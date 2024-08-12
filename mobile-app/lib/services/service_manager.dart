import 'package:flutter/material.dart';
import 'package:sidequests/services/app_config.dart';
import 'package:sidequests/services/appwrite_api.dart';
import 'package:sidequests/services/feature_flags.dart';
import 'package:sidequests/services/side_quest_db_helper.dart';
import 'package:sidequests/services/sqlite_db_helper.dart';

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

  late AppConfig _appConfig;
  AppConfig get appConfig => _appConfig;

  late bool _isReady = false;
  bool get isReady => _isReady;

  SideQuestDBHelper get dbHelper => _featureFlags.isEnabled(Flags.useAppwrite)
      ? _appwriteAPI
      : _sqliteDBHelper;

  Future<void> create() async {
    _featureFlags = await FeatureFlags.create();
    _appwriteAPI = await AppwriteAPI.create();
    _sqliteDBHelper = await SQliteDBHelper.create();
    _appConfig = await AppConfig.create();

    _featureFlags.addListener(() {
      notifyListeners();
  });
    _appwriteAPI.addListener(() => notifyListeners());

    _isReady = true;
    notifyListeners();
  }
}
