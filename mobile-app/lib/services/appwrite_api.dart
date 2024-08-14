import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sidequests/models/side_quest.dart';
import 'package:sidequests/services/side_quest_db_helper.dart';

/// The authentication status of the user
enum AuthStatus {
  uninitialized, // No current authenticated user, for example the app has just been launched for the first time
  authenticated, // There is a user and they are authenticated
  unauthenticated, // There is a user and they are unauthenticated, for example they logged out
}

class AppwriteAPI extends ChangeNotifier implements SideQuestDBHelper {
  AppwriteAPI._(this._client, this._account, this._databases, this._databaseId, this._collectionId);

  // ignore: unused_field
  final Client _client;
  final Account _account;
  final Databases _databases;
  final String _databaseId;
  final String _collectionId;

  late User _currentUser;

  AuthStatus _status = AuthStatus.uninitialized;

  User get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get username => _currentUser.name;
  String? get email => _currentUser.email;
  String? get userId => _currentUser.$id;

  /// Creates and initializes an instance of AppwriteAPI.
  ///
  /// This static method sets up the Appwrite client, account, and database connections
  /// using environment variables for configuration. It also loads the user information.
  ///
  /// Returns:
  ///   A Future that resolves to an initialized AppwriteAPI instance.
  static Future<AppwriteAPI> create() async {
    // Retrieve Appwrite configuration from environment variables
    final String appwriteProjectId = dotenv.env["APPWRITE_PROJECT_ID"]!;
    final String databaseId = dotenv.env["APPWRITE_DATABASE_ID"]!;
    final String collectionId = dotenv.env["APPWRITE_COLLECTION_ID"]!;

    // Initialize Appwrite client
    final client = Client().setEndpoint('https://cloud.appwrite.io/v1').setProject(appwriteProjectId).setSelfSigned();

    // Create Account and Databases instances
    final account = Account(client);
    final databases = Databases(client);

    // Create an instance of AppwriteAPI with initialized components
    final appwriteAPI = AppwriteAPI._(client, account, databases, databaseId, collectionId);

    // Load user information
    await appwriteAPI.loadUser();

    return appwriteAPI;
  }

  /// Attempts to load the user's account information.
  ///
  /// This asynchronous method tries to fetch the user data from the account service.
  /// If successful, it updates the authentication status and current user.
  /// If an error occurs, it sets the status to unauthenticated.
  /// In both cases, it notifies listeners of any changes.
  loadUser() async {
    try {
      // Attempt to retrieve user data from the account service
      final user = await _account.get();

      // Update authentication status and current user if successful
      _status = AuthStatus.authenticated;
      _currentUser = user;
    } catch (e) {
      // Set status to unauthenticated if an error occurs
      _status = AuthStatus.unauthenticated;
    } finally {
      // Notify listeners of any changes, regardless of the outcome
      notifyListeners();
    }
  }

  /// Creates a new user account with the provided email and password.
  ///
  /// This method attempts to create a new user in the system using the given
  /// credentials. It notifies listeners before and after the creation process.
  ///
  /// Parameters:
  ///   - email: The email address for the new user account.
  ///   - password: The password for the new user account.
  ///
  /// Returns:
  ///   A Future that resolves to a User object representing the newly created account.
  ///
  /// Throws:
  ///   May throw exceptions related to account creation failures (e.g., network issues,
  ///   invalid credentials, etc.). These exceptions are not caught in this method.
  Future<User> createUser({required String email, required String password}) async {
    // Notify listeners that the creation process is starting
    notifyListeners();

    try {
      // Attempt to create a new user account
      final user = await _account.create(userId: ID.unique(), email: email, password: password, name: email // Using email as the initial name
          );
      return user;
    } finally {
      // Notify listeners that the creation process has completed
      // This is called regardless of success or failure
      notifyListeners();
    }
  }

  /// Creates an email-based session for user authentication.
  ///
  /// This method attempts to create a new session using the provided email and password.
  /// It notifies listeners before and after the authentication attempt.
  ///
  /// Parameters:
  ///   - email: The user's email address.
  ///   - password: The user's password.
  ///
  /// Returns:
  ///   A [Future] that resolves to a [Session] object if authentication is successful.
  ///
  /// Throws:
  ///   Any exceptions that occur during the authentication process.
  Future<Session> createEmailSession({
    required String email,
    required String password,
  }) async {
    // Notify listeners that the authentication process is starting
    notifyListeners();

    try {
      // Attempt to create an email/password session
      final session = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      // If successful, get the current user's information
      _currentUser = await _account.get();

      // Update the authentication status
      _status = AuthStatus.authenticated;

      // Return the created session
      return session;
    } finally {
      // Notify listeners that the authentication process has completed,
      // regardless of whether it was successful or not
      notifyListeners();
    }
  }

