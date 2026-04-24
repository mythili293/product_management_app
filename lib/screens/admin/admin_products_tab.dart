import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';

class AdminProductsTab extends StatelessWidget {
  const AdminProductsTab({super.key});

  void _showAddProductDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final specCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    String category = 'Electric';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Add Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(labelText: 'Code'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  items: const [
                    DropdownMenuItem(
                      value: 'Electric',
                      child: Text('Electric'),
                    ),
                    DropdownMenuItem(
                      value: 'Electronic',
                      child: Text('Electronic'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => category = value);
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: specCtrl,
                  decoration: const InputDecoration(labelText: 'Specification'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: qtyCtrl,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final product = Product(
                  productId: '',
                  productName: nameCtrl.text,
                  specification: specCtrl.text,
                  category: category,
                  code: codeCtrl.text,
                  imageUrl: '',
                  price: double.tryParse(priceCtrl.text) ?? 0.0,
                  quantityAvailable: int.tryParse(qtyCtrl.text) ?? 0,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                await Provider.of<ProductProvider>(
                  context,
                  listen: false,
                ).addProduct(product);
                if (context.mounted) {
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddProductDialog(context),
      ),
      body: StreamBuilder<List<Product>>(
        stream: productProvider.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products available.'));
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product.productName),
                subtitle: Text(
                  'Stock: ${product.quantityAvailable} | \$${product.price}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await productProvider.deleteProduct(product.productId);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
