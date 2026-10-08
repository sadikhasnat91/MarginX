import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import 'add_order_view.dart';
import 'package:intl/intl.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController orderController = Get.put(OrderController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
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
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orderController.orders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orderController.orders[index];
              
              final realProfit = order.sellingPrice - order.discount - order.productCost - order.courierCost - order.packagingCost - order.adAllocation - order.paymentFee - order.returnCost - order.otherCost;
              final isProfitPositive = realProfit >= 0;
              
              Color statusColor = Colors.grey;
              if (order.status == 'Delivered') statusColor = Colors.green;
              if (order.status == 'Returned' || order.status == 'RTO') statusColor = Colors.red;
              if (order.status == 'Shipped') statusColor = Colors.blue;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              order.customerName ?? 'Unknown',
                              style: theme.textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PopupMenuButton<String>(
                                initialValue: order.status,
                                onSelected: (String newStatus) {
                                  if (newStatus != order.status) {
                                    orderController.updateOrderStatus(order, newStatus);
                                  }
                                },
                                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(value: 'Pending', child: Text('Pending')),
                                  const PopupMenuItem<String>(value: 'Shipped', child: Text('Shipped')),
                                  const PopupMenuItem<String>(value: 'Delivered', child: Text('Delivered')),
                                  const PopupMenuItem<String>(value: 'Returned', child: Text('Returned')),
                                  const PopupMenuItem<String>(value: 'RTO', child: Text('RTO')),
                                ],
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        order.status,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Icon(Icons.arrow_drop_down, size: 16, color: statusColor),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  Get.to(() => AddOrderView(order: order));
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  Get.defaultDialog(
                                    title: 'Delete Order',
                                    middleText: 'Are you sure you want to delete this order?\nThis will remove it from all calculations.',
                                    textConfirm: 'Delete',
                                    textCancel: 'Cancel',
                                    confirmTextColor: Colors.white,
                                    buttonColor: Colors.red,
                                    onConfirm: () {
                                      Get.back();
                                      orderController.deleteOrder(order.id);
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                          const SizedBox(width: 4),
                          Text(
                            order.phone ?? 'No phone',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.calendar_today, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                          const SizedBox(width: 4),
                          Text(
                            order.orderDate != null ? DateFormat('MMM dd, yyyy').format(order.orderDate!) : 'Unknown date',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Revenue', style: theme.textTheme.bodySmall),
                              Text('৳${(order.sellingPrice - order.discount).toStringAsFixed(0)}', style: theme.textTheme.titleSmall),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Real Profit', style: theme.textTheme.bodySmall),
                              Text(
                                '${isProfitPositive ? "+" : ""}৳${realProfit.toStringAsFixed(0)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: isProfitPositive ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (order.status == 'Delivered') ...[
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Payment Status', style: theme.textTheme.bodyMedium),
                            InkWell(
                              onTap: () => orderController.togglePaymentStatus(order),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: order.isPaymentReceived 
                                      ? Colors.green.withValues(alpha: 0.1) 
                                      : Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: order.isPaymentReceived ? Colors.green : Colors.orange,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      order.isPaymentReceived ? Icons.check_circle : Icons.pending_actions,
                                      size: 16,
                                      color: order.isPaymentReceived ? Colors.green : Colors.orange,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      order.isPaymentReceived ? 'Received' : 'Pending',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: order.isPaymentReceived ? Colors.green : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddOrderView()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
