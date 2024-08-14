import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sidequests/models/side_quest.dart';
import 'package:sidequests/services/feature_flags.dart';
import 'package:sidequests/services/service_manager.dart';
import 'package:sidequests/views/side_quest_item.dart';

class SideQuestList extends StatefulWidget {
  const SideQuestList({super.key});

  /// Creates and returns the mutable state for the SideQuestList widget.
  ///
  /// This method is called automatically by the Flutter framework when the
  /// SideQuestList widget is first created or when it needs to rebuild.
  ///
  /// Returns:
  ///   A new instance of _SideQuestListState, which manages the internal state
  ///   of the SideQuestList widget.
  @override
  State<SideQuestList> createState() => _SideQuestListState();
}

class _SideQuestListState extends State<SideQuestList> {
  final TextEditingController _textFieldController = TextEditingController();
  final List<SideQuest> _sideQuests = <SideQuest>[];

  bool _isLoading = true;

  /// Asynchronously loads side quest data from the database.
  Future<void> _loadData() async {
    // Access the ServiceManager from the widget's context
    final serviceManager = context.read<ServiceManager>();

    // Fetch all side quests from the database
    final allSideQuests = await serviceManager.dbHelper.getSideQuests();

    // Check if the widget is still mounted before updating the state
    if (mounted) {
      setState(() {
        // Clear existing side quests
        _sideQuests.clear();

        // Add newly fetched side quests to the list
        _sideQuests.addAll(allSideQuests);

        // Set loading state to false, indicating data fetch is complete
        _isLoading = false;
      });
    }
  }

  /// Initializes the state of the widget.
  @override
  void initState() {
    super.initState();

    // Start loading data when the widget initializes
    _loadData();
  }

  /// Handles the sign-out process for the user.
  ///
  /// This function is responsible for signing out the user from the application
  /// by accessing the AppwriteAPI through the ServiceManager.
  ///
  /// Parameters:
  /// - context: The BuildContext of the current widget tree, used to access the Provider.
  ///
  /// Note: This function does not return any value and doesn't handle exceptions.
  /// It's recommended to implement error handling in the AppwriteAPI.signOut() method.
  void _handleSignOut(BuildContext context) {
    // Access the ServiceManager without listening to changes
    // and call the signOut method from the AppwriteAPI
    Provider.of<ServiceManager>(context, listen: false).appwriteAPI.signOut();
  }

  /// Builds the widget tree for the Side Quests screen.
  ///
  /// This method constructs the UI based on the current state of the [ServiceManager]
  /// and the Appwrite feature flag. It handles two main scenarios:
  ///
  /// 1. Appwrite enabled: Displays a logout button and a list of side quests.
  /// 2. Appwrite disabled: Shows only the list of side quests.
  ///
  /// The method also sets up a listener for [ServiceManager] changes to trigger
  /// data reloading, and includes a floating action button for adding new side quests.
  ///
  /// @param context The build context for this widget.
  /// @return A [Scaffold] widget containing the constructed UI.
  @override
  Widget build(BuildContext context) {
    // Watch for changes in the ServiceManager
    final serviceManager = context.watch<ServiceManager>();

    // Add a listener to ServiceManager to trigger data reload
    serviceManager.addListener(() {
      setState(() {
        _isLoading = true;
        _loadData();
      });
    });

    Widget? widgetBody;
    // Check if Appwrite feature flag is enabled
    if (serviceManager.featureFlags.isEnabled(Flags.useAppwrite)) {
      // Build UI for Appwrite-enabled version
      widgetBody = Column(
        children: [
          // Logout button
          ElevatedButton(
              onPressed: () {
                _handleSignOut(context);
              },
              child: const Text("logout")),
          // List of side quests
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: _sideQuests.map((SideQuest sideQuest) {
                return SideQuestItem(
                  sideQuest: sideQuest,
                  onSideQuestChanged: _handleSideQuestChange,
                );
              }).toList(),
            ),
          ),
        ],
      );
    } else {
      // Build UI for non-Appwrite version (side quests list only)
      widgetBody = ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: _sideQuests.map((SideQuest sideQuest) {
          return SideQuestItem(
            sideQuest: sideQuest,
            onSideQuestChanged: _handleSideQuestChange,
          );
        }).toList(),
      );
    }

    // Return the main Scaffold widget
    return Scaffold(
      appBar: AppBar(
        title: const Text('Side Quests'),
      ),
      body: _isLoading
          ? const CircularProgressIndicator() // Show spinner while loading
          : widgetBody,
      // Floating action button to add new side quests
      floatingActionButton: FloatingActionButton(onPressed: () => _displayDialog(), tooltip: 'Add side quest', child: const Icon(Icons.add)),
    );
  }

  /// Handles the change in a side quest's completion status.
  ///
  /// This method is responsible for updating the side quest's status in the database
  /// and in the local state.
  ///
  /// @param sideQuest The SideQuest object to be updated.
  void _handleSideQuestChange(SideQuest sideQuest) async {
    // Update the side quest's completion status in the database
    await context.read<ServiceManager>().dbHelper.updateSideQuest(sideQuest.id, !sideQuest.complete);

    // Update the local state to reflect the new completion status
    setState(() {
      sideQuest.complete = !sideQuest.complete;
    });
  }

  /// Adds a new side quest item to the database and updates the UI.
  ///
  /// This method is responsible for creating a new side quest with the given [name],
  /// adding it to the local list of side quests, and clearing the text input field.
  ///
  /// Parameters:
  ///   [name] - The name of the side quest to be added.
  void _addSideQuestItem(String name) async {
    // Create a new side quest in the database using the ServiceManager
    final newSideQuest = await context.read<ServiceManager>().dbHelper.createSideQuest(name);

    // Update the local state with the newly created side quest
    setState(() {
      _sideQuests.add(newSideQuest);
    });

    // Clear the text input field after adding the side quest
    _textFieldController.clear();
  }

  /// Displays a dialog for adding a new side quest.
  ///
  /// This function shows an alert dialog with a text field for entering
  /// the name of a new side quest. It uses [showDialog] to present the dialog
  /// and returns a [Future] that completes when the dialog is dismissed.
  Future<void> _displayDialog() async {
    return showDialog<void>(
      context: context,
      // Prevents dismissing the dialog by tapping outside of it
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a new side quest'),
          content: TextField(
            // Uses a TextEditingController to manage the text input
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'Name your new side quest'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                // Closes the dialog
                Navigator.of(context).pop();
                // Adds the new side quest using the entered text
                _addSideQuestItem(_textFieldController.text);
              },
            ),
          ],
        );
      },
    );
  }
}
