class OrderModel {
  final String id;
  final String businessId;
  final String? orderIdCustom;
  final String? customerName;
  final String? phone;
  final String status;
  final DateTime? orderDate;
  final DateTime? deliveryDate;
  final String? courier;
  final double sellingPrice;
  final double discount;
  final double productCost;
  final double courierCost;
  final double packagingCost;
  final double adAllocation;
  final double paymentFee;
  final double returnCost;
  final double otherCost;
  final bool isPaymentReceived;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.businessId,
    this.orderIdCustom,
    this.customerName,
    this.phone,
    this.status = 'Pending',
    this.orderDate,
    this.deliveryDate,
    this.courier,
    this.sellingPrice = 0.0,
    this.discount = 0.0,
    this.productCost = 0.0,
    this.courierCost = 0.0,
    this.packagingCost = 0.0,
    this.adAllocation = 0.0,
    this.paymentFee = 0.0,
    this.returnCost = 0.0,
    this.otherCost = 0.0,
    this.isPaymentReceived = false,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      businessId: json['business_id'],
      orderIdCustom: json['order_id_custom'],
      customerName: json['customer_name'],
      phone: json['phone'],
      status: json['status'] ?? 'Pending',
      orderDate: json['order_date'] != null ? DateTime.parse(json['order_date']) : null,
      deliveryDate: json['delivery_date'] != null ? DateTime.parse(json['delivery_date']) : null,
      courier: json['courier'],
      sellingPrice: (json['selling_price'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      productCost: (json['product_cost'] ?? 0).toDouble(),
      courierCost: (json['courier_cost'] ?? 0).toDouble(),
      packagingCost: (json['packaging_cost'] ?? 0).toDouble(),
      adAllocation: (json['ad_allocation'] ?? 0).toDouble(),
      paymentFee: (json['payment_fee'] ?? 0).toDouble(),
      returnCost: (json['return_cost'] ?? 0).toDouble(),
      otherCost: (json['other_cost'] ?? 0).toDouble(),
      isPaymentReceived: json['is_payment_received'] ?? false,
      notes: json['notes'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_id': businessId,
      'order_id_custom': orderIdCustom,
      'customer_name': customerName,
      'phone': phone,
      'status': status,
      'order_date': orderDate?.toIso8601String(),
      'delivery_date': deliveryDate?.toIso8601String(),
      'courier': courier,
      'selling_price': sellingPrice,
      'discount': discount,
      'product_cost': productCost,
      'courier_cost': courierCost,
      'packaging_cost': packagingCost,
      'ad_allocation': adAllocation,
      'payment_fee': paymentFee,
      'return_cost': returnCost,
      'other_cost': otherCost,
      'is_payment_received': isPaymentReceived,
      'notes': notes,
    };
  }
}
