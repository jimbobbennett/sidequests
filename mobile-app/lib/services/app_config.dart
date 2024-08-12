import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class AppConfig {
  AppConfig._(this._database);

  final Database _database;

  static Future<AppConfig> create() async {
    final database = await _initDB();
    return AppConfig._(database);
  }

  static Future<Database> _initDB() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/app_config.db';
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE app_config (
        id INTEGER PRIMARY KEY,
        email TEXT
      )
    ''');
  }

  Future<String?> getFirstEmail() async {
    final result = await _database.rawQuery("SELECT email FROM app_config ORDER BY id ASC LIMIT 1");
    if (result.isNotEmpty) {
      return result.first['email'] as String?;
    }
    return null;
  }


  Future<bool> emailExists(String email) async {
    final result = await _database
        .rawQuery("SELECT * FROM app_config WHERE email = ?", [email]);
    return result.isNotEmpty;
  }

  Future<void> addEmail(String email) async {
    if (!await emailExists(email)) {
      await _database.delete("app_config");
      await _database
          .rawInsert("INSERT INTO app_config (email) VALUES (?)", [email]);
    }
  }
}

