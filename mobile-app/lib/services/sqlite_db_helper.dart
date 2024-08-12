import 'package:path/path.dart';
import 'package:sidequests/models/side_quest.dart';
import 'package:sidequests/services/side_quest_db_helper.dart';
import 'package:sqflite/sqflite.dart';

class SQliteDBHelper implements SideQuestDBHelper {
  static const String databaseName = 'sidequests';
  static const String sideQuestsTableName = 'sidequests';

  SQliteDBHelper._(this._database);

  final Database _database;

  static Future<SQliteDBHelper> create() async {
    final database = await _initDB();
    return SQliteDBHelper._(database);
  }

  /// Initializes the database connection and creates the sideQuestsTableName if it doesn't exist.
  ///
  /// Returns a [Future] that completes with the initialized database instance.
  static Future<Database> _initDB() async {
    // Get the database path using the `sqflite` package's `getDatabasesPath()` method.
    String path = join(await getDatabasesPath(), '$databaseName.db');

    // Open the database connection.
    // If the database doesn't exist, it will be created and the `onCreate` callback will be invoked.
    return await openDatabase(
      path,
      // Define the database schema in the `onCreate` callback.
      // Here, we create a table named sideQuestsTableName with columns: id, name, and age.
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE $sideQuestsTableName(id INTEGER PRIMARY KEY, name TEXT, complete BOOLEAN)",
        );
      },
      // Specify the database version.
      // Increment this value whenever you make changes to the database schema.
      version: 1,
    );
  }

  /// Get all the side quests from the database
  @override
  Future<List<SideQuest>> getSideQuests() async {
    final data = await _database.query(sideQuestsTableName);

    return data.map((e) {
      return SideQuest(
          id: e['id'].toString(),
          name: e['name'].toString(),
          complete: int.parse(e['complete'].toString()) == 1);
    }).toList();
  }

  /// Create a new side quest in the database.
  ///
  /// [name] is the name of the side quest to be created.
  ///
  /// Returns a [Future] that resolves with the newly created [SideQuest] object.
  @override
  Future<SideQuest> createSideQuest(String name) async {
    // Insert a new side quest into the database and retrieve the generated ID.
    final id = await _database.insert(sideQuestsTableName, {'name': name, 'complete': false});
    // Create a new SideQuest object with the retrieved ID, provided name, and initial completion status of false.
    return SideQuest(id: id.toString(), name: name, complete: false);
  }

  /// Update the completion status of a side quest in the database.
  /// [id] is the ID of the side quest to be updated.
  /// [complete] is the new completion status of the side quest.
  /// Returns a [Future] that resolves with the updated [SideQuest] object.
  /// If the side quest with the provided ID doesn't exist, the method will throw an error.
  @override
  Future<SideQuest> updateSideQuest(String id, bool complete) async {
    // Update the completion status of the side quest with the provided ID.
    await _database.update(sideQuestsTableName, {'complete': complete ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
    // Retrieve the updated side quest from the database.
    final data = await _database.query(sideQuestsTableName, where: 'id = ?', whereArgs: [id]);
    // Create a new SideQuest object with the updated completion status.
    return SideQuest(
        id: data.first['id'].toString(),
        name: data.first['name'].toString(),
        complete: int.parse(data.first['complete'].toString()) == 1);
  }
}
