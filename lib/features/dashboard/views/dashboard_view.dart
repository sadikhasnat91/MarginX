import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

import '../../products/views/products_view.dart';
import '../../orders/views/orders_view.dart';
import '../../orders/views/add_order_view.dart';
import '../../expenses/views/expenses_view.dart';
import '../../expenses/views/add_expense_view.dart';
import '../../../core/services/profit_calculation_service.dart';
import '../../orders/controllers/order_controller.dart';
import '../../expenses/controllers/expense_controller.dart';
import '../../products/controllers/product_controller.dart';
import '../../onboarding/controllers/business_controller.dart';
import 'dart:convert';

import '../../insights/views/insights_view.dart';
import '../../settings/views/settings_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const _DashboardHomeView(),
    const ProductsView(),
    const OrdersView(),
    const ExpensesView(),
    const InsightsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Expenses'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Insights'),
        ],
      ),
    );
  }
}

class _DashboardHomeView extends StatefulWidget {
  const _DashboardHomeView();

  @override
  State<_DashboardHomeView> createState() => _DashboardHomeViewState();
}

class _DashboardHomeViewState extends State<_DashboardHomeView> {
  final ProfitCalculationService _profitService = Get.put(ProfitCalculationService());
  final ProductController _productController = Get.put(ProductController());
  final OrderController _orderController = Get.put(OrderController());
  final ExpenseController _expenseController = Get.put(ExpenseController());

  @override
  void initState() {
    super.initState();
    // Service auto-calculates on init now
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 15) {
      return 'Good Noon';
    } else if (hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final BusinessController businessController = Get.find<BusinessController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final business = businessController.currentBusiness.value;
          return Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                backgroundImage: business?.logoUrl != null && business!.logoUrl!.isNotEmpty 
                    ? (business.logoUrl!.startsWith('data:image') 
                        ? MemoryImage(base64Decode(business.logoUrl!.split(',').last)) as ImageProvider
                        : NetworkImage(business.logoUrl!))
                    : null,
                child: business?.logoUrl == null || business!.logoUrl!.isEmpty 
                    ? Icon(Icons.store, size: 18, color: theme.colorScheme.primary) 
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()},',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                    Text(
                      business?.name ?? 'Business Owner',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: DropdownButtonHideUnderline(
                child: Obx(() => DropdownButton<String>(
                  value: _profitService.dateFilter.value,
                  icon: const Icon(Icons.arrow_drop_down, size: 20),
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                  items: const [
                    DropdownMenuItem(value: 'Today', child: Text('Today')),
                    DropdownMenuItem(value: 'Yesterday', child: Text('Yesterday')),
                    DropdownMenuItem(value: 'This Month', child: Text('This Month')),
                    DropdownMenuItem(value: 'All Time', child: Text('All Time')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _profitService.dateFilter.value = value;
                    }
                  },
                )),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Get.to(() => const SettingsView());
            },
          )
        ],
      ),
      body: Obx(() {
        final revenue = _profitService.totalRevenue.value;
        final collected = _profitService.totalCollectedRevenue.value;
        final profit = _profitService.totalRealProfit.value;
        final margin = _profitService.profitMargin.value;
        final returnLoss = _profitService.totalReturnLoss.value;
        final expenses = _profitService.totalExpenses.value;
        final totalOrders = _profitService.totalOrdersCount.value;
        
        return RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              _orderController.fetchOrders(),
              _expenseController.fetchExpenses(),
            ]);
            _profitService.recalculate();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profit Card (Premium Gradient)
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'REAL PROFIT',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: Colors.white70,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: margin >= 0 ? Colors.greenAccent.withValues(alpha: 0.2) : Colors.redAccent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: margin >= 0 ? Colors.greenAccent.withValues(alpha: 0.5) : Colors.redAccent.withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                '${margin > 0 ? "+" : ""}${margin.toStringAsFixed(1)}% Margin',
                                style: TextStyle(
                                  color: margin >= 0 ? Colors.greenAccent : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '৳${profit.toStringAsFixed(0)}',
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 56, // Increased from default for better visibility
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Quick Actions
                Text('Quick Actions', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildQuickAction(context, 'Add Order', Icons.add_shopping_cart, Colors.blue, () {
                      Get.to(() => const AddOrderView()); // Needs import update if not present
                    }),
                    const SizedBox(width: 12),
                    _buildQuickAction(context, 'Add Expense', Icons.receipt_long, Colors.purple, () {
                      Get.to(() => const AddExpenseView()); // Needs import update if not present
                    }),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // 2x2 Metrics Grid
                Text('Performance Overview', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.4,
                  children: [
                    _buildMetricCard(context, 'Collected', '৳${collected.toStringAsFixed(0)}', Icons.account_balance_wallet, Colors.green),
                    _buildMetricCard(context, 'Total Orders', '$totalOrders', Icons.inventory_2, Colors.blue),
                    _buildMetricCard(context, 'Expenses', '৳${expenses.toStringAsFixed(0)}', Icons.money_off, Colors.orange),
                    _buildMetricCard(context, 'Return Losses', '৳${returnLoss.toStringAsFixed(0)}', Icons.assignment_return, Colors.red),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Warnings / Leaks Row
                if (returnLoss > 0)
                  Card(
                    elevation: 0,
                    color: Colors.red.withValues(alpha: 0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.warning_amber_rounded, color: Colors.red[600], size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Profit Leak Detected', style: theme.textTheme.titleSmall?.copyWith(color: Colors.red[700], fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text('Return/RTO costs have eaten ৳${returnLoss.toStringAsFixed(0)} of your revenue.', style: theme.textTheme.bodySmall?.copyWith(color: Colors.red[900])),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQuickAction(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color iconColor) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: iconColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title, 
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7), 
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value, 
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900, 
                  fontSize: 26,
                  letterSpacing: -0.5,
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
