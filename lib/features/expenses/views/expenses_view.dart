import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/expense_controller.dart';
import 'add_expense_view.dart';
import '../../onboarding/controllers/business_controller.dart';
import '../../../core/widgets/animated_ui_elements.dart';

class ExpensesView extends StatefulWidget {
  const ExpensesView({super.key});

  @override
  State<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<ExpensesView> {
  final ExpenseController _expenseController = Get.put(ExpenseController());
  final BusinessController _businessController = Get.find<BusinessController>();

  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Operating Expenses',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.4),
        ),
      ),
      body: Obx(() {
        if (_expenseController.isLoading.value && _expenseController.expenses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_expenseController.expenses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isLight ? const Color(0xFFF1F5F9) : Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.receipt_long_rounded, size: 64, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 20),
                Text('No expenses recorded', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                  'Track advertising, courier, and operational costs to see real net profit.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => const AddExpenseView()),
                  icon: const Icon(Icons.add),
                  label: const Text('Add First Expense'),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms).scale(),
          );
        }

        final allExpenses = _expenseController.expenses;
        final filteredExpenses = allExpenses.where((e) {
          if (_selectedCategory == 'All') return true;
          return e.category.toLowerCase() == _selectedCategory.toLowerCase();
        }).toList();

        double totalFilteredAmount = 0;
        for (var e in filteredExpenses) {
          totalFilteredAmount += e.amount;
        }

        return RefreshIndicator(
          onRefresh: _expenseController.fetchExpenses,
          child: Column(
            children: [
              // Category filter pills & Total Summary
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryPill('All', allExpenses.length),
                          _buildCategoryPill('Advertising', allExpenses.where((e) => e.category == 'Advertising').length),
                          _buildCategoryPill('Courier', allExpenses.where((e) => e.category == 'Courier').length),
                          _buildCategoryPill('Packaging', allExpenses.where((e) => e.category == 'Packaging').length),
                          _buildCategoryPill('Salary', allExpenses.where((e) => e.category == 'Salary').length),
                          _buildCategoryPill('Other', allExpenses.where((e) => e.category != 'Advertising' && e.category != 'Courier' && e.category != 'Packaging' && e.category != 'Salary').length),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Total Expense Summary Ribbon
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isLight ? Colors.white : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isLight ? const Color(0xFFD8DEE6) : Colors.white12,
                          width: 1.2,
                        ),
                        boxShadow: isLight
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD97706).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.account_balance_wallet_outlined, size: 16, color: Color(0xFFD97706)),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Total in $_selectedCategory',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isLight ? const Color(0xFF64748B) : Colors.white60,
                                ),
                              ),
                            ],
                          ),
                          AnimatedCounter(
                            value: totalFilteredAmount,
                            prefix: _businessController.currencySymbol,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                              letterSpacing: -0.4,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Expense List
              Expanded(
                child: filteredExpenses.isEmpty
                    ? Center(
                        child: Text(
                          'No expenses under $_selectedCategory',
                          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final isDesktop = constraints.maxWidth >= 800;

                          if (isDesktop) {
                            return GridView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: constraints.maxWidth >= 1200 ? 3 : 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                mainAxisExtent: 130,
                              ),
                              itemCount: filteredExpenses.length,
                              itemBuilder: (context, index) {
                                return _buildExpenseCard(
                                  context: context,
                                  expense: filteredExpenses[index],
                                  expenseController: _expenseController,
                                  businessController: _businessController,
                                  theme: theme,
                                  index: index,
                                );
                              },
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            itemCount: filteredExpenses.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _buildExpenseCard(
                                context: context,
                                expense: filteredExpenses[index],
                                expenseController: _expenseController,
                                businessController: _businessController,
                                theme: theme,
                                index: index,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const AddExpenseView()),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  Widget _buildCategoryPill(String label, int count) {
    final isSelected = _selectedCategory.toLowerCase() == label.toLowerCase();
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = label),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : (isLight ? Colors.white : theme.colorScheme.surface),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : (isLight ? const Color(0xFFD8DEE6) : Colors.white12),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white24 : (isLight ? const Color(0xFFF1F5F9) : Colors.white12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected ? Colors.white : (isLight ? const Color(0xFF64748B) : Colors.white70),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseCard({
    required BuildContext context,
    required dynamic expense,
    required ExpenseController expenseController,
    required BusinessController businessController,
    required ThemeData theme,
    required int index,
  }) {
    final isLight = theme.brightness == Brightness.light;

    IconData categoryIcon = Icons.receipt_long;
    Color iconColor = const Color(0xFF7C3AED);

    if (expense.category == 'Advertising') {
      categoryIcon = Icons.campaign_rounded;
      iconColor = const Color(0xFF2563EB);
    } else if (expense.category == 'Courier') {
      categoryIcon = Icons.local_shipping_rounded;
      iconColor = const Color(0xFFD97706);
    } else if (expense.category == 'Packaging') {
      categoryIcon = Icons.inventory_2_rounded;
      iconColor = const Color(0xFF059669);
    } else if (expense.category == 'Salary') {
      categoryIcon = Icons.people_alt_rounded;
      iconColor = const Color(0xFF9333EA);
    }

    return HoverableCard(
      padding: const EdgeInsets.all(14.0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isLight ? 0.12 : 0.22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(categoryIcon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  expense.category,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: -0.2),
                ),
                const SizedBox(height: 2),
                if (expense.description != null && expense.description!.isNotEmpty)
                  Text(
                    expense.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isLight ? const Color(0xFF475569) : Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  DateFormat('MMM dd, yyyy').format(expense.date),
                  style: TextStyle(
                    fontSize: 11,
                    color: isLight ? const Color(0xFF94A3B8) : Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${businessController.currencySymbol}${expense.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  letterSpacing: -0.4,
                  color: Color(0xFFDC2626),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Edit Expense',
                    style: IconButton.styleFrom(
                      backgroundColor: isLight ? const Color(0xFFF1F5F9) : Colors.white10,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.blue),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: () => Get.to(() => AddExpenseView(expense: expense)),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    tooltip: 'Delete Expense',
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626).withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFDC2626)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          title: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.delete_outline, color: Color(0xFFDC2626), size: 22),
                              ),
                              const SizedBox(width: 12),
                              const Text('Delete Expense'),
                            ],
                          ),
                          content: const Text(
                            'Are you sure you want to delete this expense?\nThis cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: isLight ? const Color(0xFFF1F5F9) : Colors.white10,
                                foregroundColor: isLight ? const Color(0xFF475569) : Colors.white70,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: isLight ? const BorderSide(color: Color(0xFFE2E8F0)) : BorderSide.none,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                              onPressed: () => Get.back(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Get.back();
                                expenseController.deleteExpense(expense.id);
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 40).ms, duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}
