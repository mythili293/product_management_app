import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../services/database_service.dart';
import '../models/product.dart';
import '../models/purchase.dart';

class ProductProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  Stream<List<Product>> getProducts() {
    return _dbService.getProducts();
  }

  Stream<List<Purchase>> getPersonalPurchases(String userId) {
    return _dbService.getPersonalPurchases(userId);
  }

  Future<void> addProduct(Product product) async {
    await _dbService.addProduct(product);
  }

  Future<void> updateProduct(Product product) async {
    await _dbService.updateProduct(product);
  }

  Future<void> deleteProduct(String productId) async {
    await _dbService.deleteProduct(productId);
  }

  Future<bool> buyProduct(
    String userId,
    Product product,
    int quantity, {
    String userName = '',
    String userPhone = '',
    String issuePhotoName = '',
    String issuePhotoSource = '',
    Uint8List? issuePhotoBytes,
  }) async {
    try {
      await _dbService.buyProduct(
        userId,
        product,
        quantity,
        userName: userName,
        userPhone: userPhone,
        issuePhotoName: issuePhotoName,
        issuePhotoSource: issuePhotoSource,
        issuePhotoBytes: issuePhotoBytes,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
