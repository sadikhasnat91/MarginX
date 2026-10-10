import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import 'add_order_view.dart';
import 'package:intl/intl.dart';
import '../../../core/services/export_service.dart';
import '../../onboarding/controllers/business_controller.dart';
import '../../../core/theme/app_theme.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController orderController = Get.put(OrderController());
    final BusinessController businessController = Get.find<BusinessController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Export to Excel',
            onPressed: () {
              if (orderController.orders.isNotEmpty) {
                ExportService.exportOrdersToExcel(orderController.orders);
              } else {
                Get.snackbar('Empty', 'No orders to export');
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (orderController.isLoading.value && orderController.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (orderController.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('No orders yet', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Add your first order manually or import via CSV.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => const AddOrderView()),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Order'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: orderController.fetchOrders,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 800;
              
              if (isDesktop) {
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: constraints.maxWidth >= 1200 ? 3 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 260,
                  ),
                  itemCount: orderController.orders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(context, orderController.orders[index], orderController, businessController, theme);
                  },
                );
              }
              
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: orderController.orders.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildOrderCard(context, orderController.orders[index], orderController, businessController, theme);
                },
              );
            }
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddOrderView()),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, dynamic order, OrderController orderController, BusinessController businessController, ThemeData theme) {
    final realProfit = order.sellingPrice - order.discount - order.productCost - order.courierCost - order.packagingCost - order.adAllocation - order.paymentFee - order.returnCost - order.otherCost;
    final isProfitPositive = realProfit >= 0;
    
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
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.brightness == Brightness.light ? const Color(0xFFE2E8F0) : theme.dividerColor,
                  ),
                  boxShadow: theme.brightness == Brightness.light ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Column(
                  children: [
                    // Top header with status color bar
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: theme.colorScheme.primaryContainer,
                                      child: Text(
                                        firstLetter,
                                        style: TextStyle(
                                          color: theme.colorScheme.onPrimaryContainer,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order.customerName ?? 'Unknown',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 17,
                                              letterSpacing: -0.3,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(Icons.phone_outlined, size: 14, color: theme.colorScheme.onSurfaceVariant),
                                              const SizedBox(width: 4),
                                              Text(
                                                order.phone ?? 'No phone',
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: theme.colorScheme.onSurfaceVariant,
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
                                  const PopupMenuItem<String>(value: 'INVOICE', child: Row(children: [Icon(Icons.receipt_long, size: 18), SizedBox(width: 8), Text('Generate Invoice')])),
                                ],
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        order.status,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.arrow_drop_down, size: 14, color: statusColor),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.dividerColor),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Revenue',
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${businessController.currencySymbol}${(order.sellingPrice - order.discount).toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(width: 1, height: 40, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Net Profit',
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${isProfitPositive ? "+" : "-"}${businessController.currencySymbol}${realProfit.abs().toStringAsFixed(0)}',
                                        style: TextStyle(
                                          color: isProfitPositive ? Colors.green.shade700 : Colors.red.shade700,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Date',
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        order.orderDate != null ? DateFormat('MMM dd').format(order.orderDate!) : '-',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              if (order.status == 'Confirmed')
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade600,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () {
                                      orderController.updateOrderStatus(order, 'Shipped');
                                    },
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.local_shipping_outlined, size: 18),
                                        SizedBox(width: 8),
                                        Text('Mark as Sent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                ),
                              if (order.status == 'Confirmed') const SizedBox(width: 12),
                              if (order.status == 'Delivered')
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: order.isPaymentReceived ? Colors.green.withValues(alpha: 0.05) : Colors.orange.withValues(alpha: 0.05),
                                      side: BorderSide(color: order.isPaymentReceived ? Colors.green : Colors.orange),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () => orderController.togglePaymentStatus(order),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          order.isPaymentReceived ? Icons.check_circle : Icons.pending_actions,
                                          size: 18,
                                          color: order.isPaymentReceived ? Colors.green : Colors.orange,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          order.isPaymentReceived ? 'Payment Received' : 'Payment Pending',
                                          style: TextStyle(
                                            color: order.isPaymentReceived ? Colors.green.shade700 : Colors.orange.shade700,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (order.status == 'Delivered') const SizedBox(width: 12),
                              if (order.status != 'Confirmed' && order.status != 'Delivered') const Spacer(),
                              
                              IconButton(
                                style: IconButton.styleFrom(
                                  backgroundColor: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: Icon(Icons.edit_outlined, size: 20, color: theme.colorScheme.onSecondaryContainer),
                                onPressed: () => Get.to(() => AddOrderView(order: order)),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                onPressed: () {
                                  Get.dialog(
                                    AlertDialog(
                                      title: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text('Delete Order'),
                                        ],
                                      ),
                                      content: const Text(
                                        'Are you sure you want to delete this order?\nThis action cannot be undone.',
                                      ),
                                      actions: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: theme.brightness == Brightness.light ? const Color(0xFFF1F5F9) : Colors.white10,
                                            foregroundColor: theme.brightness == Brightness.light ? const Color(0xFF475569) : Colors.white70,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              side: theme.brightness == Brightness.light ? const BorderSide(color: Color(0xFFE2E8F0)) : BorderSide.none,
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          ),
                                          onPressed: () => Get.back(),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
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
              );
  }
}
