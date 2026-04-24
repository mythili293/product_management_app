import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/primary_button.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;
  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl,
      _descCtrl,
      _categoryCtrl,
      _imageUrlCtrl,
      _qtyCtrl,
      _priceCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product?.productName ?? '');
    _descCtrl = TextEditingController(
      text: widget.product?.specification ?? '',
    );
    _categoryCtrl = TextEditingController(text: widget.product?.category ?? '');
    _imageUrlCtrl = TextEditingController(text: widget.product?.imageUrl ?? '');
    _qtyCtrl = TextEditingController(
      text: widget.product?.quantityAvailable.toString() ?? '',
    );
    _priceCtrl = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    try {
      final quantity = int.parse(_qtyCtrl.text.trim());

      if (widget.product == null) {
        final newProduct = Product(
          productId: '',
          productName: _nameCtrl.text.trim(),
          specification: _descCtrl.text.trim(),
          category: _categoryCtrl.text.trim(),
          code: _nameCtrl.text.trim().toUpperCase().replaceAll(' ', '-'),
          imageUrl: _imageUrlCtrl.text.trim(),
          quantityAvailable: quantity,
          price: double.parse(_priceCtrl.text.trim()),
          isAvailable: Product.isAvailableForQuantity(quantity),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await adminProvider.addProduct(newProduct);
      } else {
        await adminProvider.updateProduct(
          widget.product!.copyWith(
            productName: _nameCtrl.text.trim(),
            specification: _descCtrl.text.trim(),
            category: _categoryCtrl.text.trim(),
            imageUrl: _imageUrlCtrl.text.trim(),
            quantityAvailable: quantity,
            price: double.parse(_priceCtrl.text.trim()),
            isAvailable: Product.isAvailableForQuantity(quantity),
            updatedAt: DateTime.now(),
          ),
        );
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _delete() async {
    if (widget.product == null) return;
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    setState(() => _isLoading = true);
    try {
      await adminProvider.deleteProduct(widget.product!.productId);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        actions: widget.product != null
            ? [IconButton(icon: const Icon(Icons.delete), onPressed: _delete)]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _categoryCtrl,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _imageUrlCtrl,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _qtyCtrl,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                PrimaryButton(text: 'Save', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
