import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/purchase.dart';
import '../../providers/admin_provider.dart';
import 'package:intl/intl.dart';

class AllPurchasesScreen extends StatelessWidget {
  const AllPurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Global Purchase History')),
      body: StreamBuilder<List<Purchase>>(
        stream: adminProvider.getAllPurchases(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No purchases yet.'));
          }

          final purchases = snapshot.data!;
          return ListView.builder(
            itemCount: purchases.length,
            itemBuilder: (context, index) {
              final p = purchases[index];
              return ListTile(
                title: Text('${p.productName} (x${p.quantityBought})'),
                subtitle: Text(
                  'User: ${p.userId}\nDate: ${DateFormat.yMd().add_jm().format(p.purchaseDate)}',
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
