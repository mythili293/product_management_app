import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';
import '../models/purchase.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<List<Product>> getProducts() {
    return _client.from('products').stream(primaryKey: ['product_id']).map((
      rows,
    ) {
      final products = rows
          .map((row) => Product.fromMap(row, '${row['product_id'] ?? ''}'))
          .toList();
      products.sort(
        (first, second) => first.productName.compareTo(second.productName),
      );
      return products;
    });
  }

  Future<void> addProduct(Product product) async {
    final productId = product.productId.trim().isEmpty
        ? _generateProductId(product.productName)
        : product.productId.trim();

    await _client.from('products').insert({
      'product_id': productId,
      'product_name': product.productName.trim(),
      'specification': product.specification.trim(),
      'quantity_available': product.quantityAvailable,
      'price': product.price,
    });
  }

  Future<void> updateProduct(Product product) async {
    await _client
        .from('products')
        .update({
          'product_name': product.productName.trim(),
          'specification': product.specification.trim(),
          'quantity_available': product.quantityAvailable,
          'price': product.price,
        })
        .eq('product_id', product.productId);
  }

  Future<void> updateProductFields(
    String productId,
    Map<String, dynamic> data,
  ) async {
    final mappedData = <String, dynamic>{};
    if (data.containsKey('productName')) {
      mappedData['product_name'] = data['productName'];
    }
    if (data.containsKey('description')) {
      mappedData['specification'] = data['description'];
    }
    if (data.containsKey('specification')) {
      mappedData['specification'] = data['specification'];
    }
    if (data.containsKey('quantityAvailable')) {
      mappedData['quantity_available'] = data['quantityAvailable'];
    }
    if (data.containsKey('price')) mappedData['price'] = data['price'];

    data.forEach((key, value) {
      if (key.contains('_')) mappedData[key] = value;
    });

    if (mappedData.isEmpty) return;
    await _client
        .from('products')
        .update(mappedData)
        .eq('product_id', productId);
  }

  Future<void> deleteProduct(String productId) async {
    await _client.from('products').delete().eq('product_id', productId);
  }

  Future<void> deletePurchase(String purchaseId) async {
    await _client.from('purchases').delete().eq('purchase_id', purchaseId);
  }

  Future<void> buyProduct(
    String userId,
    Product product,
    int quantity, {
    String userName = '',
    String userPhone = '',
    String issuePhotoName = '',
    String issuePhotoSource = '',
    Uint8List? issuePhotoBytes,
  }) async {
    final issuePhotoUrl = await _uploadPhotoIfNeeded(
      bucket: 'issue-photos',
      fileName: issuePhotoName,
      fallbackPath: issuePhotoSource,
      bytes: issuePhotoBytes,
    );

    await _client.rpc(
      'issue_product',
      params: {
        'p_product_id': product.productId,
        'p_quantity': quantity,
        'p_user_name': userName,
        'p_user_phone': userPhone,
        'p_issue_photo_name': issuePhotoName,
        'p_issue_photo_url': issuePhotoUrl,
      },
    );
  }

  Future<void> returnPurchase(
    String purchaseId, {
    required String returnedBy,
    required String itemCondition,
    required String returnPhotoName,
    required String returnPhotoSource,
    required Uint8List? returnPhotoBytes,
    String damageReason = '',
    String damageDescription = '',
    String additionalRemarks = '',
  }) async {
    final returnPhotoUrl = await _uploadPhotoIfNeeded(
      bucket: 'return-photos',
      fileName: returnPhotoName,
      fallbackPath: returnPhotoSource,
      bytes: returnPhotoBytes,
    );

    await _client.rpc(
      'return_purchase',
      params: {
        'p_purchase_id': purchaseId,
        'p_returned_by': returnedBy,
        'p_item_condition': itemCondition,
        'p_return_photo_name': returnPhotoName,
        'p_return_photo_url': returnPhotoUrl,
        'p_damage_reason': damageReason,
        'p_damage_description': damageDescription,
        'p_additional_remarks': additionalRemarks,
      },
    );
  }

  Stream<List<Purchase>> getPersonalPurchases(String userId) {
    return _client
        .from('purchases')
        .stream(primaryKey: ['purchase_id'])
        .eq('user_id', userId)
        .map(_mapPurchases);
  }

  Stream<List<Purchase>> getAllPurchases() {
    return _client
        .from('purchases')
        .stream(primaryKey: ['purchase_id'])
        .map(_mapPurchases);
  }

  List<Purchase> _mapPurchases(List<Map<String, dynamic>> rows) {
    final purchases = rows
        .map((row) => Purchase.fromMap(row, '${row['purchase_id'] ?? ''}'))
        .toList();
    purchases.sort((first, second) {
      return second.purchaseDate.compareTo(first.purchaseDate);
    });
    return purchases;
  }

  Future<String> _uploadPhotoIfNeeded({
    required String bucket,
    required String fileName,
    required String fallbackPath,
    required Uint8List? bytes,
  }) async {
    if (bytes == null || fileName.trim().isEmpty) return fallbackPath;

    final userId = _client.auth.currentUser?.id ?? 'anonymous';
    final extension = fileName.contains('.') ? fileName.split('.').last : 'jpg';
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}.$extension';

    await _client.storage
        .from(bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return path;
  }

  String _generateProductId(String productName) {
    final prefix = productName
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    final safeLength = prefix.length < 12 ? prefix.length : 12;
    final safePrefix = prefix.isEmpty ? 'PRD' : prefix.substring(0, safeLength);
    return '$safePrefix-${DateTime.now().millisecondsSinceEpoch}';
  }
}
