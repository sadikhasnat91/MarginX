import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/product_model.dart';
import '../../onboarding/controllers/business_controller.dart';
import '../../products/controllers/product_controller.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();

  final SupabaseClient _supabase = Supabase.instance.client;
  
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(Get.find<BusinessController>().currentBusiness, (business) {
      if (business != null) {
        fetchOrders();
      } else {
        orders.clear();
      }
    });
    
    if (Get.find<BusinessController>().currentBusiness.value != null) {
      fetchOrders();
    }
  }

  Future<void> fetchOrders() async {
    final business = Get.find<BusinessController>().currentBusiness.value;
    if (business == null) return;

    try {
      isLoading.value = true;
      final response = await _supabase
          .from('orders')
          .select()
          .eq('business_id', business.id)
          .order('order_date', ascending: false);

      orders.value = (response as List).map((data) => OrderModel.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      Get.snackbar('Error', 'Failed to load orders.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addOrder({
    required ProductModel product,
    required int quantity,
    required String customerName,
    required String phone,
    required String courier,
    required String status,
    required double discount,
    required double courierCost,
    bool isPaymentReceived = false,
  }) async {
    final business = Get.find<BusinessController>().currentBusiness.value;
    if (business == null) return false;

    try {
      isLoading.value = true;
      
      final orderData = {
        'business_id': business.id,
        'customer_name': customerName,
        'phone': phone,
        'status': status,
        'courier': courier,
        'selling_price': product.sellingPrice * quantity,
        'discount': discount,
        'product_cost': product.productCost * quantity,
        'courier_cost': courierCost,
        'packaging_cost': product.packagingCost * quantity,
        'ad_allocation': 0.0,
        'payment_fee': 0.0, // Should be calculated if COD
        'return_cost': 0.0,
        'other_cost': 0.0,
        // 'is_payment_received': isPaymentReceived, // TODO: Add this column to DB
        'order_date': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      final newOrder = OrderModel.fromJson(response);
      
      // Also add to order_items
      await _supabase.from('order_items').insert({
        'order_id': newOrder.id,
        'product_id': product.id,
        'quantity': quantity,
        'unit_price': product.sellingPrice,
      });

      // Update product stock
      await _supabase.from('products').update({
        'stock_quantity': product.stockQuantity - quantity,
      }).eq('id', product.id);

      // Refresh product list in UI
      if (Get.isRegistered<ProductController>()) {
        Get.find<ProductController>().fetchProducts();
      }

      orders.insert(0, newOrder);
      
      Get.snackbar('Success', 'Order added successfully!', backgroundColor: Colors.green, colorText: Colors.white);
      return true;
    } catch (e) {
      debugPrint('Error adding order: $e');
      Get.snackbar('Error', 'Could not add order.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> togglePaymentStatus(OrderModel order) async {
    try {
      final newStatus = !order.isPaymentReceived;
      
      // TODO: Uncomment when is_payment_received column is added to DB
      // await _supabase
      //     .from('orders')
      //     .update({'is_payment_received': newStatus})
      //     .eq('id', order.id);

      final index = orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        orders[index] = OrderModel(
          id: order.id,
          businessId: order.businessId,
          orderIdCustom: order.orderIdCustom,
          customerName: order.customerName,
          phone: order.phone,
          status: order.status,
          orderDate: order.orderDate,
          deliveryDate: order.deliveryDate,
          courier: order.courier,
          sellingPrice: order.sellingPrice,
          discount: order.discount,
          productCost: order.productCost,
          courierCost: order.courierCost,
          packagingCost: order.packagingCost,
          adAllocation: order.adAllocation,
          paymentFee: order.paymentFee,
          returnCost: order.returnCost,
          otherCost: order.otherCost,
          isPaymentReceived: newStatus,
          notes: order.notes,
          createdAt: order.createdAt,
          updatedAt: order.updatedAt,
        );
      }
    } catch (e) {
      debugPrint('Error toggling payment status: $e');
      Get.snackbar('Error', 'Could not update payment status.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<bool> deleteOrder(String orderId) async {
    try {
      isLoading.value = true;
      
      // Also delete from order_items (usually cascade in DB, but explicitly here if no cascade)
      await _supabase
          .from('order_items')
          .delete()
          .eq('order_id', orderId);

      await _supabase
          .from('orders')
          .delete()
          .eq('id', orderId);

      orders.removeWhere((o) => o.id == orderId);
      
      Get.snackbar('Success', 'Order deleted successfully!', backgroundColor: Colors.green, colorText: Colors.white);
      return true;
    } catch (e) {
      debugPrint('Error deleting order: $e');
      Get.snackbar('Error', 'Could not delete order.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> editOrder({
    required String orderId,
    required String customerName,
    required String phone,
    required String courier,
    required String status,
    required double discount,
    required double courierCost,
    bool? isPaymentReceived,
  }) async {
    try {
      isLoading.value = true;
      
      final orderData = {
        'customer_name': customerName,
        'phone': phone,
        'courier': courier,
        'status': status,
        'discount': discount,
        'courier_cost': courierCost,
      };

      // if (isPaymentReceived != null) {
      //   orderData['is_payment_received'] = isPaymentReceived;
      // }

      final response = await _supabase
          .from('orders')
          .update(orderData)
          .eq('id', orderId)
          .select()
          .single();

      final updatedOrder = OrderModel.fromJson(response);
      
      final index = orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        orders[index] = updatedOrder;
      }
      
      Get.snackbar('Success', 'Order updated successfully!', backgroundColor: Colors.green, colorText: Colors.white);
      return true;
    } catch (e) {
      debugPrint('Error updating order: $e');
      Get.snackbar('Error', 'Could not update order.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrderStatus(OrderModel order, String newStatus) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': newStatus})
          .eq('id', order.id);

      final index = orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        orders[index] = OrderModel(
          id: order.id,
          businessId: order.businessId,
          orderIdCustom: order.orderIdCustom,
          customerName: order.customerName,
          phone: order.phone,
          status: newStatus,
          orderDate: order.orderDate,
          deliveryDate: newStatus == 'Delivered' ? DateTime.now() : order.deliveryDate,
          courier: order.courier,
          sellingPrice: order.sellingPrice,
          discount: order.discount,
          productCost: order.productCost,
          courierCost: order.courierCost,
          packagingCost: order.packagingCost,
          adAllocation: order.adAllocation,
          paymentFee: order.paymentFee,
          returnCost: order.returnCost,
          otherCost: order.otherCost,
          isPaymentReceived: order.isPaymentReceived,
          notes: order.notes,
          createdAt: order.createdAt,
          updatedAt: order.updatedAt,
        );
      }
      Get.snackbar('Status Updated', 'Order marked as $newStatus', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      debugPrint('Error updating order status: $e');
      Get.snackbar('Error', 'Could not update status.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
