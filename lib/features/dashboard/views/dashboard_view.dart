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
import '../../../core/theme/app_theme.dart';
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
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;
    final bool isWideDesktop = MediaQuery.of(context).size.width >= 1100;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: isWideDesktop,
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundColor: Theme.of(context).colorScheme.surface,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        width: isWideDesktop ? 180 : 56,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
                NavigationRailDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: Text('Products')),
                NavigationRailDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag), label: Text('Orders')),
                NavigationRailDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: Text('Expenses')),
                NavigationRailDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: Text('Insights')),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
            ),
          ],
        ),
      );
    }

    // Mobile layout
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(() {
          final business = businessController.currentBusiness.value;
          return Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.15),
                backgroundImage: business?.logoUrl != null && business!.logoUrl!.isNotEmpty 
                    ? (business.logoUrl!.startsWith('data:image') 
                        ? MemoryImage(base64Decode(business.logoUrl!.split(',').last)) as ImageProvider
                        : NetworkImage(business.logoUrl!))
                    : null,
                child: business?.logoUrl == null || business!.logoUrl!.isEmpty 
                    ? const Icon(Icons.store, size: 18, color: Colors.white) 
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
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.2)),
              ),
              child: DropdownButtonHideUnderline(
                child: Obx(() => DropdownButton<String>(
                  value: _profitService.dateFilter.value,
                  icon: Icon(Icons.arrow_drop_down, size: 20, color: theme.colorScheme.onSurface),
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                  dropdownColor: theme.colorScheme.surface,
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
        final returnedOrdersCount = _profitService.returnedOrdersCount.value;
        final cancelledOrdersCount = _profitService.cancelledOrdersCount.value;
        
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
                // Profit Card (Premium Tinted Design with Breakdown)
                Container(
                  decoration: BoxDecoration(
                    color: profit >= 0 
                        ? const Color(0xFF059669).withValues(alpha: 0.15) 
                        : const Color(0xFFDC2626).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: profit >= 0 
                          ? const Color(0xFF059669).withValues(alpha: 0.3) 
                          : const Color(0xFFDC2626).withValues(alpha: 0.3),
                      width: 1.5,
                    ),
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
                              'NET PROFIT',
                              style: TextStyle(
                                color: profit >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: profit >= 0 
                                    ? const Color(0xFF059669).withValues(alpha: 0.2) 
                                    : const Color(0xFFDC2626).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    margin >= 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, 
                                    size: 14, 
                                    color: profit >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444)
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${margin.abs().toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: profit >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${profit >= 0 ? "" : "-"}${businessController.currencySymbol}${profit.abs().toStringAsFixed(0)}',
                            style: TextStyle(
                              color: profit >= 0 ? const Color(0xFF34D399) : const Color(0xFFF87171),
                              fontWeight: FontWeight.w900,
                              fontSize: 48,
                              height: 1.1,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Additional breakdown row
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text('Total Sales', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text('${businessController.currencySymbol}${revenue.toStringAsFixed(0)}', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              Container(height: 30, width: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                              Column(
                                children: [
                                  Text('Total Costs', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text('${businessController.currencySymbol}${(revenue - profit).toStringAsFixed(0)}', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Quick Actions
                Text(
                  'Quick Actions', 
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, 
                    color: theme.colorScheme.onSurface
                  )
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildQuickAction(context, 'Add Order', Icons.add_shopping_cart, theme.colorScheme.secondary, () {
                      Get.to(() => const AddOrderView());
                    }),
                    const SizedBox(width: 12),
                    _buildQuickAction(context, 'Add Expense', Icons.receipt_long, Colors.purple, () {
                      Get.to(() => const AddExpenseView());
                    }),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // 2x2 Metrics Grid
                Text(
                  'Performance Overview', 
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, 
                    color: theme.colorScheme.onSurface
                  )
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 2;
                    if (constraints.maxWidth >= 1000) {
                      crossAxisCount = 4;
                    } else if (constraints.maxWidth >= 600) {
                      crossAxisCount = 3;
                    }
                    
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: constraints.maxWidth >= 1000 ? 1.8 : 1.4,
                      children: [
                        _buildMetricCard(context, 'Total Sales', '${businessController.currencySymbol}${revenue.toStringAsFixed(0)}', Icons.point_of_sale, AppTheme.info),
                        _buildMetricCard(context, 'Total Orders', '$totalOrders', Icons.inventory_2, theme.colorScheme.primary),
                        _buildMetricCard(context, 'Expenses', '${businessController.currencySymbol}${expenses.toStringAsFixed(0)}', Icons.money_off, AppTheme.warning),
                        _buildMetricCard(context, 'Collected', '${businessController.currencySymbol}${collected.toStringAsFixed(0)}', Icons.account_balance_wallet, AppTheme.success),
                        _buildMetricCard(context, 'Returned / RTO', '$returnedOrdersCount', Icons.assignment_return, theme.colorScheme.error),
                        _buildMetricCard(context, 'Cancelled', '$cancelledOrdersCount', Icons.cancel_outlined, Colors.grey),
                      ],
                    );
                  }
                ),
                
                const SizedBox(height: 24),
                
                // Warnings / Leaks Row
                if (returnLoss > 0)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.warning_amber_rounded, color: Colors.red[600] ?? Colors.red, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Profit Leak Detected', style: theme.textTheme.titleSmall?.copyWith(color: Colors.red[700] ?? Colors.red, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text('Return/RTO costs have eaten ${businessController.currencySymbol}${returnLoss.toStringAsFixed(0)} of your revenue.', style: theme.textTheme.bodySmall?.copyWith(color: Colors.red[900] ?? Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                
                if (_orderController.orders.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Orders', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          // Find DashboardView's parent NavigationRail or bottom bar and change tab to 2 (Orders).
                          // Or simply use GetX to go to OrdersView directly (but they might lose bottom bar).
                          // Actually, they can just use the navigation bar.
                        },
                        child: const Text('View All', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._orderController.orders.take(3).map((order) {
                    final realProfit = order.sellingPrice - order.discount - order.productCost - order.courierCost - order.packagingCost - order.adAllocation - order.paymentFee - order.returnCost - order.otherCost;
                    
                    Color statusColor = Colors.grey;
                    if (order.status == 'Delivered') statusColor = AppTheme.success;
                    if (order.status == 'Returned' || order.status == 'RTO') statusColor = theme.colorScheme.error;
                    if (order.status == 'Shipped') statusColor = AppTheme.info;
                    if (order.status == 'Confirmed') statusColor = AppTheme.warning;
                    if (order.status == 'Cancelled') statusColor = theme.colorScheme.error;

                    String firstLetter = order.customerName != null && order.customerName!.isNotEmpty 
                        ? order.customerName!.substring(0, 1).toUpperCase() 
                        : '?';
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            firstLetter,
                            style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(order.customerName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(
                          order.phone ?? '',
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${businessController.currencySymbol}${(order.sellingPrice - order.discount).toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                order.status,
                                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQuickAction(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
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
              Text(
                title, 
                style: TextStyle(
                  color: theme.colorScheme.onSurface, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 14
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color iconColor) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
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
                      fontSize: 13,
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
                  fontSize: 24,
                  letterSpacing: -0.5,
                  color: theme.colorScheme.onSurface,
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
