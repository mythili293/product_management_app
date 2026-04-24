import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/purchase.dart';
import 'package:intl/intl.dart';

class AdminPurchasesTab extends StatelessWidget {
  const AdminPurchasesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();

    return StreamBuilder<List<Purchase>>(
      stream: dbService.getAllPurchases(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No purchase history.'));
        }

        final purchases = snapshot.data!;
        return ListView.builder(
          itemCount: purchases.length,
          itemBuilder: (context, index) {
            final purchase = purchases[index];
            final dateStr = DateFormat(
              'MMM d, yyyy h:mm a',
            ).format(purchase.purchaseDate);
            return ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: Text(
                '${purchase.productName} (x${purchase.quantityBought})',
              ),
              subtitle: Text('Buyer UID: ${purchase.userId}\n$dateStr'),
              trailing: Text(
                '\$${purchase.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              isThreeLine: true,
            );
          },
        );
      },
    );
  }
}
