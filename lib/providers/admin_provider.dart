import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/purchase.dart';
import '../services/database_service.dart';

class AdminProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  Future<void> addProduct(Product product) async {
    await _dbService.addProduct(product);
  }

  Future<void> updateProduct(Product product) async {
    await _dbService.updateProduct(product);
  }

  Future<void> deleteProduct(String productId) async {
    await _dbService.deleteProduct(productId);
  }

  Stream<List<Purchase>> getAllPurchases() {
    return _dbService.getAllPurchases();
  }
}
