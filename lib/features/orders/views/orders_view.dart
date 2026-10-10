import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/order_controller.dart';
import 'add_order_view.dart';
import '../../../core/services/export_service.dart';
import '../../onboarding/controllers/business_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_ui_elements.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  final OrderController _orderController = Get.put(OrderController());
  final BusinessController _businessController = Get.find<BusinessController>();
  final TextEditingController _searchController = TextEditingController();

  String _selectedStatus = 'All';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Orders',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.4),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isLight ? Colors.white : theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: isLight ? const Color(0xFFD8DEE6) : Colors.white12),
              ),
              child: const Icon(Icons.file_download_outlined, size: 18),
            ),
            tooltip: 'Export to Excel',
            onPressed: () {
              if (_orderController.orders.isNotEmpty) {
                ExportService.exportOrdersToExcel(_orderController.orders);
              } else {
                Get.snackbar('Empty', 'No orders to export');
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (_orderController.isLoading.value && _orderController.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_orderController.orders.isEmpty) {
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
                  child: Icon(Icons.shopping_bag_outlined, size: 64, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 20),
                Text('No orders yet', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                  'Add your first order to start tracking revenue and profit.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => const AddOrderView()),
                  icon: const Icon(Icons.add),
                  label: const Text('Add First Order'),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms).scale(),
          );
        }

        // Filter and search logic
        final allOrders = _orderController.orders;
        final filteredOrders = allOrders.where((order) {
          final matchesStatus = _selectedStatus == 'All' ||
              order.status.toLowerCase() == _selectedStatus.toLowerCase() ||
              (_selectedStatus == 'Returned' && (order.status == 'Returned' || order.status == 'RTO'));

          final q = _searchQuery.toLowerCase();
          final matchesSearch = q.isEmpty ||
              (order.customerName != null && order.customerName!.toLowerCase().contains(q)) ||
              (order.phone != null && order.phone!.toLowerCase().contains(q)) ||
              (order.id.toString().toLowerCase().contains(q));

          return matchesStatus && matchesSearch;
        }).toList();

        // Calculate filtered summary
        double totalRev = 0;
        double totalNet = 0;
        for (var o in filteredOrders) {
          totalRev += (o.sellingPrice - o.discount);
          totalNet += (o.sellingPrice -
              o.discount -
              o.productCost -
              o.courierCost -
              o.packagingCost -
              o.adAllocation -
              o.paymentFee -
              o.returnCost -
              o.otherCost);
        }

        return RefreshIndicator(
          onRefresh: _orderController.fetchOrders,
          child: Column(
            children: [
              // 1. Search Bar & Status Filter Strip
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    // Search Field
                    Container(
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
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        decoration: InputDecoration(
                          hintText: 'Search customer name, phone, or order ID...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: isLight ? const Color(0xFF94A3B8) : Colors.white54,
                          ),
                          prefixIcon: const Icon(Icons.search_rounded, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Filter Chips Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All', allOrders.length),
                          _buildFilterChip('Confirmed', allOrders.where((o) => o.status == 'Confirmed').length),
                          _buildFilterChip('Shipped', allOrders.where((o) => o.status == 'Shipped').length),
                          _buildFilterChip('Delivered', allOrders.where((o) => o.status == 'Delivered').length),
                          _buildFilterChip('Returned', allOrders.where((o) => o.status == 'Returned' || o.status == 'RTO').length),
                          _buildFilterChip('Cancelled', allOrders.where((o) => o.status == 'Cancelled').length),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Quick Mini-Summary Ribbon
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isLight ? Colors.white : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isLight ? const Color(0xFFE2E8F0) : Colors.white12,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Showing ${filteredOrders.length} orders',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isLight ? const Color(0xFF64748B) : Colors.white60,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Sales: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isLight ? const Color(0xFF64748B) : Colors.white60,
                                ),
                              ),
                              Text(
                                '${_businessController.currencySymbol}${totalRev.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Profit: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isLight ? const Color(0xFF64748B) : Colors.white60,
                                ),
                              ),
                              Text(
                                '${totalNet >= 0 ? '+' : ''}${_businessController.currencySymbol}${totalNet.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: totalNet >= 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Orders Grid / List
              Expanded(
                child: filteredOrders.isEmpty
                    ? Center(
                        child: Text(
                          'No orders match this filter',
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
                                mainAxisExtent: 280,
                              ),
                              itemCount: filteredOrders.length,
                              itemBuilder: (context, index) {
                                return _buildOrderCard(
                                  context: context,
                                  order: filteredOrders[index],
                                  orderController: _orderController,
                                  businessController: _businessController,
                                  theme: theme,
                                  index: index,
                                );
                              },
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            itemCount: filteredOrders.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              return _buildOrderCard(
                                context: context,
                                order: filteredOrders[index],
                                orderController: _orderController,
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
        onPressed: () => Get.to(() => const AddOrderView()),
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedStatus.toLowerCase() == label.toLowerCase();
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () => setState(() => _selectedStatus = label),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
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

  Widget _buildOrderCard({
    required BuildContext context,
    required dynamic order,
    required OrderController orderController,
    required BusinessController businessController,
    required ThemeData theme,
    required int index,
  }) {
    final isLight = theme.brightness == Brightness.light;
    final realProfit = order.sellingPrice -
        order.discount -
        order.productCost -
        order.courierCost -
        order.packagingCost -
        order.adAllocation -
        order.paymentFee -
        order.returnCost -
        order.otherCost;

    final isProfitPositive = realProfit >= 0;
    final String firstLetter = order.customerName != null && order.customerName!.isNotEmpty
        ? order.customerName!.substring(0, 1).toUpperCase()
        : '?';

    return HoverableCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Accent Indicator Line
          Container(
            height: 3.5,
            decoration: BoxDecoration(
              color: isProfitPositive ? const Color(0xFF059669) : const Color(0xFFDC2626),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Avatar, Name, Phone, Status Dropdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
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
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.customerName ?? 'Unknown Customer',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone_outlined,
                                      size: 13,
                                      color: isLight ? const Color(0xFF64748B) : Colors.white60,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      order.phone ?? 'No phone',
                                      style: TextStyle(
                                        color: isLight ? const Color(0xFF64748B) : Colors.white60,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      initialValue: order.status,
                      onSelected: (String newStatus) {
                        if (newStatus == 'INVOICE') {
                          ExportService.generateInvoicePdf(order);
                        } else if (newStatus != order.status) {
                          orderController.updateOrderStatus(order, newStatus);
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(value: 'Pending', child: Text('Pending')),
                        const PopupMenuItem<String>(value: 'Confirmed', child: Text('Confirmed')),
                        const PopupMenuItem<String>(value: 'Shipped', child: Text('Shipped')),
                        const PopupMenuItem<String>(value: 'Delivered', child: Text('Delivered')),
                        const PopupMenuItem<String>(value: 'Returned', child: Text('Returned')),
                        const PopupMenuItem<String>(value: 'Cancelled', child: Text('Cancelled')),
                        const PopupMenuItem<String>(value: 'RTO', child: Text('RTO')),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'INVOICE',
                          child: Row(
                            children: [
                              Icon(Icons.receipt_long, size: 18),
                              SizedBox(width: 8),
                              Text('Generate PDF Invoice'),
                            ],
                          ),
                        ),
                      ],
                      child: StatusPill(status: order.status),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Financial Breakdown Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isLight ? const Color(0xFFF8FAFC) : theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isLight ? const Color(0xFFE2E8F0) : Colors.white12,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sale Price',
                              style: TextStyle(
                                color: isLight ? const Color(0xFF64748B) : Colors.white60,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${businessController.currencySymbol}${(order.sellingPrice - order.discount).toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 28, width: 1, color: isLight ? const Color(0xFFE2E8F0) : Colors.white12),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Real Profit',
                              style: TextStyle(
                                color: isLight ? const Color(0xFF64748B) : Colors.white60,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${isProfitPositive ? "+" : "-"}${businessController.currencySymbol}${realProfit.abs().toStringAsFixed(0)}',
                              style: TextStyle(
                                color: isProfitPositive ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 28, width: 1, color: isLight ? const Color(0xFFE2E8F0) : Colors.white12),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Date',
                            style: TextStyle(
                              color: isLight ? const Color(0xFF64748B) : Colors.white60,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.orderDate != null ? DateFormat('MMM dd').format(order.orderDate!) : '-',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Action Buttons Row
                Row(
                  children: [
                    if (order.status == 'Confirmed')
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => orderController.updateOrderStatus(order, 'Shipped'),
                          icon: const Icon(Icons.local_shipping_outlined, size: 16),
                          label: const Text('Mark as Sent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    if (order.status == 'Confirmed') const SizedBox(width: 8),

                    if (order.status == 'Delivered')
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: order.isPaymentReceived
                                ? const Color(0xFF059669).withValues(alpha: 0.08)
                                : const Color(0xFFD97706).withValues(alpha: 0.08),
                            side: BorderSide(
                              color: order.isPaymentReceived ? const Color(0xFF059669) : const Color(0xFFD97706),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => orderController.togglePaymentStatus(order),
                          icon: Icon(
                            order.isPaymentReceived ? Icons.check_circle : Icons.pending_actions,
                            size: 16,
                            color: order.isPaymentReceived ? const Color(0xFF059669) : const Color(0xFFD97706),
                          ),
                          label: Text(
                            order.isPaymentReceived ? 'Payment Received' : 'Collect Payment',
                            style: TextStyle(
                              color: order.isPaymentReceived ? const Color(0xFF059669) : const Color(0xFFD97706),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    if (order.status == 'Delivered') const SizedBox(width: 8),

                    if (order.status != 'Confirmed' && order.status != 'Delivered') const Spacer(),

                    // Edit Button
                    IconButton(
                      tooltip: 'Edit Order',
                      style: IconButton.styleFrom(
                        backgroundColor: isLight ? const Color(0xFFF1F5F9) : Colors.white10,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                      onPressed: () => Get.to(() => AddOrderView(order: order)),
                    ),
                    const SizedBox(width: 6),

                    // Delete Button
                    IconButton(
                      tooltip: 'Delete Order',
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626).withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
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
                                const Text('Delete Order'),
                              ],
                            ),
                            content: const Text(
                              'Are you sure you want to delete this order?\nThis will adjust your real profit calculations.',
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
                                  orderController.deleteOrder(order.id);
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
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 40).ms, duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}
