import 'package:flutter/material.dart';

import '../../groups/models/group_model.dart';
import '../models/expense_model.dart';
import '../widgets/expense_form.dart';

class AddExpenseScreen extends StatelessWidget {
  final Group group;
  final Expense? expense;

  const AddExpenseScreen({
    super.key,
    required this.group,
    this.expense,
  });

  bool get isEditing => expense != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? "Edit Expense"
              : "Add Expense",
        ),
      ),

      body: ExpenseForm(
        group: group,
        expense: expense,
      ),
    );
  }
}