import 'package:flutter/material.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/theme/app_theme.dart';
import 'expense_details_screen.dart';
import '../../groups/models/group_model.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';
import '../widgets/expense_card.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  final Group group;

  const ExpenseListScreen({super.key, required this.group});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List<Expense> _expenses = [];

  bool _isLoading = true;

  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
    _initSocket();
  }

  void _initSocket() {
    SocketService.instance.init();
    SocketService.instance.joinGroup(widget.group.id);
    SocketService.instance.on("expense_created", _onSocketEvent);
    SocketService.instance.on("expense_updated", _onSocketEvent);
    SocketService.instance.on("expense_deleted", _onSocketEvent);
    SocketService.instance.on("settlement_recorded", _onSocketEvent);
  }

  void _onSocketEvent(dynamic data) {
    if (mounted) {
      _loadExpenses();
    }
  }

  @override
  void dispose() {
    SocketService.instance.off("expense_created", _onSocketEvent);
    SocketService.instance.off("expense_updated", _onSocketEvent);
    SocketService.instance.off("expense_deleted", _onSocketEvent);
    SocketService.instance.off("settlement_recorded", _onSocketEvent);
    SocketService.instance.leaveGroup(widget.group.id);
    super.dispose();
  }

  Future<void> _loadExpenses() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final expenses = await ExpenseService.getExpenses(widget.group.id);

      if (!mounted) return;

      setState(() {
        _expenses = expenses;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openAddExpense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddExpenseScreen(group: widget.group)),
    );

    if (result == true) {
      _loadExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.groupName),
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

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddExpense,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          "Add Expense",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _loadExpenses,

        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 70,
                        color: Colors.red,
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Something went wrong",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(_error!, textAlign: TextAlign.center),

                      const SizedBox(height: 25),

                      ElevatedButton(
                        onPressed: _loadExpenses,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              )
            : _expenses.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 150),

                  Icon(Icons.receipt_long, size: 90, color: Colors.grey),

                  SizedBox(height: 20),

                  Center(
                    child: Text(
                      "No expenses yet",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  Center(child: Text("Tap + to add your first expense")),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 90),
                itemCount: _expenses.length,
                itemBuilder: (context, index) {
                  final expense = _expenses[index];

                  return ExpenseCard(
                    expense: expense,

                    onTap: () async {
                      // Expense Details Screen
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExpenseDetailsScreen(
                            expense: expense,
                            group: widget.group,
                          ),
                        ),
                      );
                      if (result == true) {
                        _loadExpenses();
                      }
                    },

                    onEdit: () async {
                      // Edit Expense
                      final updatedExpense = await Navigator.push<Expense>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddExpenseScreen(
                            group: widget.group,
                            expense: expense,
                          ),
                        ),
                      );
                      if (updatedExpense != null) {
                        _loadExpenses();
                      }
                    },

                    onDelete: () async {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Delete Expense"),
                          content: const Text(
                            "Are you sure you want to delete this expense?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                              child: const Text("Cancel"),
                            ),

                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );

                      if (shouldDelete != true) {
                        return;
                      }

                      try {
                        await ExpenseService.deleteExpense(expense.id!);

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Expense deleted successfully"),
                          ),
                        );

                        _loadExpenses();
                      } catch (e) {
                        if (!mounted) return;

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                  );
                },
              ),
      ),
    );
  }
}
