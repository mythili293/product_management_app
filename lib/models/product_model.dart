class ProductModel {
  final String productId;
  final String productName;
  final String description;
  final String category;
  final String imageUrl;
  final int quantityAvailable;
  final double price;
  final DateTime createdAt;

  ProductModel({
    required this.productId,
    required this.productName,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.quantityAvailable,
    required this.price,
    required this.createdAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ProductModel(
      productId: data['product_id'] ?? documentId,
      productName: data['product_name'] ?? data['productName'] ?? '',
      description: data['description'] ?? data['specification'] ?? '',
      category: data['category'] ?? 'General',
      imageUrl: data['image_url'] ?? data['imageUrl'] ?? '',
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
      'specification': description,
      'category': category,
      'image_url': imageUrl,
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
