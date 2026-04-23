import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import 'edit_item_screen.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final String categoryName;

  const ItemDetailsScreen({super.key, required this.item, required this.categoryName});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  late Map<String, dynamic> _item;

  @override
  void initState() {
    super.initState();
    _item = Map.from(widget.item);
  }

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = _item['isAvailable'] ?? true;
    final String categoryCode = widget.categoryName.substring(0, 3).toUpperCase();
    final String itemCode = _item['code'] ?? '$categoryCode-001';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Item Details', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditItemScreen(item: _item, categoryName: widget.categoryName)),
              );
              if (result != null && result is Map<String, dynamic>) {
                setState(() => _item = result);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Arch header
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
                  // Hero Icon Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: widget.categoryName == 'Electric' ? const Color(0xFFDCFCE7) : const Color(0xFFE0E7FF),
                          child: Icon(
                            _item['icon'] as IconData? ?? Icons.inventory_2,
                            size: 36,
                            color: widget.categoryName == 'Electric' ? const Color(0xFF16A34A) : AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(_item['title'] ?? 'Unknown Item', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 22, color: const Color(0xFF1F2937))),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(itemCode, style: GoogleFonts.inter(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Details Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Item Information', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF1F2937))),
                        const SizedBox(height: 16),
                        _infoRow(Icons.label_outline, 'Item Name', _item['title'] ?? '—'),
                        const Divider(height: 24, color: Color(0xFFF3F4F6)),
                        _infoRow(Icons.qr_code_2, 'Item Code', itemCode),
                        const Divider(height: 24, color: Color(0xFFF3F4F6)),
                        _infoRow(Icons.category_outlined, 'Category', widget.categoryName),
                        const Divider(height: 24, color: Color(0xFFF3F4F6)),
                        _infoRow(Icons.description_outlined, 'Description', _item['subtitle'] ?? 'No description available.'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Availability Status Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isAvailable ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isAvailable ? Icons.check_circle_outline : Icons.cancel_outlined,
                            color: isAvailable ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Availability Status', style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text(
                                isAvailable ? 'Available' : 'Not Available',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isAvailable ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isAvailable ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isAvailable ? 'In Stock' : 'Taken',
                            style: GoogleFonts.inter(
                              color: isAvailable ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Edit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditItemScreen(item: _item, categoryName: widget.categoryName)),
                        );
                        if (result != null && result is Map<String, dynamic>) {
                          if (result['deleted'] == true) {
                            Navigator.pop(context, {'deleted': true});
                          } else {
                            setState(() => _item = result);
                          }
                        }
                      },
                      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                      label: Text('Edit Item', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              Text(label, style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value, style: GoogleFonts.inter(color: const Color(0xFF1F2937), fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
