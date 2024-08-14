import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:sidequests/services/appwrite_api.dart';
import 'package:sidequests/services/feature_flags.dart';
import 'package:sidequests/services/service_manager.dart';
import 'package:sidequests/views/login_page.dart';
import 'package:sidequests/views/side_quest_list.dart';

import 'package:provider/provider.dart';

/// Main function to start the Flutter application asynchronously.
void main() async {
  // Ensure Flutter bindings are initialized before any other code runs.
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from a .env file.
  // This is useful for managing configuration settings and secrets.
  await dotenv.load(fileName: ".env");

  // Run the Flutter application.
  // ChangeNotifierProvider is used to provide an instance of ServiceManager
  // to the widget tree, allowing for state management.
  runApp(
    ChangeNotifierProvider(
      // Create an instance of ServiceManager.
      create: (context) => ServiceManager(),
      // The child widget that will have access to the ServiceManager instance.
      child: const SideQuestsApp(),
    ),
  );
}

/// A stateless widget that represents the main application
class SideQuestsApp extends StatelessWidget {
  const SideQuestsApp({super.key});

  /// Builds the main widget for the application.
  ///
  /// This method constructs the main widget tree based on the state of the
  /// `ServiceManager`. It listens to the `ServiceManager` and updates the UI
  /// accordingly.
  ///
  /// - If the `ServiceManager` is not ready, it shows a loading indicator.
  /// - If the `ServiceManager` is ready and the `useAppwrite` feature flag is enabled:
  ///   - If the user is authenticated, it shows the `SideQuestList`.
  ///   - If the user is unauthenticated, it shows the `LoginPage`.
  /// - If the `useAppwrite` feature flag is not enabled, it shows the `SideQuestList`.
  ///
  /// Returns a `MaterialApp` widget with the appropriate home widget.
  @override
  Widget build(BuildContext context) {
    // Obtain the ServiceManager instance from the context
    final serviceManager = context.watch<ServiceManager>();

    // Check if the ServiceManager is ready
    final serviceManagerIsReady = serviceManager.isReady;

    // Default widget body to show a loading indicator
    Widget widgetBody = const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );

    // If the ServiceManager is ready, determine which widget to display
    if (serviceManagerIsReady) {
      // Check if the useAppwrite feature flag is enabled
      if (serviceManager.featureFlags.isEnabled(Flags.useAppwrite)) {
        // If the user is authenticated, show the SideQuestList
        if (serviceManager.appwriteAPI.status == AuthStatus.authenticated) {
          widgetBody = const SideQuestList();
        }
        // If the user is unauthenticated, show the LoginPage
        else if (serviceManager.appwriteAPI.status == AuthStatus.unauthenticated) {
          widgetBody = const LoginPage();
        }
      }
      // If the useAppwrite feature flag is not enabled, show the SideQuestList
      else {
        widgetBody = const SideQuestList();
      }
    }

    // Return the MaterialApp with the determined home widget
    return MaterialApp(title: 'SideQuests', home: widgetBody);
  }
}
