import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/group_model.dart';

class GroupActionButtons extends StatelessWidget {
  final Group group;
  final VoidCallback onInviteMembers;
  final VoidCallback onAddExpense;
  final VoidCallback onViewExpenses;
  final VoidCallback onViewBalances;

  const GroupActionButtons({
    super.key,
    required this.group,
    required this.onInviteMembers,
    required this.onAddExpense,
    required this.onViewExpenses,
    required this.onViewBalances,
  });

  void _showInviteDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.share_rounded, size: 24),
            SizedBox(width: 10),
            Text("Invite to Group"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Share this 6-character code with your friends to let them join this group.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Text(
                group.groupCode,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy_rounded),
                label: const Text("Copy Group Code"),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: group.groupCode));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Group code '${group.groupCode}' copied!"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                title: "Add Expense",
                subtitle: "Record payment",
                icon: Icons.add_card_rounded,
                isPrimary: true,
                onTap: onAddExpense,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionTile(
                title: "Expenses",
                subtitle: "View all history",
                icon: Icons.receipt_long_rounded,
                isPrimary: false,
                onTap: onViewExpenses,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                title: "Balances",
                subtitle: "Settle debts",
                icon: Icons.account_balance_wallet_rounded,
                isPrimary: false,
                onTap: onViewBalances,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionTile(
                title: "Invite Code",
                subtitle: "Add members",
                icon: Icons.qr_code_2_rounded,
                isPrimary: false,
                onTap: () => _showInviteDialog(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isPrimary
                ? primaryColor
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPrimary
                  ? primaryColor
                  : (isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0)),
              width: 1,
            ),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? onPrimary.withOpacity(0.18)
                      : primaryColor.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isPrimary ? onPrimary : primaryColor,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isPrimary
                      ? onPrimary
                      : (isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isPrimary
                      ? onPrimary.withOpacity(0.8)
                      : (isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
