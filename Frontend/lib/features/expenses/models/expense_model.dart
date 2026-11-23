class Expense {
  final String? id;
  final String title;
  final double amount;
  final String paidBy;
  final List<String> splitBetween;
  final String notes;
  final String groupId;
  final bool isSettlement;
  final DateTime? createdAt;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.splitBetween,
    required this.notes,
    required this.groupId,
    this.isSettlement = false,
    this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json["_id"],
      title: json["title"],
      amount: (json["amount"] as num).toDouble(),
      paidBy: json["paidBy"],
      splitBetween:
          List<String>.from(json["splitBetween"]),
      notes: json["notes"] ?? "",
      groupId: json["groupId"] is String
          ? json["groupId"]
          : json["groupId"]["_id"],
      isSettlement: json["isSettlement"] ?? false,
      createdAt: json["createdAt"] == null
          ? null
          : DateTime.parse(json["createdAt"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "amount": amount,
      "paidBy": paidBy,
      "splitBetween": splitBetween,
      "notes": notes,
      "groupId": groupId,
      "isSettlement": isSettlement,
    };
  }
}