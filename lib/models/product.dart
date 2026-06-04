class Product {
  final String productId;
  final String productName;
  final String specification;
  final int quantityAvailable;
  final double price;
  final DateTime createdAt;

  Product({
    required this.productId,
    required this.productName,
    required this.specification,
    required this.quantityAvailable,
    required this.price,
    required this.createdAt,
  });

  factory Product.fromMap(Map<String, dynamic> data, String documentId) {
    return Product(
      productId: data['product_id'] ?? documentId,
      productName: data['product_name'] ?? data['productName'] ?? '',
      specification: data['specification'] ?? '',
      quantityAvailable:
          data['quantity_available'] ?? data['quantityAvailable'] ?? 0,
      price: (data['price'] ?? 0.0).toDouble(),
      createdAt: _parseDate(data['created_at'] ?? data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'specification': specification,
      'quantity_available': quantityAvailable,
      'price': price,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
