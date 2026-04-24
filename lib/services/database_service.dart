import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/inventory_activity.dart';
import '../models/product.dart';
import '../models/purchase.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<List<Product>> getProducts({String? category}) {
    final stream = category == null
        ? _client
              .from('products')
              .stream(primaryKey: ['id'])
              .order('created_at', ascending: false)
        : _client
              .from('products')
              .stream(primaryKey: ['id'])
              .eq('category', category)
              .order('created_at', ascending: false);

    return stream.map(
      (rows) => rows.map((row) => Product.fromMap(row)).toList(),
    );
  }

  Future<void> addProduct(Product product) async {
    await _client.from('products').insert(product.toInsertMap());
  }

  Future<void> updateProduct(Product product) async {
    await _client
        .from('products')
        .update(product.toUpdateMap())
        .eq('id', product.productId);
  }

  Future<void> deleteProduct(String productId) async {
    await _client.from('products').delete().eq('id', productId);
  }

  Future<void> buyProduct(String userId, Product product, int quantity) async {
    await _client.rpc(
      'purchase_product',
      params: {
        'p_product_id': product.productId,
        'p_user_id': userId,
        'p_quantity': quantity,
      },
    );
  }

  Stream<List<Purchase>> getPersonalPurchases(String userId) {
    return _client
        .from('purchases')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('purchase_date', ascending: false)
        .map((rows) => rows.map((row) => Purchase.fromMap(row)).toList());
  }

  Stream<List<Purchase>> getAllPurchases() {
    return _client
        .from('purchases')
        .stream(primaryKey: ['id'])
        .order('purchase_date', ascending: false)
        .map((rows) => rows.map((row) => Purchase.fromMap(row)).toList());
  }

  Stream<List<InventoryActivity>> getInventoryActivities() {
    return _client
        .from('inventory_activity')
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false)
        .map(
          (rows) => rows.map((row) => InventoryActivity.fromMap(row)).toList(),
        );
  }

  Future<InventoryActivity?> getInventoryActivityForProduct(
    String productId,
  ) async {
    final response = await _client
        .from('inventory_activity')
        .select()
        .eq('product_id', productId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return InventoryActivity.fromMap(response);
  }

  Future<Product?> getProductById(String productId) async {
    final response = await _client
        .from('products')
        .select()
        .eq('id', productId)
        .maybeSingle();
    if (response == null) return null;
    return Product.fromMap(response);
  }

  Future<void> saveInventoryActivity(InventoryActivity activity) async {
    await _client
        .from('inventory_activity')
        .upsert(activity.toUpsertMap(), onConflict: 'product_id');
  }
}
