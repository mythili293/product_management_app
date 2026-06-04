import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/product_model.dart';
import '../models/purchase_model.dart';
import '../services/database_service.dart';

class AdminProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  Future<void> addProduct(ProductModel product) async {
    await _dbService.addProduct(
      Product(
        productId: product.productId,
        productName: product.productName,
        specification: product.description,
        quantityAvailable: product.quantityAvailable,
        price: product.price,
        createdAt: product.createdAt,
      ),
    );
  }

  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    await _dbService.updateProductFields(productId, data);
  }

  Future<void> deleteProduct(String productId) async {
    await _dbService.deleteProduct(productId);
  }

  Stream<List<PurchaseModel>> getAllPurchases() {
    return _dbService.getAllPurchases().map(
      (purchases) => purchases
          .map(
            (purchase) => PurchaseModel(
              purchaseId: purchase.purchaseId,
              userId: purchase.userId,
              userName: purchase.userName,
              userPhone: purchase.userPhone,
              productId: purchase.productId,
              productName: purchase.productName,
              quantityBought: purchase.quantityBought,
              purchaseDate: purchase.purchaseDate,
              returnDueDate: purchase.returnDueDate,
              issuePhotoName: purchase.issuePhotoName,
              issuePhotoUrl: purchase.issuePhotoSource,
              isReturned: purchase.isReturned,
              returnDate: purchase.returnDate,
              returnPhotoName: purchase.returnPhotoName,
              returnPhotoUrl: purchase.returnPhotoSource,
              itemCondition: purchase.itemCondition,
              damageReason: purchase.damageReason,
              damageDescription: purchase.damageDescription,
              additionalRemarks: purchase.additionalRemarks,
              returnedBy: purchase.returnedBy,
            ),
          )
          .toList(),
    );
  }
}
