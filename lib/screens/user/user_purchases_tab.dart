import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/purchase.dart';
import 'package:intl/intl.dart';

class UserPurchasesTab extends StatelessWidget {
  const UserPurchasesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();
    final uid = Provider.of<AuthProvider>(context, listen: false).appUser!.userId;

    return StreamBuilder<List<Purchase>>(
      stream: dbService.getPersonalPurchases(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('You have not made any purchases yet.'));
        }

        final purchases = snapshot.data!;
        return ListView.builder(
          itemCount: purchases.length,
          itemBuilder: (context, index) {
            final purchase = purchases[index];
            final dateStr = DateFormat('MMM d, yyyy h:mm a').format(purchase.purchaseDate);
            return ListTile(
              leading: const Icon(Icons.shopping_bag_outlined),
              title: Text('${purchase.productName} (x${purchase.quantityBought})'),
              subtitle: Text(dateStr),
              trailing: Text('\$${purchase.totalAmount.toStringAsFixed(2)}', 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            );
          },
        );
      },
    );
  }
}
