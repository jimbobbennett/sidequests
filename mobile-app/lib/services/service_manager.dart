import 'package:flutter/material.dart';
import 'package:sidequests/services/appwrite_api.dart';
import 'package:sidequests/services/feature_flags.dart';
import 'package:sidequests/services/side_quest_db_helper.dart';
import 'package:sidequests/services/sqlite_db_helper.dart';

/// A class that manages various services and APIs used in the application.
///
/// This class is responsible for initializing and providing access to:
/// * Feature flags
/// * Appwrite API
/// * SQLite database helper
///
/// It also manages the readiness state of these services and notifies listeners
/// when changes occur. The class implements [ChangeNotifier] to allow widgets
/// to rebuild when the underlying services change.
///
/// The [dbHelper] getter dynamically returns either the Appwrite API or SQLite
/// helper based on the current feature flag configuration.
class ServiceManager extends ChangeNotifier {
  ServiceManager() {
    create();
  }

  late FeatureFlags _featureFlags;
  FeatureFlags get featureFlags => _featureFlags;

  late AppwriteAPI _appwriteAPI;
  AppwriteAPI get appwriteAPI => _appwriteAPI;

  late SQliteDBHelper _sqliteDBHelper;
  SQliteDBHelper get sqliteDBHelper => _sqliteDBHelper;

  late bool _isReady = false;
  bool get isReady => _isReady;

  SideQuestDBHelper get dbHelper => _featureFlags.isEnabled(Flags.useAppwrite) ? _appwriteAPI : _sqliteDBHelper;

  /// Initializes and sets up the main components of the application.
  ///
  /// This asynchronous method creates instances of FeatureFlags, AppwriteAPI,
  /// and SQliteDBHelper. It also sets up listeners for feature flags and
  /// Appwrite API changes, and marks the initialization as complete.
  Future<void> create() async {
    // Initialize feature flags
    _featureFlags = await FeatureFlags.create();

    // Initialize the Appwrite API and SQLite. Although we will only be using one at a time,
    // initialize both so we can quickly switch them out at run time with a feature flag

    // Initialize Appwrite API
    _appwriteAPI = await AppwriteAPI.create();

    // Initialize SQLite database helper
    _sqliteDBHelper = await SQliteDBHelper.create();

    // Set up a listener for feature flag changes
    _featureFlags.addListener(() {
      notifyListeners();
    });

    // Set up a listener for Appwrite API changes
    _appwriteAPI.addListener(() => notifyListeners());

    // Mark initialization as complete
    _isReady = true;

    // Notify listeners that initialization is complete
    notifyListeners();
  }
}
