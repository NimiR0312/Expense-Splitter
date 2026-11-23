class Member {
  final String name;
  final bool isAdmin;
  final DateTime joinedAt;

  const Member({
    required this.name,
    required this.isAdmin,
    required this.joinedAt,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      name: json["name"] as String,
      isAdmin: json["isAdmin"] as bool,
      joinedAt: DateTime.parse(json["joinedAt"] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "isAdmin": isAdmin,
      "joinedAt": joinedAt.toIso8601String(),
    };
  }

  Member copyWith({
    String? name,
    bool? isAdmin,
    DateTime? joinedAt,
  }) {
    return Member(
      name: name ?? this.name,
      isAdmin: isAdmin ?? this.isAdmin,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}