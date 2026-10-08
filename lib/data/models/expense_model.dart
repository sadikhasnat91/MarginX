class ExpenseModel {
  final String id;
  final String businessId;
  final double amount;
  final String category;
  final DateTime date;
  final String? description;
  final String? attachmentUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ExpenseModel({
    required this.id,
    required this.businessId,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
    this.attachmentUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      businessId: json['business_id'],
      amount: (json['amount'] ?? 0).toDouble(),
      category: json['category'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      attachmentUrl: json['attachment_url'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_id': businessId,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String().split('T')[0], // Store only the date part
      'description': description,
      'attachment_url': attachmentUrl,
    };
  }
}
