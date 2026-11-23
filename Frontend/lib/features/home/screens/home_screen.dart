import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../groups/models/group_model.dart';
import '../../groups/screens/create_group_screen.dart';
import '../../groups/screens/group_details_screen.dart';
import '../../groups/screens/join_group_screen.dart';
import '../../groups/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Group> _savedGroups = [];
  String? _userName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final userName = await StorageService.getUserName();
    final groups = await StorageService.getSavedGroups();

    if (!mounted) return;

    setState(() {
      _userName = userName;
      _savedGroups = groups;
      _isLoading = false;
    });
  }

  Future<void> _openGroup(Group group) async {
    Group activeGroup = group;
    try {
      final fresh = await ApiService.getGroupById(group.id);
      activeGroup = fresh;
      await StorageService.saveGroup(fresh);
    } catch (_) {
      // Offline fallback
    }

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupDetailsScreen(group: activeGroup),
      ),
    );

    _loadData();
  }

  Future<void> _confirmRemoveGroup(Group group) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Remove Group"),
        content: Text(
          "Remove '${group.groupName}' from your saved groups on this device?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Remove"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.removeGroup(group.id);
      _loadData();
    }
  }

  void _copyGroupCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Group code '$code' copied to clipboard!"),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Splitter"),
        elevation: 0,
        centerTitle: true,
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: AppTheme.themeModeNotifier,
            builder: (context, mode, _) {
              final isCurrentlyDark = mode == ThemeMode.dark;
              return IconButton(
                icon: Icon(
                  isCurrentlyDark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                ),
                tooltip: isCurrentlyDark
                    ? "Switch to Light (Navy Blue)"
                    : "Switch to Dark (Turquoise)",
                onPressed: () => AppTheme.toggleTheme(),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Modern Hero Greeting Card
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [Color(0xFF111827), Color(0xFF1E293B)]
                        : const [Color(0xFF0F2042), Color(0xFF1E3A8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? const Color(0xFF14B8A6).withOpacity(0.12)
                          : const Color(0xFF0F2042).withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF14B8A6).withOpacity(0.2)
                                : Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_rounded,
                            color: isDark
                                ? const Color(0xFF2DD4BF)
                                : Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName != null && _userName!.isNotEmpty
                                    ? "Hello, $_userName"
                                    : "Welcome 👋",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Split bills & settle debts in real-time",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.groups_rounded,
                            size: 16,
                            color: isDark
                                ? const Color(0xFF2DD4BF)
                                : Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "${_savedGroups.length} active ${_savedGroups.length == 1 ? 'group' : 'groups'}",
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFF2DD4BF)
                                  : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action buttons row
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateGroupScreen(),
                          ),
                        );
                        _loadData();
                      },
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      label: const Text("Create Group"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const JoinGroupScreen(),
                          ),
                        );
                        _loadData();
                      },
                      icon: const Icon(Icons.login_rounded),
                      label: const Text("Join Group"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "My Groups",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  if (_savedGroups.isNotEmpty)
                    Text(
                      "${_savedGroups.length} groups",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_savedGroups.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 48,
                      horizontal: 24,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.group_work_outlined,
                          size: 64,
                          color: isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFFCBD5E1),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No Groups Yet",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Create a group for your trip, house, or dinner to start splitting expenses.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _savedGroups.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final group = _savedGroups[index];

                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => _openGroup(group),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: isDark
                                    ? const Color(0xFF14B8A6).withOpacity(0.18)
                                    : const Color(0xFF0F2042).withOpacity(0.08),
                                child: Text(
                                  group.groupName.isNotEmpty
                                      ? group.groupName[0].toUpperCase()
                                      : "G",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? const Color(0xFF2DD4BF)
                                        : const Color(0xFF0F2042),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      group.groupName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () =>
                                              _copyGroupCode(group.groupCode),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF0B0F19)
                                                  : const Color(0xFFF1F5F9),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: isDark
                                                    ? const Color(0xFF334155)
                                                    : const Color(0xFFE2E8F0),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  group.groupCode,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1.2,
                                                    color: isDark
                                                        ? const Color(
                                                            0xFF2DD4BF)
                                                        : const Color(
                                                            0xFF0F2042),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                  Icons.copy_rounded,
                                                  size: 11,
                                                  color: isDark
                                                      ? const Color(0xFF94A3B8)
                                                      : const Color(0xFF64748B),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "${group.members.length} ${group.members.length == 1 ? 'member' : 'members'}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.more_vert_rounded,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                                onSelected: (val) {
                                  if (val == "copy") {
                                    _copyGroupCode(group.groupCode);
                                  } else if (val == "remove") {
                                    _confirmRemoveGroup(group);
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(
                                    value: "copy",
                                    child: Row(
                                      children: [
                                        Icon(Icons.copy_rounded, size: 18),
                                        SizedBox(width: 8),
                                        Text("Copy Code"),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: "remove",
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline_rounded,
                                            size: 18, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text("Remove from list",
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
