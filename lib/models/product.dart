class Product {
  final String productId;
  final String productName;
  final String specification;
  final String category;
  final String code;
  final String imageUrl;
  final int quantityAvailable;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.productId,
    required this.productName,
    required this.specification,
    required this.category,
    required this.code,
    required this.imageUrl,
    required this.quantityAvailable,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromMap(Map<String, dynamic> data) {
    final createdAt =
        DateTime.tryParse(data['created_at']?.toString() ?? '')?.toLocal() ??
        DateTime.tryParse(data['createdAt']?.toString() ?? '')?.toLocal() ??
        DateTime.now();
    final updatedAt =
        DateTime.tryParse(data['updated_at']?.toString() ?? '')?.toLocal() ??
        DateTime.tryParse(data['updatedAt']?.toString() ?? '')?.toLocal() ??
        createdAt;

    return Product(
      productId: data['id']?.toString() ?? data['productId']?.toString() ?? '',
      productName:
          data['product_name']?.toString() ??
          data['productName']?.toString() ??
          '',
      specification: data['specification']?.toString() ?? '',
      category: data['category']?.toString() ?? 'Electric',
      code: data['code']?.toString() ?? '',
      imageUrl:
          data['image_url']?.toString() ?? data['imageUrl']?.toString() ?? '',
      quantityAvailable:
          data['quantity_available'] as int? ??
          data['quantityAvailable'] as int? ??
          0,
      price: (data['price'] as num?)?.toDouble() ?? 0,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Product copyWith({
    String? productId,
    String? productName,
    String? specification,
    String? category,
    String? code,
    String? imageUrl,
    int? quantityAvailable,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      specification: specification ?? this.specification,
      category: category ?? this.category,
      code: code ?? this.code,
      imageUrl: imageUrl ?? this.imageUrl,
      quantityAvailable: quantityAvailable ?? this.quantityAvailable,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isAvailable => quantityAvailable > 0;

  Map<String, dynamic> toInsertMap() {
    return {
      'product_name': productName,
      'specification': specification,
      'category': category,
      'code': code,
      'image_url': imageUrl.isEmpty ? null : imageUrl,
      'quantity_available': quantityAvailable,
      'price': price,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'product_name': productName,
      'specification': specification,
      'category': category,
      'code': code,
      'image_url': imageUrl.isEmpty ? null : imageUrl,
      'quantity_available': quantityAvailable,
      'price': price,
    };
  }
}
