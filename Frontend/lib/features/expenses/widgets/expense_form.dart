import 'package:flutter/material.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../groups/models/group_model.dart';
import '../services/expense_service.dart';
import '../models/expense_model.dart';

class ExpenseForm extends StatefulWidget {
  final Group group;
  final Expense? expense;

  const ExpenseForm({
    super.key,
    required this.group,
    this.expense,
  });

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedPaidBy;

  final List<String> _selectedMembers = [];

  bool _isLoading = false;

  bool get isEditing => widget.expense != null;

  @override
void initState() {
  super.initState();

  if (isEditing) {
    final expense = widget.expense!;

    _titleController.text = expense.title;
    _amountController.text = expense.amount.toString();
    _notesController.text = expense.notes;

    _selectedPaidBy = expense.paidBy;

    _selectedMembers.addAll(expense.splitBetween);
  } else {
    if (widget.group.members.isNotEmpty) {
      _selectedPaidBy = widget.group.members.first.name;
    }
  }
}

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool _validateSelections() {
  if (_selectedPaidBy == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Please select who paid.",
        ),
      ),
    );
    return false;
  }

  if (_selectedMembers.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Select at least one member.",
        ),
      ),
    );
    return false;
  }

  return true;
}

Expense _buildExpense() {
  return Expense(
    id: isEditing ? widget.expense!.id : null,
    title: _titleController.text.trim(),
    amount: double.parse(
      _amountController.text.trim(),
    ),
    paidBy: _selectedPaidBy!,
    splitBetween: List.from(
      _selectedMembers,
    ),
    notes: _notesController.text.trim(),
    groupId: widget.group.id,
    createdAt: isEditing
        ? widget.expense!.createdAt
        : null,
  );
}

Future<void> _createExpense(
  Expense expense,
) async {

final createdExpense = await ExpenseService.addExpense(
    expense: expense,
  );

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        "Expense added successfully",
      ),
    ),
  );

  Navigator.pop(
    context,
    createdExpense,
  );
}

Future<void> _updateExpense(
  Expense expense,
) async {

  final updatedExpense =
      await ExpenseService.updateExpense(
    expenseId: expense.id!,
    expense: expense,
  );

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        "Expense updated successfully",
      ),
    ),
  );

  Navigator.pop(
    context,
    updatedExpense,
  );
}

  Future<void> _saveExpense() async {

  if (!_formKey.currentState!.validate()) {
    return;
  }

  if (!_validateSelections()) {
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    debugPrint("GROUP ID: ${widget.group.id}");
    debugPrint("GROUP NAME: ${widget.group.groupName}");
    debugPrint("GROUP CODE: ${widget.group.groupCode}");
    final expense = _buildExpense();

    if (isEditing) {
      await _updateExpense(
        expense,
      );
    } else {
      await _createExpense(
        expense,
      );
    }

  } catch (e) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.toString(),
        ),
      ),
    );

  } finally {

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Text(
              isEditing
                  ? "Edit Expense"
                  : "Add New Expense",
              style: Theme.of(context)
    .textTheme
    .headlineSmall
    ?.copyWith(
      fontWeight: FontWeight.bold,
    ),
        ),

            const SizedBox(height: 30),

            AppTextField(
              controller: _titleController,
              hintText: "Dinner",
              labelText: "Expense Title",
              prefixIcon: Icons.receipt_long,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter an expense title";
                }

                return null;
              },
            ),

            const SizedBox(height: 20),

            AppTextField(
              controller: _amountController,
              hintText: "1200",
              labelText: "Amount",
              prefixIcon: Icons.currency_rupee,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter the amount";
                }

                final amount = double.tryParse(value);

                if (amount == null) {
                  return "Enter a valid amount";
                }

                if (amount <= 0) {
                  return "Amount must be greater than zero";
                }

                return null;
              },
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _selectedPaidBy,
              decoration: InputDecoration(
                labelText: "Paid By",
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                ),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                ),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: widget.group.members
                  .map(
                    (member) => DropdownMenuItem<String>(
                      value: member.name,
                      child: Text(member.name),
                    ),
                  )
                  .toList(),

              onChanged: (value) {
                setState(() {
                  _selectedPaidBy = value;
                });
              },

              validator: (value) {
                if (value == null) {
                  return "Please select who paid";
                }

                return null;
              },
            ),

            const SizedBox(height: 20),

            AppTextField(
              controller: _notesController,
              hintText: "Optional notes",
              labelText: "Notes",
              prefixIcon: Icons.notes,
              maxLines: 3,
            ),

            const SizedBox(height: 30),

            const Text(
              "Split Between",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),
                        ...widget.group.members.map(
              (member) {
                final isSelected = _selectedMembers.contains(member.name);
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                child: CheckboxListTile(
                  value: isSelected,
                  title: Text(member.name),
                  subtitle: member.isAdmin
                      ? const Text("Admin")
                      : null,
                  controlAffinity:
                      ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        if(!_selectedMembers.contains(member.name)) {
                          _selectedMembers.add(member.name);
                        }
                      } else {
                        _selectedMembers.remove(member.name);
                      }
                    });
                  },
                ),
              );
            },
          ).toList(),

            const SizedBox(height: 30),

            AppButton(
              text: isEditing ? "Update Expense" : "Save Expense",
              icon: isEditing ? Icons.edit : Icons.save,
              isLoading: _isLoading,
              onPressed: _saveExpense,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}