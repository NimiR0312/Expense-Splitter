import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/expense_model.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  IconData _getExpenseIcon() {
    if (expense.isSettlement) {
      return Icons.handshake_rounded;
    }

    final title = expense.title.toLowerCase();

    if (title.contains("food") ||
        title.contains("dinner") ||
        title.contains("lunch") ||
        title.contains("breakfast") ||
        title.contains("burger") ||
        title.contains("pizza")) {
      return Icons.restaurant_rounded;
    }

    if (title.contains("coffee") || title.contains("tea")) {
      return Icons.coffee_rounded;
    }

    if (title.contains("taxi") ||
        title.contains("uber") ||
        title.contains("ola") ||
        title.contains("cab")) {
      return Icons.local_taxi_rounded;
    }

    if (title.contains("fuel") ||
        title.contains("petrol") ||
        title.contains("diesel")) {
      return Icons.local_gas_station_rounded;
    }

    if (title.contains("hotel") ||
        title.contains("stay") ||
        title.contains("room")) {
      return Icons.hotel_rounded;
    }

    if (title.contains("flight") || title.contains("air")) {
      return Icons.flight_rounded;
    }

    if (title.contains("movie") || title.contains("cinema")) {
      return Icons.movie_rounded;
    }

    if (title.contains("shopping") ||
        title.contains("groceries") ||
        title.contains("grocery")) {
      return Icons.shopping_bag_rounded;
    }

    return Icons.receipt_long_rounded;
  }

  String _formatDate() {
    if (expense.createdAt == null) return "";

    return DateFormat("dd MMM yyyy • hh:mm a").format(expense.createdAt!);
  }

  String _formatAmount() {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    return formatter.format(expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final amountColor =
        expense.isSettlement ? primaryColor : const Color(0xFF10B981);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header Row
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: expense.isSettlement
                          ? primaryColor.withOpacity(isDark ? 0.25 : 0.12)
                          : (isDark
                              ? const Color(0xFF059669).withOpacity(0.2)
                              : const Color(0xFF10B981).withOpacity(0.12)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _getExpenseIcon(),
                      color: expense.isSettlement
                          ? primaryColor
                          : (isDark
                              ? const Color(0xFF34D399)
                              : const Color(0xFF059669)),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                expense.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (expense.isSettlement) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "Settlement",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "Paid by ${expense.paidBy}",
                          style: TextStyle(
                            fontSize: 13,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatAmount(),
                    style: TextStyle(
                      fontSize: 17,
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              /// Split Members chips
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.groups_rounded,
                    size: 16,
                    color: subtitleColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      expense.splitBetween.join(" • "),
                      style: TextStyle(
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if (expense.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 16,
                      color: subtitleColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        expense.notes,
                        style: TextStyle(
                          fontSize: 12,
                          color: subtitleColor,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 4),

              /// Footer: Date and Action Buttons
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: subtitleColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _formatDate(),
                      style: TextStyle(
                        fontSize: 11,
                        color: subtitleColor,
                      ),
                    ),
                  ),
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      tooltip: "Edit Expense",
                      onPressed: onEdit,
                      visualDensity: VisualDensity.compact,
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 18, color: Colors.red),
                      tooltip: "Delete Expense",
                      onPressed: onDelete,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
