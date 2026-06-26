import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../auth/presentation/auth_controller.dart';
import '../domain/entities/expense.dart';
import 'expenses_controller.dart';
import '../../../core/constants/app_routes.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  late final ExpensesController controller;
  late final AuthController authController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ExpensesController());
    authController = Get.find<AuthController>();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      controller.subscribe(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notes),
            tooltip: 'Notes',
            onPressed: () {
              Get.toNamed(AppRoutes.notes);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authController.signOut();
              Get.offAllNamed(AppRoutes.login);
            },
          ),
        ],
      ),
      body: Obx(() {
        final expenses = controller.expenses;
        final totalMonth = controller.totalThisMonth;
        final totalToday = controller.totalToday;
        final predicted = controller.predictedMonthEnd;
        final budget = 30000.0;
        final remaining = budget - totalMonth;
        final comparison = controller.weeklyComparisonPercent;

        return RefreshIndicator(
          onRefresh: () async {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) controller.subscribe(user.uid);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Welcome ${authController.displayName.value ?? 'User'}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildStatCard('Spent Today', '₹${totalToday.toStringAsFixed(0)}'),
                  _buildStatCard('This Month', '₹${totalMonth.toStringAsFixed(0)}'),
                  _buildStatCard('Budget', '₹${budget.toStringAsFixed(0)}'),
                  _buildStatCard('Remaining', '₹${remaining.toStringAsFixed(0)}'),
                ],
              ),
              const SizedBox(height: 18),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text('Top category: ${controller.topCategory}'),
                      const SizedBox(height: 6),
                      Text('Top merchant: ${controller.topMerchant}'),
                      const SizedBox(height: 6),
                      Text('Predicted month end: ₹${predicted.toStringAsFixed(0)}'),
                      const SizedBox(height: 6),
                      Text('Weekly change: ${comparison >= 0 ? '+' : ''}${comparison.toStringAsFixed(1)}%'),
                      const SizedBox(height: 6),
                      Text('Spending score: ${controller.spendingScore}/100'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (expenses.isEmpty)
                Column(
                  children: [
                    const SizedBox(height: 40),
                    const Icon(Icons.account_balance_wallet_outlined, size: 96, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text('No expenses yet', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    const Text('Add your first expense and the wallet will generate insights automatically.'),
                  ],
                )
              else ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final Expense expense = expenses[index];
                    return Card(
                      child: ListTile(
                        title: Text('${expense.merchant} • ${expense.category}'),
                        subtitle: Text('${expense.paymentMode} • ${expense.note.isEmpty ? 'No note' : expense.note}'),
                        trailing: Text('₹${expense.amount.toStringAsFixed(0)}'),
                        onTap: () {
                          Get.toNamed(AppRoutes.expense, arguments: expense);
                        },
                        onLongPress: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Delete expense'),
                              content: const Text('Delete this expense?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await controller.deleteExpense(expense.id);
                          }
                        },
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 90),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(AppRoutes.expense);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
