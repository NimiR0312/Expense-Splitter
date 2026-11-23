import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/services/socket_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../groups/models/group_model.dart';
import '../models/balance_model.dart';
import '../services/expense_service.dart';

class SettlementScreen extends StatefulWidget {
  final Group group;

  const SettlementScreen({super.key, required this.group});

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  GroupBalancesResponse? _balancesData;
  bool _isLoading = true;
  String? _error;

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _loadBalances();
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
      _loadBalances();
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

  Future<void> _loadBalances() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final data = await ExpenseService.getGroupBalances(widget.group.id);

      if (!mounted) return;
      setState(() {
        _balancesData = data;
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

  void _showSettleUpDialog({
    required String defaultFrom,
    required String defaultTo,
    required double defaultAmount,
  }) {
    final amountController =
        TextEditingController(text: defaultAmount.toStringAsFixed(2));
    final notesController =
        TextEditingController(text: "Settlement: $defaultFrom paid $defaultTo");
    String selectedFrom = defaultFrom;
    String selectedTo = defaultTo;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final memberNames =
                widget.group.members.map((m) => m.name).toList();

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Record Payment",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Payer dropdown
                  DropdownButtonFormField<String>(
                    value: selectedFrom,
                    decoration: const InputDecoration(
                      labelText: "Who paid?",
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    items: memberNames.map((name) {
                      return DropdownMenuItem(value: name, child: Text(name));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedFrom = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Payee dropdown
                  DropdownButtonFormField<String>(
                    value: selectedTo,
                    decoration: const InputDecoration(
                      labelText: "Paid to whom?",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    items: memberNames.map((name) {
                      return DropdownMenuItem(value: name, child: Text(name));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedTo = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Amount
                  TextField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: "Amount (₹)",
                      prefixIcon: Icon(Icons.currency_rupee),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Notes
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: "Notes (Optional)",
                      prefixIcon: Icon(Icons.note_alt_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final parsedAmount =
                                double.tryParse(amountController.text.trim());
                            if (parsedAmount == null || parsedAmount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Please enter a valid amount"),
                                ),
                              );
                              return;
                            }

                            if (selectedFrom == selectedTo) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Payer and payee cannot be the same person"),
                                ),
                              );
                              return;
                            }

                            setModalState(() {
                              isSubmitting = true;
                            });

                            try {
                              await ExpenseService.settleDebt(
                                groupId: widget.group.id,
                                from: selectedFrom,
                                to: selectedTo,
                                amount: parsedAmount,
                                notes: notesController.text.trim(),
                              );

                              if (!mounted) return;
                              Navigator.pop(bottomSheetContext);

                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.green.shade700,
                                  content: Text(
                                    "Recorded payment of ${_currencyFormat.format(parsedAmount)} from $selectedFrom to $selectedTo",
                                  ),
                                ),
                              );

                              _loadBalances();
                            } catch (e) {
                              setModalState(() {
                                isSubmitting = false;
                              });
                              if (!mounted) return;
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            "Confirm & Settle Up",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryCard(double totalSpending) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF111827), Color(0xFF1E293B)]
              : const [Color(0xFF0F2042), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFF14B8A6).withOpacity(0.12)
                : const Color(0xFF0F2042).withOpacity(0.2),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF14B8A6).withOpacity(0.2)
                  : Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 30,
              color: isDark ? const Color(0xFF2DD4BF) : Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Group Spending",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currencyFormat.format(totalSpending),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementsSection(List<SettlementSuggestion> settlements) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Suggested Settlements",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${settlements.length} pending",
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (settlements.isEmpty)
          Card(
            color: isDark
                ? const Color(0xFF064E3B).withOpacity(0.3)
                : const Color(0xFFECFDF5),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF10B981), size: 26),
                  const SizedBox(width: 10),
                  Text(
                    "All debts are settled up! 🎉",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? const Color(0xFF34D399)
                          : const Color(0xFF065F46),
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
            itemCount: settlements.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = settlements[index];

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isDark
                            ? const Color(0xFF7F1D1D).withOpacity(0.5)
                            : const Color(0xFFFEE2E2),
                        child: Text(
                          item.from.isNotEmpty
                              ? item.from[0].toUpperCase()
                              : "?",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFFFCA5A5)
                                : const Color(0xFF991B1B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: item.from,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: " owes ",
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                  TextSpan(
                                    text: item.to,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currencyFormat.format(item.amount),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _showSettleUpDialog(
                            defaultFrom: item.from,
                            defaultTo: item.to,
                            defaultAmount: item.amount,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Settle"),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildBalancesSection(List<MemberBalance> balances) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Member Net Balances",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: balances.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final member = balances[index];
            final isPositive = member.netBalance > 0.009;
            final isNegative = member.netBalance < -0.009;

            Color statusColor =
                isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
            String statusText = "Settled";
            IconData statusIcon = Icons.check_circle_outline_rounded;

            if (isPositive) {
              statusColor = isDark
                  ? const Color(0xFF34D399)
                  : const Color(0xFF059669);
              statusText =
                  "gets back ${_currencyFormat.format(member.netBalance)}";
              statusIcon = Icons.arrow_downward_rounded;
            } else if (isNegative) {
              statusColor = isDark
                  ? const Color(0xFFF87171)
                  : const Color(0xFFDC2626);
              statusText =
                  "owes ${_currencyFormat.format(member.netBalance.abs())}";
              statusIcon = Icons.arrow_upward_rounded;
            }

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: statusColor.withOpacity(isDark ? 0.2 : 0.1),
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                title: Text(
                  member.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                subtitle: Text(
                  "Paid: ${_currencyFormat.format(member.totalPaid)} • Share: ${_currencyFormat.format(member.totalOwed)}",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                trailing: Text(
                  statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final members = widget.group.members;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Balances & Settlements"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadBalances,
            tooltip: "Refresh Balances",
          ),
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
        onPressed: members.length < 2
            ? null
            : () {
                _showSettleUpDialog(
                  defaultFrom: members.first.name,
                  defaultTo: members.length > 1
                      ? members[1].name
                      : members.first.name,
                  defaultAmount: 0.0,
                );
              },
        icon: const Icon(Icons.payment),
        label: const Text("Record Payment"),
      ),
      body: RefreshIndicator(
        onRefresh: _loadBalances,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 60, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadBalances,
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: 80,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCard(_balancesData!.totalGroupSpending),
                        const SizedBox(height: 24),
                        _buildSettlementsSection(_balancesData!.settlements),
                        const SizedBox(height: 24),
                        _buildBalancesSection(_balancesData!.balances),
                      ],
                    ),
                  ),
      ),
    );
  }
}
