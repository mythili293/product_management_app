import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_management_app/models/product.dart';
import 'package:product_management_app/screens/dashboard/edit_item_screen.dart';

void main() {
  testWidgets('availability status follows quantity changes', (tester) async {
    final product = Product(
      productId: 'p-1',
      productName: 'Cable Tester',
      specification: 'Checks cable continuity',
      category: 'Electric',
      code: 'ELE-100',
      imageUrl: '',
      quantityAvailable: 0,
      price: 100,
      isAvailable: false,
      createdAt: DateTime(2026, 4, 24),
      updatedAt: DateTime(2026, 4, 24),
    );

    await tester.pumpWidget(
      MaterialApp(home: EditItemScreen(product: product)),
    );

    expect(find.text('Not Available'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(2), '5');
    await tester.pump();

    expect(find.text('Available'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(2), '0');
    await tester.pump();

    expect(find.text('Not Available'), findsOneWidget);
  });
}
