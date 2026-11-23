import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/groups/models/group_model.dart';

class StorageService {
  static const String _groupsKey = 'saved_groups_v1';
  static const String _userNameKey = 'user_name_v1';

  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name.trim());
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<void> saveGroup(Group group) async {
    final prefs = await SharedPreferences.getInstance();
    final groups = await getSavedGroups();

    // Move to front if already exists, else insert at top
    groups.removeWhere((g) => g.id == group.id);
    groups.insert(0, group);

    final jsonList = groups.map((g) => jsonEncode(g.toJson())).toList();
    await prefs.setStringList(_groupsKey, jsonList);
  }

  static Future<List<Group>> getSavedGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_groupsKey) ?? [];

    final List<Group> groups = [];
    for (final item in jsonList) {
      try {
        final decoded = jsonDecode(item) as Map<String, dynamic>;
        groups.add(Group.fromJson(decoded));
      } catch (e) {
        print('[StorageService] Error parsing saved group: $e');
      }
    }
    return groups;
  }

  static Future<void> removeGroup(String groupId) async {
    final prefs = await SharedPreferences.getInstance();
    final groups = await getSavedGroups();
    groups.removeWhere((g) => g.id == groupId);
    final jsonList = groups.map((g) => jsonEncode(g.toJson())).toList();
    await prefs.setStringList(_groupsKey, jsonList);
  }
}
