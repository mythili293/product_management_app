import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';
import '../../models/product.dart';
import '../../services/database_service.dart';
import 'dashboard_helpers.dart';
import 'edit_item_screen.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Product product;

  const ItemDetailsScreen({super.key, required this.product});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  late Product _product;
  final _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  /// Re-fetch the product from Supabase so the detail screen
  /// always reflects the real DB value (including is_available).
  Future<void> _refreshProduct() async {
    try {
      final rows = await _db.getProductById(_product.productId);
      if (rows != null && mounted) {
        setState(() => _product = rows);
      }
    } catch (_) {
      // If re-fetch fails, keep whatever the edit screen returned.
    }
  }

  @override
  Widget build(BuildContext context) {
    final isElectric = DashboardHelpers.isElectricCategory(_product.category);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Item Details',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditItemScreen(product: _product),
                ),
              );
              if (!context.mounted) return;
              if (result is bool && result) {
                Navigator.pop(context, true);
              } else if (result is Product) {
                // Re-fetch from DB to get the real is_available value
                await _refreshProduct();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 40,
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: isElectric
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFE0E7FF),
                          child: Icon(
                            DashboardHelpers.categoryIcon(_product.category),
                            size: 36,
                            color: isElectric
                                ? const Color(0xFF16A34A)
                                : AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _product.productName,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _product.code,
                            style: GoogleFonts.inter(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Item Information',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _infoRow(
                          Icons.label_outline,
                          'Item Name',
                          _product.productName,
                        ),
                        const Divider(height: 24, color: Color(0xFFF3F4F6)),
                        _infoRow(Icons.qr_code_2, 'Item Code', _product.code),
                        const Divider(height: 24, color: Color(0xFFF3F4F6)),
                        _infoRow(
                          Icons.category_outlined,
                          'Category',
                          _product.category,
                        ),
                        const Divider(height: 24, color: Color(0xFFF3F4F6)),
                        _infoRow(
                          Icons.description_outlined,
                          'Description',
                          _product.specification,
                        ),
                        const Divider(height: 24, color: Color(0xFFF3F4F6)),
                        _infoRow(
                          Icons.currency_rupee,
                          'Price',
                          _product.price.toStringAsFixed(2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _product.isAvailable
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _product.isAvailable
                                ? Icons.check_circle_outline
                                : Icons.cancel_outlined,
                            color: _product.isAvailable
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Availability Status',
                                style: GoogleFonts.inter(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _product.isAvailable
                                    ? 'Available'
                                    : 'Not Available',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: _product.isAvailable
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFDC2626),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _product.isAvailable
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_product.quantityAvailable} in stock',
                            style: GoogleFonts.inter(
                              color: _product.isAvailable
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFDC2626),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditItemScreen(product: _product),
                          ),
                        );
                        if (!context.mounted) return;
                        if (result is bool && result) {
                          Navigator.pop(context, true);
                        } else if (result is Product) {
                          // Re-fetch from DB to get the real is_available value
                          await _refreshProduct();
                        }
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        'Edit Item',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: const Color(0xFF1F2937),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
