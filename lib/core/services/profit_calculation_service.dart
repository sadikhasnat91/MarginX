import 'package:get/get.dart';
import '../../data/models/order_model.dart';
import '../../data/models/expense_model.dart';
import '../../features/orders/controllers/order_controller.dart';
import '../../features/expenses/controllers/expense_controller.dart';

class ProfitCalculationService extends GetxService {
  static ProfitCalculationService get instance => Get.find();

  // Metrics
  final RxDouble totalRevenue = 0.0.obs;
  final RxDouble totalCollectedRevenue = 0.0.obs;
  final RxDouble totalRealProfit = 0.0.obs;
  final RxDouble profitMargin = 0.0.obs;
  
  final RxInt totalOrdersCount = 0.obs;
  final RxInt deliveredOrdersCount = 0.obs;
  final RxInt returnedOrdersCount = 0.obs;
  
  final RxDouble totalReturnLoss = 0.0.obs;
  final RxDouble totalExpenses = 0.0.obs;
  final RxDouble totalProductCost = 0.0.obs;
  final RxDouble totalCourierCost = 0.0.obs;

  final RxString dateFilter = 'All Time'.obs;

  late Worker _orderWorker;
  late Worker _expenseWorker;

  @override
  void onInit() {
    super.onInit();
    
    // We delay the worker registration slightly to ensure controllers are ready
    Future.delayed(Duration.zero, () {
      final orderController = Get.find<OrderController>();
      final expenseController = Get.find<ExpenseController>();

      _orderWorker = ever(orderController.orders, (_) => recalculate());
      _expenseWorker = ever(expenseController.expenses, (_) => recalculate());
      ever(dateFilter, (_) => recalculate());
    });
  }

  @override
  void onClose() {
    _orderWorker.dispose();
    _expenseWorker.dispose();
    super.onClose();
  }

  void recalculate() {
    final orderController = Get.find<OrderController>();
    final expenseController = Get.find<ExpenseController>();
    
    DateTime? startDate;
    DateTime? endDate;
    final now = DateTime.now();

    if (dateFilter.value == 'Today') {
      startDate = DateTime(now.year, now.month, now.day);
      endDate = startDate.add(const Duration(days: 1));
    } else if (dateFilter.value == 'Yesterday') {
      startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
      endDate = startDate.add(const Duration(days: 1));
    } else if (dateFilter.value == 'This Month') {
      startDate = DateTime(now.year, now.month, 1);
      endDate = DateTime(now.year, now.month + 1, 1);
    }

    calculate(orderController.orders.toList(), expenseController.expenses.toList(), startDate: startDate, endDate: endDate);
  }

  void calculate(List<OrderModel> orders, List<ExpenseModel> expenses, {DateTime? startDate, DateTime? endDate}) {
    double rev = 0;
    double collectedRev = 0;
    double prodCost = 0;
    double courCost = 0;
    double packCost = 0;
    double adCost = 0;
    double returnCost = 0;
    double paymentFees = 0;
    double otherCost = 0;
    
    int total = 0;
    int delivered = 0;
    int returned = 0;

    for (var order in orders) {
      if (startDate != null && order.orderDate != null && order.orderDate!.isBefore(startDate)) continue;
      if (endDate != null && order.orderDate != null && order.orderDate!.isAfter(endDate)) continue;

      total++;
      if (order.status == 'Delivered') {
        delivered++;
        rev += (order.sellingPrice - order.discount);
        prodCost += order.productCost;
        courCost += order.courierCost;
        packCost += order.packagingCost;
        adCost += order.adAllocation;
        paymentFees += order.paymentFee;
        otherCost += order.otherCost;
        if (order.isPaymentReceived) {
          collectedRev += (order.sellingPrice - order.discount);
        }
      } else if (order.status == 'Returned' || order.status == 'RTO') {
        returned++;
        returnCost += order.courierCost + order.returnCost + order.packagingCost; 
        // For returned items, you typically lose the courier cost both ways + packaging. Product is returned to inventory.
      }
    }

    double exp = 0;
    for (var expense in expenses) {
      if (startDate != null && expense.date.isBefore(startDate)) continue;
      if (endDate != null && expense.date.isAfter(endDate)) continue;
      exp += expense.amount;
    }

    totalRevenue.value = rev;
    totalCollectedRevenue.value = collectedRev;
    totalExpenses.value = exp;
    totalReturnLoss.value = returnCost;
    totalProductCost.value = prodCost;
    totalCourierCost.value = courCost;
    
    // Real Profit Formula
    totalRealProfit.value = rev - prodCost - courCost - packCost - adCost - paymentFees - otherCost - returnCost - exp;

    if (rev > 0) {
      profitMargin.value = (totalRealProfit.value / rev) * 100;
    } else {
      profitMargin.value = 0;
    }

    totalOrdersCount.value = total;
    deliveredOrdersCount.value = delivered;
    returnedOrdersCount.value = returned;
  }
}
