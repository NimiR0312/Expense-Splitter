import 'package:flutter/material.dart';
import '../models/member_model.dart';

class MemberTile extends StatelessWidget {
  final Member member;

  const MemberTile({
    super.key,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: primaryColor.withOpacity(isDark ? 0.2 : 0.1),
        child: Text(
          member.name.isNotEmpty ? member.name[0].toUpperCase() : "?",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ),
      title: Text(
        member.name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
      ),
      subtitle: Text(
        member.isAdmin ? "Group Admin" : "Member",
        style: TextStyle(
          fontSize: 12,
          color: member.isAdmin
              ? (isDark ? const Color(0xFFFBBF24) : Colors.amber.shade800)
              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          fontWeight: member.isAdmin ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: member.isAdmin
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: isDark ? const Color(0xFFFBBF24) : Colors.amber.shade800,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Admin",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFFBBF24) : Colors.amber.shade800,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
