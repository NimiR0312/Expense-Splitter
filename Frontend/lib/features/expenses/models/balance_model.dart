class MemberBalance {
  final String name;
  final double totalPaid;
  final double totalOwed;
  final double netBalance;

  MemberBalance({
    required this.name,
    required this.totalPaid,
    required this.totalOwed,
    required this.netBalance,
  });

  factory MemberBalance.fromJson(Map<String, dynamic> json) {
    return MemberBalance(
      name: json["name"] ?? "",
      totalPaid: (json["totalPaid"] as num?)?.toDouble() ?? 0.0,
      totalOwed: (json["totalOwed"] as num?)?.toDouble() ?? 0.0,
      netBalance: (json["netBalance"] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SettlementSuggestion {
  final String from;
  final String to;
  final double amount;

  SettlementSuggestion({
    required this.from,
    required this.to,
    required this.amount,
  });

  factory SettlementSuggestion.fromJson(Map<String, dynamic> json) {
    return SettlementSuggestion(
      from: json["from"] ?? "",
      to: json["to"] ?? "",
      amount: (json["amount"] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class GroupBalancesResponse {
  final double totalGroupSpending;
  final List<MemberBalance> balances;
  final List<SettlementSuggestion> settlements;

  GroupBalancesResponse({
    required this.totalGroupSpending,
    required this.balances,
    required this.settlements,
  });

  factory GroupBalancesResponse.fromJson(Map<String, dynamic> json) {
    return GroupBalancesResponse(
      totalGroupSpending:
          (json["totalGroupSpending"] as num?)?.toDouble() ?? 0.0,
      balances: (json["balances"] as List? ?? [])
          .map((b) => MemberBalance.fromJson(b))
          .toList(),
      settlements: (json["settlements"] as List? ?? [])
          .map((s) => SettlementSuggestion.fromJson(s))
          .toList(),
    );
  }
}
