class ProductModel {
  final String id;
  final String businessId;
  final String name;
  final String? sku;
  final String? category;
  final double sellingPrice;
  final double productCost;
  final double packagingCost;
  final double defaultDiscount;
  final int stockQuantity;
  final bool isActive;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.businessId,
    required this.name,
    this.sku,
    this.category,
    this.sellingPrice = 0.0,
    this.productCost = 0.0,
    this.packagingCost = 0.0,
    this.defaultDiscount = 0.0,
    this.stockQuantity = 0,
    this.isActive = true,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      businessId: json['business_id'],
      name: json['name'],
      sku: json['sku'],
      category: json['category'],
      sellingPrice: (json['selling_price'] ?? 0).toDouble(),
      productCost: (json['product_cost'] ?? 0).toDouble(),
      packagingCost: (json['packaging_cost'] ?? 0).toDouble(),
      defaultDiscount: (json['default_discount'] ?? 0).toDouble(),
      stockQuantity: json['stock_quantity'] ?? 0,
      isActive: json['is_active'] ?? true,
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_id': businessId,
      'name': name,
      'sku': sku,
      'category': category,
      'selling_price': sellingPrice,
      'product_cost': productCost,
      'packaging_cost': packagingCost,
      'default_discount': defaultDiscount,
      'stock_quantity': stockQuantity,
      'is_active': isActive,
      'image_url': imageUrl,
    };
  }
}
