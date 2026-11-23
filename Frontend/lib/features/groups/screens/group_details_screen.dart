import 'package:flutter/material.dart';

import '../../../core/services/socket_service.dart';
import '../../../core/theme/app_theme.dart';
import '../models/group_model.dart';
import '../widgets/group_action_buttons.dart';
import '../widgets/group_info_card.dart';
import '../widgets/members_card.dart';
import '../../expenses/screens/add_expense_screen.dart';
import '../../expenses/screens/expense_list_screen.dart';
import '../../expenses/screens/settlement_screen.dart';

class GroupDetailsScreen extends StatefulWidget {
  final Group group;

  const GroupDetailsScreen({super.key, required this.group});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  late Group _currentGroup;

  @override
  void initState() {
    super.initState();
    _currentGroup = widget.group;
    _initSocket();
  }

  void _initSocket() {
    SocketService.instance.init();
    SocketService.instance.joinGroup(_currentGroup.id);
    SocketService.instance.on("member_joined", _onMemberJoined);
  }

  void _onMemberJoined(dynamic data) {
    if (!mounted || data == null) return;
    try {
      if (data["group"] != null) {
        final updatedGroup = Group.fromJson(data["group"]);
        final newMemberName = data["newMember"] ?? "A new member";
        setState(() {
          _currentGroup = updatedGroup;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$newMemberName joined the group! 🎉"),
            backgroundColor: Colors.teal.shade700,
          ),
        );
      }
    } catch (e) {
      print("[GroupDetailsScreen] Error handling member_joined event: $e");
    }
  }

  @override
  void dispose() {
    SocketService.instance.off("member_joined", _onMemberJoined);
    SocketService.instance.leaveGroup(_currentGroup.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Group Details"),
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            GroupInfoCard(group: _currentGroup),

            const SizedBox(height: 20),

            MembersCard(group: _currentGroup),

            const SizedBox(height: 20),

            GroupActionButtons(
              group: _currentGroup,
              onInviteMembers: () {
                // Navigate to Invite Members screen
              },
              onAddExpense: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddExpenseScreen(group: _currentGroup),
                  ),
                );

                if (result == true) {
                  // Refresh if needed
                }
              },
              onViewExpenses: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExpenseListScreen(group: _currentGroup),
                  ),
                );
              },
              onViewBalances: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettlementScreen(group: _currentGroup),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
