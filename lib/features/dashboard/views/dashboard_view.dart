import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../products/views/products_view.dart';
import '../../orders/views/orders_view.dart';
import '../../orders/views/add_order_view.dart';
import '../../expenses/views/expenses_view.dart';
import '../../expenses/views/add_expense_view.dart';
import '../../products/views/add_product_view.dart';
import '../../../core/services/profit_calculation_service.dart';
import '../../orders/controllers/order_controller.dart';
import '../../expenses/controllers/expense_controller.dart';
import '../../products/controllers/product_controller.dart';
import '../../onboarding/controllers/business_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_ui_elements.dart';
import '../../insights/views/insights_view.dart';
import '../../settings/views/settings_view.dart';

class DashboardNavController extends GetxController {
  static DashboardNavController get to => Get.find<DashboardNavController>();
  final currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Get.put(DashboardNavController());
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;
    final bool isWideDesktop = MediaQuery.of(context).size.width >= 1100;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    final List<Widget> pages = const [
      _DashboardHomeView(),
      ProductsView(),
      OrdersView(),
      ExpensesView(),
      InsightsView(),
    ];

    return Obx(() {
      final currentIdx = nav.currentIndex.value;

      if (isDesktop) {
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                extended: isWideDesktop,
                selectedIndex: currentIdx,
                onDestinationSelected: (index) => nav.changeTab(index),
                backgroundColor: isLight ? const Color(0xFFF8FAFC) : theme.colorScheme.surface,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        width: isWideDesktop ? 160 : 44,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: Text('Dashboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.inventory_2_outlined),
                    selectedIcon: Icon(Icons.inventory_2),
                    label: Text('Products'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.shopping_bag_outlined),
                    selectedIcon: Icon(Icons.shopping_bag),
                    label: Text('Orders'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.account_balance_wallet_outlined),
                    selectedIcon: Icon(Icons.account_balance_wallet),
                    label: Text('Expenses'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.insights_outlined),
                    selectedIcon: Icon(Icons.insights),
                    label: Text('Insights'),
                  ),
                ],
              ),
              VerticalDivider(
                thickness: 1,
                width: 1,
                color: isLight ? const Color(0xFFD8DEE6) : theme.dividerColor,
              ),
              Expanded(
                child: IndexedStack(
                  index: currentIdx,
                  children: pages,
                ),
              ),
            ],
          ),
        );
      }

      // Mobile layout
      return Scaffold(
        body: IndexedStack(
          index: currentIdx,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIdx,
          onDestinationSelected: (index) => nav.changeTab(index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: 'Products',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_bag_outlined),
              selectedIcon: Icon(Icons.shopping_bag),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Expenses',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights),
              label: 'Insights',
            ),
          ],
        ),
      );
    });
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
    final isLight = theme.brightness == Brightness.light;
    final BusinessController businessController = Get.find<BusinessController>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(() {
          final business = businessController.currentBusiness.value;
          return Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isLight ? const Color(0xFFD8DEE6) : Colors.white24,
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 19,
                  backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.15),
                  backgroundImage: business?.logoUrl != null && business!.logoUrl!.isNotEmpty
                      ? (business.logoUrl!.startsWith('data:image')
                          ? MemoryImage(base64Decode(business.logoUrl!.split(',').last)) as ImageProvider
                          : NetworkImage(business.logoUrl!))
                      : null,
                  child: business?.logoUrl == null || business!.logoUrl!.isEmpty
                      ? const Icon(Icons.storefront_rounded, size: 20, color: Colors.blueAccent)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()},',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      business?.name ?? 'Business Owner',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: -0.3,
                      ),
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
                color: isLight ? Colors.white : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isLight ? const Color(0xFFD8DEE6) : Colors.white12,
                  width: 1.2,
                ),
                boxShadow: isLight
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: DropdownButtonHideUnderline(
                child: Obx(
                  () => DropdownButton<String>(
                    value: _profitService.dateFilter.value,
                    icon: Icon(Icons.calendar_today_outlined, size: 16, color: theme.colorScheme.primary),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
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
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isLight ? Colors.white : theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isLight ? const Color(0xFFD8DEE6) : Colors.white12,
                  width: 1.2,
                ),
              ),
              child: Icon(Icons.settings_outlined, size: 18, color: theme.colorScheme.onSurface),
            ),
            onPressed: () {
              Get.to(() => const SettingsView());
            },
          ),
          const SizedBox(width: 8),
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
              _productController.fetchProducts(),
            ]);
            _profitService.recalculate();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Hero Net Profit Card (State of the art Fintech design)
                _buildHeroProfitCard(
                  context: context,
                  profit: profit,
                  margin: margin,
                  revenue: revenue,
                  collected: collected,
                  currencySymbol: businessController.currencySymbol,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 24),

                // 2. Quick Action Hub
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quick Actions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        context: context,
                        title: 'Add Order',
                        subtitle: 'New sale',
                        icon: Icons.add_shopping_cart_rounded,
                        accentColor: const Color(0xFF2563EB),
                        gradient: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        onTap: () => Get.to(() => const AddOrderView()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionButton(
                        context: context,
                        title: 'Add Expense',
                        subtitle: 'Ads, courier & ops',
                        icon: Icons.receipt_long_rounded,
                        accentColor: const Color(0xFF7C3AED),
                        gradient: const [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                        onTap: () => Get.to(() => const AddExpenseView()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionButton(
                        context: context,
                        title: 'Add Product',
                        subtitle: 'Inventory item',
                        icon: Icons.inventory_2_rounded,
                        accentColor: const Color(0xFF059669),
                        gradient: const [Color(0xFF059669), Color(0xFF047857)],
                        onTap: () => Get.to(() => const AddProductView()),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.08, end: 0),

                const SizedBox(height: 24),

                // 3. Performance Metrics Grid
                Text(
                  'Performance Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: theme.colorScheme.onSurface,
                  ),
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
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: constraints.maxWidth >= 1000 ? 1.75 : 1.35,
                      children: [
                        _buildMetricCard(
                          context: context,
                          title: 'Total Sales',
                          value: revenue,
                          prefix: businessController.currencySymbol,
                          icon: Icons.point_of_sale_rounded,
                          accentColor: const Color(0xFF2563EB),
                          badgeText: 'Gross',
                          delayMs: 150,
                        ),
                        _buildMetricCard(
                          context: context,
                          title: 'Total Orders',
                          value: totalOrders,
                          isCount: true,
                          icon: Icons.shopping_bag_outlined,
                          accentColor: const Color(0xFF0F172A),
                          badgeText: 'Volume',
                          delayMs: 200,
                        ),
                        _buildMetricCard(
                          context: context,
                          title: 'Total Expenses',
                          value: expenses,
                          prefix: businessController.currencySymbol,
                          icon: Icons.account_balance_wallet_outlined,
                          accentColor: const Color(0xFFD97706),
                          badgeText: 'Costs',
                          delayMs: 250,
                        ),
                        _buildMetricCard(
                          context: context,
                          title: 'Cash Collected',
                          value: collected,
                          prefix: businessController.currencySymbol,
                          icon: Icons.check_circle_outline_rounded,
                          accentColor: const Color(0xFF059669),
                          badgeText: 'Received',
                          delayMs: 300,
                        ),
                        _buildMetricCard(
                          context: context,
                          title: 'Returned / RTO',
                          value: returnedOrdersCount,
                          isCount: true,
                          icon: Icons.assignment_return_outlined,
                          accentColor: const Color(0xFFDC2626),
                          badgeText: 'Returns',
                          delayMs: 350,
                        ),
                        _buildMetricCard(
                          context: context,
                          title: 'Cancelled',
                          value: cancelledOrdersCount,
                          isCount: true,
                          icon: Icons.cancel_outlined,
                          accentColor: const Color(0xFF64748B),
                          badgeText: 'Void',
                          delayMs: 400,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // 4. Profit Leak Warning (if return loss exists)
                if (returnLoss > 0)
                  HoverableCard(
                    onTap: () => DashboardNavController.to.changeTab(2),
                    backgroundColor: isLight ? const Color(0xFFFFF1F2) : const Color(0xFF881337).withOpacity(0.2),
                    borderColor: isLight ? const Color(0xFFFECDD3) : const Color(0xFFF43F5E).withOpacity(0.4),
                    borderWidth: 1.5,
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 26),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const PulsingStatusDot(color: Color(0xFFDC2626), size: 8),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Profit Leak Detected',
                                    style: TextStyle(
                                      color: isLight ? const Color(0xFF9F1239) : const Color(0xFFFDA4AF),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Courier return fees have eaten ${businessController.currencySymbol}${returnLoss.toStringAsFixed(0)} of your real profit. Click to review returned orders.',
                                style: TextStyle(
                                  color: isLight ? const Color(0xFF881337) : Colors.white70,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFDC2626)),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).shake(duration: 600.ms, hz: 2),

                // 5. Recent Orders Section
                if (_orderController.orders.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Recent Orders',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isLight ? const Color(0xFFE2E8F0) : Colors.white10,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_orderController.orders.length}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isLight ? const Color(0xFF475569) : Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () => DashboardNavController.to.changeTab(2),
                        icon: const Icon(Icons.arrow_forward, size: 14),
                        label: const Text('View All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._orderController.orders.take(4).toList().asMap().entries.map((entry) {
                    final int idx = entry.key;
                    final order = entry.value;
                    final realProfit = order.sellingPrice -
                        order.discount -
                        order.productCost -
                        order.courierCost -
                        order.packagingCost -
                        order.adAllocation -
                        order.paymentFee -
                        order.returnCost -
                        order.otherCost;

                    final isProfitable = realProfit >= 0;
                    final String firstLetter = order.customerName != null && order.customerName!.isNotEmpty
                        ? order.customerName!.substring(0, 1).toUpperCase()
                        : '?';

                    return HoverableCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      onTap: () => DashboardNavController.to.changeTab(2),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary.withValues(alpha: 0.15),
                                  AppTheme.primaryLight.withValues(alpha: 0.25),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                firstLetter,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        order.customerName ?? 'Unknown Customer',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    StatusPill(status: order.status),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  order.phone != null && order.phone!.isNotEmpty
                                      ? order.phone!
                                      : 'Order #${order.id.toString().substring(0, 6)}',
                                  style: TextStyle(
                                    color: isLight ? const Color(0xFF64748B) : Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${businessController.currencySymbol}${(order.sellingPrice - order.discount).toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isProfitable
                                      ? const Color(0xFF059669).withValues(alpha: 0.12)
                                      : const Color(0xFFDC2626).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${isProfitable ? '+' : ''}${businessController.currencySymbol}${realProfit.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: isProfitable ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: (400 + idx * 50).ms, duration: 350.ms).slideX(begin: 0.04, end: 0);
                  }),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  /// State-of-the-art Hero Net Profit card with gradient depth and animated counters
  Widget _buildHeroProfitCard({
    required BuildContext context,
    required double profit,
    required double margin,
    required double revenue,
    required double collected,
    required String currencySymbol,
  }) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final isProfitable = profit >= 0;

    final primaryColor = isProfitable ? const Color(0xFF059669) : const Color(0xFFDC2626);
    final darkBgGradient = isProfitable
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B192C), Color(0xFF064E3B)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E1014), Color(0xFF7F1D1D)],
          );

    final lightBgGradient = isProfitable
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
          );

    return Container(
      decoration: BoxDecoration(
        gradient: isLight ? lightBgGradient : darkBgGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLight
              ? (isProfitable ? const Color(0xFF86EFAC) : const Color(0xFFFECACA))
              : (isProfitable ? const Color(0xFF059669).withOpacity(0.4) : const Color(0xFFDC2626).withOpacity(0.4)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(isLight ? 0.08 : 0.25),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title + Pulsing Live Dot + Margin Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    PulsingStatusDot(color: primaryColor, size: 8),
                    const SizedBox(width: 8),
                    Text(
                      'REAL NET PROFIT',
                      style: TextStyle(
                        color: isLight
                            ? (isProfitable ? const Color(0xFF15803D) : const Color(0xFFDC2626))
                            : (isProfitable ? const Color(0xFF34D399) : const Color(0xFFF87171)),
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.white : Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: primaryColor.withOpacity(isLight ? 0.3 : 0.5),
                    ),
                    boxShadow: isLight
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        margin >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        size: 16,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${margin.abs().toStringAsFixed(1)}% Margin',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Big Number: Animated Counter
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: AnimatedCounter(
                value: profit.abs(),
                prefix: '${isProfitable ? "" : "-"}$currencySymbol',
                style: TextStyle(
                  color: isLight
                      ? (isProfitable ? const Color(0xFF15803D) : const Color(0xFFB91C1C))
                      : (isProfitable ? const Color(0xFF34D399) : const Color(0xFFF87171)),
                  fontWeight: FontWeight.w900,
                  fontSize: 48,
                  height: 1.1,
                  letterSpacing: -1.5,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Visual Ratio Bar: Net Profit Share of Revenue
            if (revenue > 0) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (profit / revenue).clamp(0.0, 1.0),
                  minHeight: 7,
                  backgroundColor: isLight ? const Color(0xFFE2E8F0) : Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profit retention rate',
                    style: TextStyle(
                      fontSize: 11,
                      color: isLight ? const Color(0xFF64748B) : Colors.white60,
                    ),
                  ),
                  Text(
                    '${((profit / revenue) * 100).clamp(-100.0, 100.0).toStringAsFixed(1)}% of total sales',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isLight ? const Color(0xFF475569) : Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
            ],

            // Breakdown Stats Sub-Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isLight ? Colors.white : theme.colorScheme.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isLight ? const Color(0xFFD8DEE6) : Colors.white12,
                  width: 1,
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
                children: [
                  Expanded(
                    child: _buildBreakdownItem(
                      title: 'Total Sales',
                      value: revenue,
                      currency: currencySymbol,
                      isLight: isLight,
                      theme: theme,
                    ),
                  ),
                  Container(height: 28, width: 1, color: isLight ? const Color(0xFFE2E8F0) : Colors.white12),
                  Expanded(
                    child: _buildBreakdownItem(
                      title: 'Total Costs',
                      value: (revenue - profit) > 0 ? (revenue - profit) : 0,
                      currency: currencySymbol,
                      isLight: isLight,
                      theme: theme,
                    ),
                  ),
                  Container(height: 28, width: 1, color: isLight ? const Color(0xFFE2E8F0) : Colors.white12),
                  Expanded(
                    child: _buildBreakdownItem(
                      title: 'Collected',
                      value: collected,
                      currency: currencySymbol,
                      isLight: isLight,
                      theme: theme,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItem({
    required String title,
    required double value,
    required String currency,
    required bool isLight,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: isLight ? const Color(0xFF64748B) : Colors.white60,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedCounter(
          value: value,
          prefix: currency,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  /// Modern interactive quick action button with hover scaling and vibrant gradient badge
  Widget _buildQuickActionButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return HoverableCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isLight ? const Color(0xFF64748B) : Colors.white60,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Modern KPI Metric Card with animated number rolling, rounded icon pill, and hover lift
  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required num value,
    String prefix = '',
    bool isCount = false,
    required IconData icon,
    required Color accentColor,
    required String badgeText,
    required int delayMs,
  }) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return HoverableCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isLight ? 0.1 : 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isLight ? const Color(0xFFF1F5F9) : Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isLight ? const Color(0xFF64748B) : Colors.white60,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isLight ? const Color(0xFF64748B) : Colors.white60,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: AnimatedCounter(
                  value: value,
                  prefix: prefix,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    letterSpacing: -0.6,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: delayMs.ms, duration: 350.ms).slideY(begin: 0.08, end: 0);
  }
}
