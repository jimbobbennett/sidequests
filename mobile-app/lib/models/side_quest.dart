import 'package:json_annotation/json_annotation.dart';

part 'side_quest.g.dart';

// A class to represent a side quest
@JsonSerializable()
class SideQuest {
  SideQuest({required this.id, required this.name, required this.complete});

  // The id of the side quest
  String id;

  // The name of the side quest
  final String name;

  // Whether the side quest is complete
  bool complete;

  factory SideQuest.fromJson(Map<String, dynamic> json) {
    // Map $id to id
    json['id'] = json['\$id'];

     return _$SideQuestFromJson(json);
  }
  
  Map<String, dynamic> toJson() => _$SideQuestToJson(this);
}
