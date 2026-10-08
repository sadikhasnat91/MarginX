class BusinessModel {
  final String id;
  final String ownerId;
  final String name;
  final String? category;
  final String? monthlyOrderVolume;
  final String? sellingChannel;
  final String currency;
  final String? logoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BusinessModel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.category,
    this.monthlyOrderVolume,
    this.sellingChannel,
    this.currency = 'BDT',
    this.logoUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'],
      ownerId: json['owner_id'],
      name: json['name'],
      category: json['category'],
      monthlyOrderVolume: json['monthly_order_volume'],
      sellingChannel: json['selling_channel'],
      currency: json['currency'] ?? 'BDT',
      logoUrl: json['logo_url'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owner_id': ownerId,
      'name': name,
      'category': category,
      'monthly_order_volume': monthlyOrderVolume,
      'selling_channel': sellingChannel,
      'currency': currency,
      'logo_url': logoUrl,
    };
  }
}
