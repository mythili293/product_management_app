import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../data/mock_data.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descController = TextEditingController();
  
  String _selectedCategory = 'Electric';
  bool _isSubmitting = false;

  void _submitItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      
      // Simulating a short delay for UX
      await Future.delayed(const Duration(milliseconds: 600));
      
      // Actually add to MockData
      final newItem = {
        'title': _nameController.text.trim(),
        'subtitle': _descController.text.trim(),
        'icon': _selectedCategory == 'Electric' ? Icons.electrical_services : Icons.memory,
        'category': _selectedCategory,
        'code': _codeController.text.trim().toUpperCase(),
        'isAvailable': true,
      };
      
      MockData.allItems.add(newItem);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nameController.text} added to inventory!', style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context); // Go back
    }
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
        title: Text('Add New Item', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
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
                Text('Item Specifics', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Item Name',
                  prefixIcon: Icons.extension_outlined,
                  validator: (value) => value!.isEmpty ? 'Item name required' : null,
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _codeController,
                  labelText: 'Item Code (e.g. ELE-102)',
                  prefixIcon: Icons.qr_code_scanner,
                  validator: (value) => value!.isEmpty ? 'Item code required' : null,
                ),
                
                const SizedBox(height: 24),
                Text('Categorization', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryBlue),
                      style: GoogleFonts.inter(color: const Color(0xFF1F2937), fontSize: 15, fontWeight: FontWeight.w600),
                      items: ['Electric', 'Electronic'].map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) setState(() => _selectedCategory = newValue);
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                const SizedBox(height: 24),
                Text('Additional Information', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
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
                      borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(text: 'ADD TO INVENTORY', onPressed: _submitItem),
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
    super.dispose();
  }
}
