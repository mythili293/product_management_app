class PurchaseModel {
  final String purchaseId;
  final String userId;
  final String userName;
  final String userPhone;
  final String productId;
  final String productName;
  final int quantityBought;
  final DateTime purchaseDate;
  final DateTime? returnDueDate;
  final String issuePhotoName;
  final String issuePhotoUrl;
  final bool isReturned;
  final DateTime? returnDate;
  final String returnPhotoName;
  final String returnPhotoUrl;
  final String itemCondition;
  final String damageReason;
  final String damageDescription;
  final String additionalRemarks;
  final String returnedBy;

  PurchaseModel({
    required this.purchaseId,
    required this.userId,
    this.userName = '',
    this.userPhone = '',
    required this.productId,
    required this.productName,
    required this.quantityBought,
    required this.purchaseDate,
    this.returnDueDate,
    this.issuePhotoName = '',
    this.issuePhotoUrl = '',
    this.isReturned = false,
    this.returnDate,
    this.returnPhotoName = '',
    this.returnPhotoUrl = '',
    this.itemCondition = '',
    this.damageReason = '',
    this.damageDescription = '',
    this.additionalRemarks = '',
    this.returnedBy = '',
  });

  factory PurchaseModel.fromMap(Map<String, dynamic> data, String documentId) {
    return PurchaseModel(
      purchaseId: data['purchase_id'] ?? documentId,
      userId: data['user_id'] ?? data['userId'] ?? '',
      userName: data['user_name'] ?? data['userName'] ?? '',
      userPhone: data['user_phone'] ?? data['userPhone'] ?? '',
      productId: data['product_id'] ?? data['productId'] ?? '',
      productName: data['product_name'] ?? data['productName'] ?? '',
      quantityBought: data['quantity_bought'] ?? data['quantityBought'] ?? 0,
      purchaseDate: _parseDate(data['purchase_date'] ?? data['purchaseDate']),
      returnDueDate: _parseNullableDate(
        data['return_due_date'] ?? data['returnDueDate'],
      ),
      issuePhotoName: data['issue_photo_name'] ?? data['issuePhotoName'] ?? '',
      issuePhotoUrl: data['issue_photo_url'] ?? data['issuePhotoUrl'] ?? '',
      isReturned: data['is_returned'] ?? data['isReturned'] ?? false,
      returnDate: _parseNullableDate(data['return_date'] ?? data['returnDate']),
      returnPhotoName:
          data['return_photo_name'] ?? data['returnPhotoName'] ?? '',
      returnPhotoUrl: data['return_photo_url'] ?? data['returnPhotoUrl'] ?? '',
      itemCondition: data['item_condition'] ?? data['itemCondition'] ?? '',
      damageReason: data['damage_reason'] ?? data['damageReason'] ?? '',
      damageDescription:
          data['damage_description'] ?? data['damageDescription'] ?? '',
      additionalRemarks:
          data['additional_remarks'] ?? data['additionalRemarks'] ?? '',
      returnedBy: data['returned_by'] ?? data['returnedBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_phone': userPhone,
      'product_id': productId,
      'product_name': productName,
      'quantity_bought': quantityBought,
      'purchase_date': purchaseDate.toIso8601String(),
      'return_due_date': _formatDateOnly(returnDueDate),
      'issue_photo_name': issuePhotoName,
      'issue_photo_url': issuePhotoUrl,
      'is_returned': isReturned,
      'return_date': returnDate?.toIso8601String(),
      'return_photo_name': returnPhotoName,
      'return_photo_url': returnPhotoUrl,
      'item_condition': itemCondition,
      'damage_reason': damageReason,
      'damage_description': damageDescription,
      'additional_remarks': additionalRemarks,
      'returned_by': returnedBy,
    };
  }

  static DateTime _parseDate(dynamic value) =>
      _parseNullableDate(value) ?? DateTime.now();

  static DateTime? _parseNullableDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static String? _formatDateOnly(DateTime? value) {
    if (value == null) return null;
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
