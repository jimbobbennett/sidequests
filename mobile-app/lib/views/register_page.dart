import 'package:appwrite/appwrite.dart';
import 'package:sidequests/services/appwrite_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A widget that represents the registration page of the application.
///
/// This widget is stateful and creates an instance of [_RegisterPageState]
/// to manage its state.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  /// Creates the mutable state for the RegisterPage widget.
  ///
  /// This method is called automatically by the Flutter framework when
  /// the RegisterPage widget is first created or when it needs to be rebuilt.
  ///
  /// Returns:
  ///   An instance of _RegisterPageState, which manages the state of the RegisterPage.
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

/// The state for the [RegisterPage] widget.
///
/// This class manages the state of the registration page, including
/// text controllers for email and password inputs, methods for account
/// creation, and UI building.
class _RegisterPageState extends State<RegisterPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  /// Creates a new user account using the provided email and password.
  /// Displays a loading indicator during the process and handles success/failure scenarios.
  createAccount() async {
    // Show a loading dialog to indicate that account creation is in progress
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
      // Get the AppwriteAPI instance from the context
      final AppwriteAPI appwrite = context.read<AppwriteAPI>();

      // Attempt to create a new user with the provided email and password
      await appwrite.createUser(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      // Dismiss the loading dialog
      Navigator.pop(context);

      // Show a success message using a SnackBar
      const snackbar = SnackBar(
        content: Text('Account created!'),
        duration: Duration(seconds: 2),
      );
      final scaffoldController = ScaffoldMessenger.of(context);
      scaffoldController.showSnackBar(snackbar);

      // Wait for 2 seconds before navigating back
      await Future.delayed(const Duration(seconds: 2));

      // Navigate back to the previous screen
      Navigator.pop(context);
    } on AppwriteException catch (e) {
      // Handle Appwrite-specific exceptions
      Navigator.pop(context); // Dismiss the loading dialog
      showAlert(title: 'Account creation failed', text: e.message.toString());
    }
  }

  /// Displays an alert dialog with a title, message, and an 'Ok' button.
  ///
  /// This function creates and shows a simple alert dialog using the [showDialog] method.
  /// The dialog contains a title, a message, and an 'Ok' button to dismiss it.
  ///
  /// Parameters:
  /// - [title]: A required [String] that represents the title of the alert dialog.
  /// - [text]: A required [String] that represents the main message body of the alert dialog.
  ///
  /// The function uses the current [BuildContext] to display the dialog.
  showAlert({required String title, required String text}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // Set the title of the alert dialog
          title: Text(title),
          // Set the main content (message) of the alert dialog
          content: Text(text),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Close the dialog when the 'Ok' button is pressed
                Navigator.pop(context);
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  /// Builds the widget tree for the account creation screen.
  ///
  /// This method constructs a [Scaffold] with an [AppBar] and a centered [Column]
  /// containing input fields for email and password, along with a sign-up button.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create your account'),
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
                obscureText: true, // Hides the password text
              ),
              const SizedBox(height: 16),
              // Sign-up button
              ElevatedButton.icon(
                onPressed: () {
                  createAccount(); // Calls the account creation method
                },
                icon: const Icon(Icons.app_registration),
                label: const Text('Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
