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

  /// A factory constructor that creates a `SideQuest` instance from a JSON map.
  ///
  /// This method maps the JSON key `\$id` to the `id` field before calling the
  /// generated `_$SideQuestFromJson` function to create the `SideQuest` instance.
  ///
  /// @param json A map representing the JSON data.
  /// @return A `SideQuest` instance created from the JSON data.
  factory SideQuest.fromJson(Map<String, dynamic> json) {
    // Map $id to id
    json['id'] = json['\$id'];

    return _$SideQuestFromJson(json);
  }

  /// Converts the SideQuest instance to a JSON map.
  ///
  /// This method uses the generated `_$SideQuestToJson` function to
  /// serialize the instance into a map of key-value pairs, where the keys
  /// are strings and the values are dynamic.
  ///
  /// Returns a map representation of the SideQuest instance.
  Map<String, dynamic> toJson() => _$SideQuestToJson(this);
}