  /// Signs in the user using an OAuth provider.
  ///
  /// This method attempts to create an OAuth2 session using the provided [provider].
  /// If successful, it updates the current user and authentication status.
  ///
  /// Parameters:
  ///   - [provider]: The OAuth provider to use for authentication.
  ///
  /// Returns:
  ///   A [Future] that resolves to the created OAuth2 session.
  ///
  /// Throws:
  ///   Any exceptions that might occur during the OAuth2 session creation process.
  signInWithProvider({required OAuthProvider provider}) async {
    try {
      // Attempt to create an OAuth2 session with the provided provider
      final session = await _account.createOAuth2Session(provider: provider);

      // Update the current user
      _currentUser = await _account.get();

      // Set the authentication status to authenticated
      _status = AuthStatus.authenticated;

      // Return the created session
      return session;
    } finally {
      // Notify listeners of potential state changes, regardless of success or failure
      notifyListeners();
    }
  }

  /// Signs out the current user by deleting their session.
  ///
  /// This method attempts to delete the current session from the account.
  /// If successful, it updates the authentication status to unauthenticated.
  /// Regardless of the outcome, it notifies listeners of any potential changes.
  signOut() async {
    try {
      // Attempt to delete the current session
      await _account.deleteSession(sessionId: 'current');

      // Update the authentication status to unauthenticated
      _status = AuthStatus.unauthenticated;
    } finally {
      // Notify listeners of potential changes, regardless of success or failure
      notifyListeners();
    }
  }

  /// Creates a new side quest in the database.
  ///
  /// This function takes a [name] parameter and creates a new side quest
  /// document in the database with the given name and a default 'complete'
  /// status of false.
  ///
  /// Parameters:
  ///   - [name]: A String representing the name of the side quest.
  ///
  /// Returns:
  ///   A Future<SideQuest> representing the newly created side quest.
  @override
  Future<SideQuest> createSideQuest(String name) async {
    // Prepare the data for the new side quest document
    final data = {
      'name': name,
      'complete': false,
    };

    // Create a new document in the database
    final document = await _databases.createDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: ID.unique(), // Generate a unique ID for the document
      data: data,
    );

    // Convert the document data to a SideQuest object and return it
    return SideQuest.fromJson(document.data.map((k, v) => MapEntry(k.toString(), v)));
  }

  /// Retrieves a list of side quests from the database.
  ///
  /// This function asynchronously fetches side quest documents from the database
  /// and converts them into [SideQuest] objects.
  ///
  /// Returns a [Future] that resolves to a [List] of [SideQuest] objects.
  @override
  Future<List<SideQuest>> getSideQuests() async {
    // Fetch documents from the database using the specified database and collection IDs
    final documents = await _databases.listDocuments(databaseId: _databaseId, collectionId: _collectionId);

    // Convert the fetched documents to SideQuest objects
    // 1. Use the convertTo method to transform each document
    // 2. Apply the SideQuest.fromJson constructor to parse the JSON data
    // 3. Convert the result to a List
    return documents.convertTo<SideQuest>((json) => SideQuest.fromJson(json.map((k, v) => MapEntry(k.toString(), v)))).toList();
  }

  /// Updates the completion status of a SideQuest.
  ///
  /// This method updates the 'complete' field of a SideQuest document in the database.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the SideQuest to be updated.
  /// - [complete]: A boolean value indicating whether the SideQuest is completed or not.
  ///
  /// Returns:
  /// A [Future] that resolves to a [SideQuest] object representing the updated SideQuest.
  ///
  /// Throws:
  /// May throw exceptions related to database operations if the update fails.
  @override
  Future<SideQuest> updateSideQuest(String id, bool complete) async {
    // Update the document in the database
    final document = await _databases.updateDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: id,
      data: {
        'complete': complete,
      },
    );

    // Convert the updated document data to a SideQuest object and return it
    return SideQuest.fromJson(document.data.map((k, v) => MapEntry(k.toString(), v)));
  }
}
