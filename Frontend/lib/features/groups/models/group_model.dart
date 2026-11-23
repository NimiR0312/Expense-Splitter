import 'member_model.dart';

class Group {
  final String id;
  final String groupName;
  final String groupCode;
  final List<Member> members;

  const Group({
    required this.id,
    required this.groupName,
    required this.groupCode,
    required this.members,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json["_id"] as String,
      groupName: json["groupName"] as String,
      groupCode: json["groupCode"] as String,
      members: (json["members"] as List<dynamic>)
          .map((member) => Member.fromJson(member))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "groupName": groupName,
      "groupCode": groupCode,
      "members": members
          .map((member) => member.toJson())
          .toList(),
    };
  }

  Group copyWith({
    String? id,
    String? groupName,
    String? groupCode,
    List<Member>? members,
  }) {
    return Group(
      id: id ?? this.id,
      groupName: groupName ?? this.groupName,
      groupCode: groupCode ?? this.groupCode,
      members: members ?? this.members,
    );
  }
}