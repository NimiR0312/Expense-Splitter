import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';
import '../widgets/detail_tile.dart';
import 'add_expense_screen.dart';
import '../../groups/models/group_model.dart';

class ExpenseDetailsScreen extends StatefulWidget {
  final Expense expense;
  final Group group;

  const ExpenseDetailsScreen({
    super.key,
    required this.expense,
    required this.group,
  });

  @override
  State<ExpenseDetailsScreen> createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  late Expense expense;

  @override
  void initState() {
    super.initState();
    expense = widget.expense;
  }

  String get formattedAmount {
    return NumberFormat.currency(
      locale: "en_IN",
      symbol: "₹",
    ).format(expense.amount);
  }

  String get formattedDate {
    if (expense.createdAt == null) {
      return "-";
    }

    return DateFormat("dd MMM yyyy • hh:mm a").format(expense.createdAt!);
  }

  Future<void> _editExpense() async {
    final updatedExpense = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(group: widget.group, expense: expense),
      ),
    );

    bool _hasChanges = false;
    if (updatedExpense != null) {
      setState(() {
        expense = updatedExpense;
      });
      _hasChanges = true;
    }
  }

  Future<void> _deleteExpense() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Expense"),
        content: const Text("Are you sure you want to delete this expense?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await ExpenseService.deleteExpense(expense.id!);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result){
        if(!didPop) return;
      },
    child: Scaffold(
      appBar: AppBar(title: const Text("Expense Details")),
      

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      child: Icon(Icons.receipt_long, size: 36),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      expense.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      formattedAmount,
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            DetailTile(
              icon: Icons.person,
              title: "Paid By",
              child: Text(expense.paidBy),
            ),

            DetailTile(
              icon: Icons.group,
              title: "Split Between",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: expense.splitBetween
                    .map(
                      (member) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text("• $member"),
                      ),
                    )
                    .toList(),
              ),
            ),

            if (expense.notes.isNotEmpty)
              DetailTile(
                icon: Icons.notes,
                title: "Notes",
                child: Text(expense.notes),
              ),

            DetailTile(
              icon: Icons.calendar_today,
              title: "Created On",
              child: Text(formattedDate),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _editExpense,
                icon: const Icon(Icons.edit),
                label: const Text("Edit Expense"),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _deleteExpense,
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  "Delete Expense",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    )
    );
  }
}
