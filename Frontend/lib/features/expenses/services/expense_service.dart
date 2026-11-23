import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../models/expense_model.dart';
import '../models/balance_model.dart';

class ExpenseService {
  static String get _baseUrl => AppConfig.expensesUrl;

  static const Map<String, String> _headers = {
    "Content-Type": "application/json",
  };

  static dynamic _parseResponse(http.Response response) {
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    throw Exception(
      data["message"] ??
          "Something went wrong",
    );
  }

  // ---------------- CREATE ----------------

  static Future<Expense> addExpense({
    required Expense expense,
  }) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: jsonEncode(
        expense.toJson(),
      ),
    );

    final data = _parseResponse(response);

    return Expense.fromJson(
      data["data"],
    );
  }

  // ---------------- READ ALL ----------------

  static Future<List<Expense>> getExpenses(
    String groupId,
  ) async {
    final response = await http.get(
      Uri.parse(
        "$_baseUrl/$groupId",
      ),
    );

    final data = _parseResponse(response);

    return (data["data"] as List)
        .map(
          (expense) =>
              Expense.fromJson(expense),
        )
        .toList();
  }

  // ---------------- READ ONE ----------------

  static Future<Expense> getExpense(
    String expenseId,
  ) async {
    final response = await http.get(
      Uri.parse(
        "$_baseUrl/details/$expenseId",
      ),
    );

    final data = _parseResponse(response);

    return Expense.fromJson(
      data["data"],
    );
  }

  // ---------------- UPDATE ----------------

  static Future<Expense> updateExpense({
    required String expenseId,
    required Expense expense,
  }) async {
    final response = await http.put(
      Uri.parse(
        "$_baseUrl/$expenseId",
      ),
      headers: _headers,
      body: jsonEncode(
        expense.toJson(),
      ),
    );

    final data = _parseResponse(response);

    return Expense.fromJson(
      data["data"],
    );
  }

  // ---------------- DELETE ----------------

  static Future<void> deleteExpense(
    String expenseId,
  ) async {
    final response = await http.delete(
      Uri.parse(
        "$_baseUrl/$expenseId",
      ),
    );

    _parseResponse(response);
  }

  // ---------------- BALANCES & SETTLEMENTS ----------------

  static Future<GroupBalancesResponse> getGroupBalances(
    String groupId,
  ) async {
    final response = await http.get(
      Uri.parse("$_baseUrl/balances/$groupId"),
    );

    final data = _parseResponse(response);

    return GroupBalancesResponse.fromJson(data["data"]);
  }

  // ---------------- RECORD SETTLEMENT ----------------

  static Future<Expense> settleDebt({
    required String groupId,
    required String from,
    required String to,
    required double amount,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/settle"),
      headers: _headers,
      body: jsonEncode({
        "groupId": groupId,
        "from": from,
        "to": to,
        "amount": amount,
        if (notes != null && notes.isNotEmpty) "notes": notes,
      }),
    );

    final data = _parseResponse(response);

    return Expense.fromJson(data["data"]);
  }
}