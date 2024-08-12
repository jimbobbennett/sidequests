import 'package:sidequests/models/side_quest.dart';

abstract class SideQuestDBHelper {
  Future<List<SideQuest>> getSideQuests();
  Future<SideQuest> createSideQuest(String name);
  Future<SideQuest> updateSideQuest(String id, bool complete);
}
