import 'dart:typed_data';

class Purchase {
  final String purchaseId;
  final String userId;
  final String userName;
  final String userPhone;
  final String productId;
  final String productName;
  final int quantityBought;
  final double totalAmount;
  final DateTime purchaseDate;
  final DateTime? returnDueDate;
  final String issuePhotoName;
  final String issuePhotoSource;
  final Uint8List? issuePhotoBytes;
  final bool isReturned;
  final DateTime? returnDate;
  final String returnPhotoName;
  final String returnPhotoSource;
  final Uint8List? returnPhotoBytes;
  final String itemCondition;
  final String damageReason;
  final String damageDescription;
  final String additionalRemarks;
  final String returnedBy;

  Purchase({
    required this.purchaseId,
    required this.userId,
    this.userName = '',
    this.userPhone = '',
    required this.productId,
    required this.productName,
    required this.quantityBought,
    required this.totalAmount,
    required this.purchaseDate,
    this.returnDueDate,
    this.issuePhotoName = '',
    this.issuePhotoSource = '',
    this.issuePhotoBytes,
    this.isReturned = false,
    this.returnDate,
    this.returnPhotoName = '',
    this.returnPhotoSource = '',
    this.returnPhotoBytes,
    this.itemCondition = '',
    this.damageReason = '',
    this.damageDescription = '',
    this.additionalRemarks = '',
    this.returnedBy = '',
  });

  String get currentStatus => isReturned ? 'Returned' : 'Issued';
  bool get isDamaged => itemCondition == 'Damaged Item';

  Purchase copyWith({
    bool? isReturned,
    DateTime? returnDate,
    DateTime? returnDueDate,
    String? returnPhotoName,
    String? returnPhotoSource,
    Uint8List? returnPhotoBytes,
    String? itemCondition,
    String? damageReason,
    String? damageDescription,
    String? additionalRemarks,
    String? returnedBy,
  }) {
    return Purchase(
      purchaseId: purchaseId,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      productId: productId,
      productName: productName,
      quantityBought: quantityBought,
      totalAmount: totalAmount,
      purchaseDate: purchaseDate,
      returnDueDate: returnDueDate ?? this.returnDueDate,
      issuePhotoName: issuePhotoName,
      issuePhotoSource: issuePhotoSource,
      issuePhotoBytes: issuePhotoBytes,
      isReturned: isReturned ?? this.isReturned,
      returnDate: returnDate ?? this.returnDate,
      returnPhotoName: returnPhotoName ?? this.returnPhotoName,
      returnPhotoSource: returnPhotoSource ?? this.returnPhotoSource,
      returnPhotoBytes: returnPhotoBytes ?? this.returnPhotoBytes,
      itemCondition: itemCondition ?? this.itemCondition,
      damageReason: damageReason ?? this.damageReason,
      damageDescription: damageDescription ?? this.damageDescription,
      additionalRemarks: additionalRemarks ?? this.additionalRemarks,
      returnedBy: returnedBy ?? this.returnedBy,
    );
  }

  factory Purchase.fromMap(Map<String, dynamic> data, String documentId) {
    return Purchase(
      purchaseId: data['purchase_id'] ?? documentId,
      userId: data['user_id'] ?? data['userId'] ?? '',
      userName: data['user_name'] ?? data['userName'] ?? '',
      userPhone: data['user_phone'] ?? data['userPhone'] ?? '',
      productId: data['product_id'] ?? data['productId'] ?? '',
      productName: data['product_name'] ?? data['productName'] ?? '',
      quantityBought: data['quantity_bought'] ?? data['quantityBought'] ?? 0,
      totalAmount: (data['total_amount'] ?? data['totalAmount'] ?? 0.0)
          .toDouble(),
      purchaseDate: _parseDate(data['purchase_date'] ?? data['purchaseDate']),
      returnDueDate: _parseNullableDate(
        data['return_due_date'] ?? data['returnDueDate'],
      ),
      issuePhotoName: data['issue_photo_name'] ?? data['issuePhotoName'] ?? '',
      issuePhotoSource:
          data['issue_photo_url'] ??
          data['issuePhotoSource'] ??
          data['issue_photo_source'] ??
          '',
      isReturned: data['is_returned'] ?? data['isReturned'] ?? false,
      returnDate: _parseNullableDate(data['return_date'] ?? data['returnDate']),
      returnPhotoName:
          data['return_photo_name'] ?? data['returnPhotoName'] ?? '',
      returnPhotoSource:
          data['return_photo_url'] ??
          data['returnPhotoSource'] ??
          data['return_photo_source'] ??
          '',
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
      'purchase_id': purchaseId,
      'user_id': userId,
      'user_name': userName,
      'user_phone': userPhone,
      'product_id': productId,
      'product_name': productName,
      'quantity_bought': quantityBought,
      'total_amount': totalAmount,
      'purchase_date': purchaseDate.toIso8601String(),
      'return_due_date': _formatDateOnly(returnDueDate),
      'issue_photo_name': issuePhotoName,
      'issue_photo_url': issuePhotoSource,
      'is_returned': isReturned,
      'return_date': returnDate?.toIso8601String(),
      'return_photo_name': returnPhotoName,
      'return_photo_url': returnPhotoSource,
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
