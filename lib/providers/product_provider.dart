import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  Stream<List<Product>> getProducts({String? category}) {
    return _dbService.getProducts(category: category);
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

  Future<bool> buyProduct(String userId, Product product, int quantity) async {
    try {
      await _dbService.buyProduct(userId, product, quantity);
      return true;
    } catch (e) {
      return false;
    }
  }
}
