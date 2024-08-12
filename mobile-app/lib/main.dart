import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:sidequests/services/appwrite_api.dart';
import 'package:sidequests/services/feature_flags.dart';
import 'package:sidequests/services/service_manager.dart';
import 'package:sidequests/views/login_page.dart';
import 'package:sidequests/views/side_quest_list.dart';

import 'package:provider/provider.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(
    ChangeNotifierProvider(
        create: (context) => ServiceManager(), child: const SideQuestsApp()),
  );
}

class SideQuestsApp extends StatelessWidget {
  const SideQuestsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceManager = context.watch<ServiceManager>();
    final serviceManagerIsReady = serviceManager.isReady;

    Widget widgetBody = const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );

    if (serviceManagerIsReady) {
      if (serviceManager.featureFlags.isEnabled(Flags.useAppwrite)) {
        if (serviceManager.appwriteAPI.status == AuthStatus.authenticated) {
          widgetBody = const SideQuestList();
        } else if (serviceManager.appwriteAPI.status ==
            AuthStatus.unauthenticated) {
          widgetBody = const LoginPage();
        }
      } else {
          widgetBody = const SideQuestList();
      }
    }

    return MaterialApp(title: 'SideQuests', home: widgetBody);
  }
}
