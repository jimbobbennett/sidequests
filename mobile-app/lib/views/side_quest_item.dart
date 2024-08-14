import 'package:flutter/material.dart';
import 'package:sidequests/models/side_quest.dart';

/// A widget that represents a single side quest item in a list.
///
/// This widget displays a [ListTile] with the side quest's name and completion status.
/// It also provides functionality to toggle the completion status of the side quest.
class SideQuestItem extends StatelessWidget {
  /// Creates a [SideQuestItem].
  ///
  /// The [sideQuest] parameter is required and represents the side quest to be displayed.
  /// The [onSideQuestChanged] parameter is a callback function that is called when the side quest's status is toggled.
  SideQuestItem({
    required this.sideQuest,
    required this.onSideQuestChanged,
  }) : super(key: ObjectKey(sideQuest));

  /// The side quest to be displayed.
  final SideQuest sideQuest;

  /// A callback function that is called when the side quest's status is toggled.
  final Function(SideQuest) onSideQuestChanged;

  /// Returns a [TextStyle] based on the completion status of the side quest.
  ///
  /// If [checked] is true, it returns a style with a line-through decoration.
  /// Otherwise, it returns null.
  TextStyle? _getTextStyle(bool checked) {
    if (!checked) return null;

    return const TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
  }

  /// Builds a ListTile widget representing a side quest.
  ///
  /// This widget is typically used in a list of side quests, displaying
  /// the quest's name and completion status.
  ///
  /// @param context The build context.
  /// @return A ListTile widget representing the side quest.
  @override
  Widget build(BuildContext context) {
    return ListTile(
      // Handles the tap event on the ListTile
      onTap: () {
        // Calls the callback function to update the selected side quest
        onSideQuestChanged(sideQuest);
      },
      // Displays the first letter of the side quest name in a circle
      leading: CircleAvatar(
        child: Text(sideQuest.name[0]),
      ),
      // Displays the full name of the side quest
      // The text style is determined by the completion status
      title: Text(sideQuest.name, style: _getTextStyle(sideQuest.complete)),
    );
  }
}
