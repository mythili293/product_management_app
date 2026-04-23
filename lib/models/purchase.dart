class Purchase {
  final String purchaseId;
  final String userId;
  final String productId;
  final String productName;
  final int quantityBought;
  final double totalAmount;
  final DateTime purchaseDate;

  const Purchase({
    required this.purchaseId,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.quantityBought,
    required this.totalAmount,
    required this.purchaseDate,
  });

  factory Purchase.fromMap(Map<String, dynamic> data) {
    return Purchase(
      purchaseId: data['id']?.toString() ?? data['purchaseId']?.toString() ?? '',
      userId: data['user_id']?.toString() ?? data['userId']?.toString() ?? '',
      productId:
          data['product_id']?.toString() ?? data['productId']?.toString() ?? '',
      productName: data['product_name']?.toString() ??
          data['productName']?.toString() ??
          '',
      quantityBought:
          data['quantity_bought'] as int? ?? data['quantityBought'] as int? ?? 0,
      totalAmount: (data['total_amount'] as num?)?.toDouble() ??
          (data['totalAmount'] as num?)?.toDouble() ??
          0,
      purchaseDate:
          DateTime.tryParse(data['purchase_date']?.toString() ?? '')?.toLocal() ??
              DateTime.tryParse(data['purchaseDate']?.toString() ?? '')
                  ?.toLocal() ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'product_id': productId,
      'product_name': productName,
      'quantity_bought': quantityBought,
      'total_amount': totalAmount,
      'purchase_date': purchaseDate.toUtc().toIso8601String(),
    };
  }
}
