import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sidequests/models/side_quest.dart';
import 'package:sidequests/services/appwrite_api.dart';
import 'package:sidequests/services/feature_flags.dart';
import 'package:sidequests/services/service_manager.dart';
import 'package:sidequests/views/side_quest_item.dart';

class SideQuestList extends StatefulWidget {
  const SideQuestList({super.key});

  @override
  State<SideQuestList> createState() => _SideQuestListState();
}

class _SideQuestListState extends State<SideQuestList> {
  final TextEditingController _textFieldController = TextEditingController();
  final List<SideQuest> _sideQuests = <SideQuest>[];

  bool _isLoading = true;

  Future<void> _loadData() async {
    final serviceManager = context.read<ServiceManager>();
    final allSideQuests = await serviceManager.dbHelper.getSideQuests();

    setState(() {
      _sideQuests.clear();
      _sideQuests.addAll(allSideQuests);
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData(); // Start loading data when the widget initializes
  }

  void _handleSignOut(BuildContext context) {
    Provider.of<ServiceManager>(context, listen: false).appwriteAPI.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final serviceManager = context.watch<ServiceManager>();
    serviceManager.addListener(() {
      setState(() {
        _isLoading = true;
        _loadData();
      });
    });

    Widget? widgetBody;
    if (serviceManager.featureFlags.isEnabled(Flags.useAppwrite)) {
      widgetBody = Column(
        children: [
          ElevatedButton(
              onPressed: () {
                _handleSignOut(context);
              },
              child: const Text("logout")),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Side Quests'),
      ),
      body: _isLoading
          ? const CircularProgressIndicator() // Show spinner while loading
          : widgetBody,
      floatingActionButton: FloatingActionButton(onPressed: () => _displayDialog(), tooltip: 'Add side quest', child: const Icon(Icons.add)),
    );
  }

  void _handleSideQuestChange(SideQuest sideQuest) async {
    await context.read<ServiceManager>().dbHelper.updateSideQuest(sideQuest.id, !sideQuest.complete);
    setState(() {
      sideQuest.complete = !sideQuest.complete;
    });
  }

  void _addSideQuestItem(String name) async {
    final newSideQuest = await context.read<ServiceManager>().dbHelper.createSideQuest(name);
    setState(() {
      _sideQuests.add(newSideQuest);
    });
    _textFieldController.clear();
  }

  Future<void> _displayDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a new side quest'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'Name your new side quest'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                Navigator.of(context).pop();
                _addSideQuestItem(_textFieldController.text);
              },
            ),
          ],
        );
      },
    );
  }
}
