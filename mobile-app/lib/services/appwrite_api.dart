import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sidequests/models/side_quest.dart';
import 'package:sidequests/services/side_quest_db_helper.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}

class AppwriteAPI extends ChangeNotifier implements SideQuestDBHelper {
  AppwriteAPI._(this._client, this._account, this._databases, this._databaseId,
      this._collectionId);

  final Client _client;
  final Account _account;
  final Databases _databases;
  final String _databaseId;
  final String _collectionId;

  late User _currentUser;

  AuthStatus _status = AuthStatus.uninitialized;

  // Getter methods
  User get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get username => _currentUser?.name;
  String? get email => _currentUser?.email;
  String? get userid => _currentUser?.$id;

  static Future<AppwriteAPI> create() async {
    final String appwriteProjectId = dotenv.env["APPWRITE_PROJECT_ID"]!;
    final String databaseId = dotenv.env["APPWRITE_DATABASE_ID"]!;
    final String collectionId = dotenv.env["APPWRITE_COLLECTION_ID"]!;

    final client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject(appwriteProjectId)
        .setSelfSigned();

    final account = Account(client);
    final databases = Databases(client);

    final appwriteAPI =
        AppwriteAPI._(client, account, databases, databaseId, collectionId);

    await appwriteAPI.loadUser();
    return appwriteAPI;
  }

  loadUser() async {
    try {
      final user = await _account.get();
      _status = AuthStatus.authenticated;
      _currentUser = user;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  Future<User> createUser(
      {required String email, required String password}) async {
    notifyListeners();

    try {
      final user = await _account.create(
          userId: ID.unique(), email: email, password: password, name: email);
      return user;
    } finally {
      notifyListeners();
    }
  }

  Future<Session> createEmailSession(
      {required String email, required String password}) async {
    notifyListeners();

    try {
      final session = await _account.createEmailPasswordSession(
          email: email, password: password);
      _currentUser = await _account.get();
      _status = AuthStatus.authenticated;
      return session;
    } finally {
      notifyListeners();
    }
  }

  signInWithProvider({required OAuthProvider provider}) async {
    try {
      final session = await _account.createOAuth2Session(provider: provider);
      _currentUser = await _account.get();
      _status = AuthStatus.authenticated;
      return session;
    } finally {
      notifyListeners();
    }
  }

  signOut() async {
    try {
      await _account.deleteSession(sessionId: 'current');
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  Future<Preferences> getUserPreferences() async {
    return await _account.getPrefs();
  }

  updatePreferences({required String bio}) async {
    return _account.updatePrefs(prefs: {'bio': bio});
  }

  @override
  Future<SideQuest> createSideQuest(String name) async {
    final data = {
      'name': name,
      'complete': false,
    };
    final document = await _databases.createDocument(databaseId: _databaseId, collectionId: _collectionId, documentId: ID.unique(), data: data);
    return SideQuest.fromJson(document.data.map((k, v) => MapEntry(k.toString(), v)));
  }

  @override
  Future<List<SideQuest>> getSideQuests() async {
    final documents = await _databases.listDocuments(databaseId: _databaseId, collectionId: _collectionId);
    return documents.convertTo<SideQuest>((json) => SideQuest.fromJson(json.map((k, v) => MapEntry(k.toString(), v)))).toList();
  }

  @override
  Future<SideQuest> updateSideQuest(String id, bool complete) async {
    final document = await _databases.updateDocument(databaseId: _databaseId, collectionId: _collectionId, documentId: id, data: {
      'complete': complete,
    });

    return SideQuest.fromJson(document.data.map((k, v) => MapEntry(k.toString(), v)));
  }
}
