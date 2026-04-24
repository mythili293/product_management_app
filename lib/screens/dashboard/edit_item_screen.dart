import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class EditItemScreen extends StatefulWidget {
  final Product product;

  const EditItemScreen({super.key, required this.product});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _descController;
  late TextEditingController _qtyController;
  late TextEditingController _priceController;

  late String _selectedCategory;
  late bool _isAvailable;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.productName);
    _codeController = TextEditingController(text: widget.product.code);
    _descController = TextEditingController(text: widget.product.specification);
    _qtyController = TextEditingController(
      text: widget.product.quantityAvailable.toString(),
    );
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    _selectedCategory = widget.product.category;
    _isAvailable = widget.product.isAvailable;
  }

  Future<void> _submitItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      var quantity = int.parse(_qtyController.text.trim());
      if (!_isAvailable) {
        quantity = 0;
      } else if (quantity == 0) {
        quantity = 1;
      }

      final updatedProduct = widget.product.copyWith(
        productName: _nameController.text.trim(),
        specification: _descController.text.trim(),
        category: _selectedCategory,
        code: _codeController.text.trim().toUpperCase(),
        quantityAvailable: quantity,
        price: double.parse(_priceController.text.trim()),
        updatedAt: DateTime.now(),
      );

      await Provider.of<ProductProvider>(
        context,
        listen: false,
      ).updateProduct(updatedProduct);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Item successfully updated!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, updatedProduct);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _deleteItem() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            'Delete Item',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to permanently delete "${widget.product.productName}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: Colors.grey.shade600),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await Provider.of<ProductProvider>(
                  context,
                  listen: false,
                ).deleteProduct(widget.product.productId);
                if (!mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${widget.product.productName} deleted successfully!',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.pop(context, true);
              },
              child: Text(
                'Delete',
                style: GoogleFonts.inter(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Item',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Text(
                  'Modification Specifics',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Item Name',
                  prefixIcon: Icons.extension_outlined,
                  validator: (value) =>
                      value!.isEmpty ? 'Item name required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _codeController,
                  labelText: 'Item Code',
                  prefixIcon: Icons.qr_code_scanner,
                  validator: (value) =>
                      value!.isEmpty ? 'Item code required' : null,
                ),
                const SizedBox(height: 24),
                Text(
                  'Categorization',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppTheme.primaryBlue,
                      ),
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1F2937),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
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
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() => _selectedCategory = newValue);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _qtyController,
                  labelText: 'Quantity',
                  prefixIcon: Icons.numbers,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Quantity required';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _priceController,
                  labelText: 'Price',
                  prefixIcon: Icons.currency_rupee,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Price required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: _isAvailable
                                ? const Color(0xFF16A34A)
                                : Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _isAvailable ? 'Available' : 'Not Available',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        activeThumbColor: const Color(0xFF16A34A),
                        inactiveThumbColor: Colors.red,
                        inactiveTrackColor: Colors.red.shade200,
                        value: _isAvailable,
                        onChanged: (value) {
                          setState(() {
                            _isAvailable = value;
                            if (!_isAvailable) {
                              _qtyController.text = '0';
                            } else if (_qtyController.text.trim() == '0') {
                              _qtyController.text = '1';
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Additional Information',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  style: GoogleFonts.inter(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Enter specifications or arbitrary details...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryBlue,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _isSubmitting
                    ? const Center(child: CircularProgressIndicator())
                    : PrimaryButton(
                        text: 'SAVE CHANGES',
                        onPressed: _submitItem,
                      ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _deleteItem,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'DELETE ITEM',
                      style: GoogleFonts.inter(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
