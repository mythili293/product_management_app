import 'model_utils.dart';
import 'product.dart';

class InventoryActivity {
  final String activityId;
  final String productId;
  final String itemName;
  final String itemCode;
  final String category;
  final String assignedToName;
  final String assignedRole;
  final String contact;
  final DateTime? takenAt;
  final DateTime? returnedAt;
  final String status;
  final bool? isReturnable;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InventoryActivity({
    required this.activityId,
    required this.productId,
    required this.itemName,
    required this.itemCode,
    required this.category,
    required this.assignedToName,
    required this.assignedRole,
    required this.contact,
    required this.takenAt,
    required this.returnedAt,
    required this.status,
    required this.isReturnable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InventoryActivity.fromMap(Map<String, dynamic> data) {
    final now = DateTime.now();
    return InventoryActivity(
      activityId: normalizeText(
        data['id'],
        fallback: normalizeText(data['activity_id']),
      ),
      productId: normalizeText(data['product_id']),
      itemName: normalizeText(
        data['item_name'],
        fallback: normalizeText(data['product_name']),
      ),
      itemCode: normalizeText(data['item_code']),
      category: normalizeText(data['category'], fallback: 'Electric'),
      assignedToName: normalizeText(
        data['assigned_to_name'],
        fallback: 'No User Assigned',
      ),
      assignedRole: normalizeText(
        data['assigned_role'],
        fallback: 'Unspecified',
      ),
      contact: normalizeText(data['contact']),
      takenAt: parseDateTimeValue(data['taken_at']),
      returnedAt: parseDateTimeValue(data['returned_at']),
      status: normalizeText(data['status'], fallback: 'Not Returned'),
      isReturnable: data['is_returnable'] as bool?,
      createdAt: parseDateTimeValue(data['created_at']) ?? now,
      updatedAt: parseDateTimeValue(data['updated_at']) ?? now,
    );
  }

  factory InventoryActivity.emptyForProduct(Product product) {
    final now = DateTime.now();
    return InventoryActivity(
      activityId: '',
      productId: product.productId,
      itemName: product.productName,
      itemCode: product.code,
      category: product.category,
      assignedToName: 'No User Assigned',
      assignedRole: 'Unspecified',
      contact: '',
      takenAt: null,
      returnedAt: null,
      status: 'Not Returned',
      isReturnable: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  InventoryActivity copyWith({
    String? activityId,
    String? productId,
    String? itemName,
    String? itemCode,
    String? category,
    String? assignedToName,
    String? assignedRole,
    String? contact,
    DateTime? takenAt,
    DateTime? returnedAt,
    String? status,
    bool? isReturnable,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearTakenAt = false,
    bool clearReturnedAt = false,
    bool clearIsReturnable = false,
  }) {
    return InventoryActivity(
      activityId: activityId ?? this.activityId,
      productId: productId ?? this.productId,
      itemName: itemName ?? this.itemName,
      itemCode: itemCode ?? this.itemCode,
      category: category ?? this.category,
      assignedToName: assignedToName ?? this.assignedToName,
      assignedRole: assignedRole ?? this.assignedRole,
      contact: contact ?? this.contact,
      takenAt: clearTakenAt ? null : takenAt ?? this.takenAt,
      returnedAt: clearReturnedAt ? null : returnedAt ?? this.returnedAt,
      status: status ?? this.status,
      isReturnable: clearIsReturnable ? null : isReturnable ?? this.isReturnable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toUpsertMap() {
    return {
      'product_id': productId,
      'item_name': itemName,
      'item_code': itemCode,
      'category': category,
      'assigned_to_name': assignedToName,
      'assigned_role': assignedRole,
      'contact': contact,
      'taken_at': takenAt?.toUtc().toIso8601String(),
      'returned_at': returnedAt?.toUtc().toIso8601String(),
      'status': status,
      'is_returnable': isReturnable,
    };
  }
}
