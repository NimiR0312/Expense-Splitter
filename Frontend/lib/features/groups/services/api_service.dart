import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../models/group_model.dart';

class ApiService {
  static String get _baseUrl => AppConfig.groupsUrl;

  static const Map<String, String> _headers = {
    "Content-Type": "application/json",
  };

  static Group _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return Group.fromJson(data["data"]);
    }

    throw Exception(
      data["message"] ?? "Something went wrong",
    );
  }

  // ---------------- CREATE GROUP ----------------

  static Future<Group> createGroup(
    String groupName,
    String creatorName,
  ) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: jsonEncode({
        "groupName": groupName,
        "creatorName": creatorName,
      }),
    );

    return _handleResponse(response);
  }

  // ---------------- JOIN GROUP ----------------

  static Future<Group> joinGroup({
    required String groupCode,
    required String memberName,
  }) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/join"),
      headers: _headers,
      body: jsonEncode({
        "groupCode": groupCode.trim().toUpperCase(),
        "memberName": memberName.trim(),
      }),
    );

    return _handleResponse(response);
  }

  // ---------------- GET GROUP BY ID ----------------

  static Future<Group> getGroupById(String groupId) async {
    final response = await http.get(
      Uri.parse("$_baseUrl/$groupId"),
    );

    return _handleResponse(response);
  }
}