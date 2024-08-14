import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:sidequests/services/appwrite_api.dart';
import 'package:sidequests/services/service_manager.dart';
import 'package:sidequests/views/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

/// A stateful widget that represents the login page of the application when logging in with Appwrite.
///
/// This widget provides a user interface for email/password login
/// as well as OAuth provider login options.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  /// Creates the mutable state for the LoginPage widget.
  ///
  /// This method is called automatically by the Flutter framework when
  /// the LoginPage widget is first created or when it needs to be rebuilt.
  ///
  /// Returns:
  ///   A new instance of _LoginPageState, which manages the state for
  ///   the LoginPage widget.
  @override
  _LoginPageState createState() => _LoginPageState();
}

/// The state for the [LoginPage] widget.
///
/// This class manages the state and UI logic for the login page,
/// including handling user input, authentication, and navigation.
class _LoginPageState extends State<LoginPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  /// Indicates whether a login operation is in progress.
  bool loading = false;

  /// Handles the sign-in process for the user.
  ///
  /// This method attempts to create an email session using the provided
  /// email and password. It displays a loading indicator during the process
  /// and handles potential errors.
  signIn() async {
    // Display a loading dialog to indicate the sign-in process has started
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Dialog(
            backgroundColor: Colors.transparent,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              CircularProgressIndicator(),
            ]),
          );
        });

    try {
      // Retrieve the AppwriteAPI instance from the ServiceManager
      final AppwriteAPI appwrite = context.read<ServiceManager>().appwriteAPI;

      // Attempt to create an email session with the provided credentials
      await appwrite.createEmailSession(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      // Close the loading dialog on successful sign-in
      Navigator.pop(context);
    } on AppwriteException catch (e) {
      // Close the loading dialog if an error occurs
      Navigator.pop(context);

      // Display an alert with the error message
      showAlert(title: 'Login failed', text: e.message.toString());
    }
  }

  /// Displays an alert dialog with a title, message, and an OK button.
  ///
  /// This function creates and shows a simple alert dialog using the Flutter
  /// [showDialog] function. The dialog contains a title, a message, and an OK
  /// button to dismiss the dialog.
  ///
  /// Parameters:
  /// - [title]: A required [String] that represents the title of the alert dialog.
  /// - [text]: A required [String] that represents the main message content of the alert dialog.
  ///
  /// The function uses the current [context] to show the dialog and handle navigation.
  showAlert({required String title, required String text}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // Display the provided title
          title: Text(title),
          // Display the provided text as the main content
          content: Text(text),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Dismiss the dialog when the OK button is pressed
                Navigator.pop(context);
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  /// Signs in the user using an OAuth provider.
  ///
  /// This method attempts to sign in the user using the specified OAuth provider.
  /// If the sign-in process fails, it displays an alert with the error message.
  ///
  /// Parameters:
  ///   - provider: An instance of OAuthProvider to be used for authentication.
  ///
  /// Throws:
  ///   - AppwriteException: If there's an error during the sign-in process.
  signInWithProvider(OAuthProvider provider) {
    try {
      // Attempt to sign in using the provided OAuth provider
      context.read<ServiceManager>().appwriteAPI.signInWithProvider(provider: provider);
    } on AppwriteException catch (e) {
      // If an AppwriteException occurs, show an alert with the error message
      showAlert(title: 'Login failed', text: e.message.toString());
    }
  }

  /// Builds the main UI for the login page.
  ///
  /// This method constructs a [Scaffold] widget that includes an app bar,
  /// input fields for email and password, buttons for signing in and
  /// creating an account, and a social login option (GitHub).
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sidequests'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email input field
              TextField(
                controller: emailTextController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Password input field
              TextField(
                controller: passwordTextController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              // Sign in button
              ElevatedButton.icon(
                onPressed: () {
                  signIn();
                },
                icon: const Icon(Icons.login),
                label: const Text("Sign in"),
              ),
              // Create account button
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                },
                child: const Text('Create Account'),
              ),
              const SizedBox(height: 16),
              // Social login options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // GitHub login button
                  ElevatedButton(
                    onPressed: () => signInWithProvider(OAuthProvider.github),
                    style: ElevatedButton.styleFrom(foregroundColor: Colors.black, backgroundColor: Colors.white),
                    child: SvgPicture.asset('assets/img/github_icon.svg', width: 12),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
