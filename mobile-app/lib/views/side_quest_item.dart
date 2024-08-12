import 'package:flutter/material.dart';
import 'package:sidequests/models/side_quest.dart';

class SideQuestItem extends StatelessWidget {
  SideQuestItem({
    required this.sideQuest,
    required this.onSideQuestChanged,
  }) : super(key: ObjectKey(sideQuest));

  final SideQuest sideQuest;
  final onSideQuestChanged;

  TextStyle? _getTextStyle(bool checked) {
    if (!checked) return null;

    return const TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onSideQuestChanged(sideQuest);
      },
      leading: CircleAvatar(
        child: Text(sideQuest.name[0]),
      ),
      title: Text(sideQuest.name, style: _getTextStyle(sideQuest.complete)),
    );
  }
}