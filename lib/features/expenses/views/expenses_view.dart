import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/expense_controller.dart';
import 'add_expense_view.dart';
import 'package:intl/intl.dart';

class ExpensesView extends StatelessWidget {
  const ExpensesView({super.key});

  @override
  Widget build(BuildContext context) {
    final ExpenseController expenseController = Get.put(ExpenseController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),
      body: Obx(() {
        if (expenseController.isLoading.value && expenseController.expenses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (expenseController.expenses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet_outlined, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('No expenses recorded', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Add your marketing, courier, and operational costs.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => const AddExpenseView()),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Expense'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: expenseController.fetchExpenses,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: expenseController.expenses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final expense = expenseController.expenses[index];

              IconData categoryIcon = Icons.money;
              if (expense.category == 'Advertising') categoryIcon = Icons.campaign_outlined;
              if (expense.category == 'Courier') categoryIcon = Icons.local_shipping_outlined;
              if (expense.category == 'Packaging') categoryIcon = Icons.inventory_2_outlined;
              if (expense.category == 'Salary') categoryIcon = Icons.people_outline;
              
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.error.withValues(alpha: 0.1),
                    child: Icon(categoryIcon, color: theme.colorScheme.error),
                  ),
                  title: Text(expense.category, style: theme.textTheme.titleMedium),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (expense.description != null && expense.description!.isNotEmpty)
                        Text(expense.description!, maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(DateFormat('MMM dd, yyyy').format(expense.date), 
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '৳${expense.amount.toStringAsFixed(0)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          Get.to(() => AddExpenseView(expense: expense));
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          Get.defaultDialog(
                            title: 'Delete Expense',
                            middleText: 'Are you sure you want to delete this expense?\nThis action cannot be undone.',
                            textConfirm: 'Delete',
                            textCancel: 'Cancel',
                            confirmTextColor: Colors.white,
                            buttonColor: Colors.red,
                            onConfirm: () {
                              Get.back();
                              expenseController.deleteExpense(expense.id);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  isThreeLine: expense.description != null && expense.description!.isNotEmpty,
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddExpenseView()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
