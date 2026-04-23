import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../data/mock_data.dart';

class EditItemScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final String categoryName;

  const EditItemScreen({
    super.key,
    required this.item,
    required this.categoryName,
  });

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _descController;
  
  late String _selectedCategory;
  late bool _isAvailable;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item['title']);
    _codeController = TextEditingController(text: '${widget.categoryName.substring(0, 3).toUpperCase()}-001');
    _descController = TextEditingController(text: widget.item['subtitle'] ?? 'Measures and monitors values in industrial applications.');
    _selectedCategory = widget.categoryName;
    _isAvailable = widget.item['isAvailable'] ?? true;
  }

  void _submitItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      
      // Simulate network save
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item successfully updated!', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Return updated state
      Map<String, dynamic> updatedItem = Map.from(widget.item);
      updatedItem['title'] = _nameController.text;
      updatedItem['subtitle'] = _descController.text;
      updatedItem['isAvailable'] = _isAvailable;
      
      Navigator.pop(context, updatedItem);
    }
  }

  void _deleteItem() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('Delete Item', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to permanently delete "${widget.item['title']}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey.shade600)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // close dialog
                
                // Remove from MockData
                MockData.allItems.removeWhere((item) => 
                  item['title'] == widget.item['title'] && 
                  item['category'] == widget.categoryName
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${widget.item['title']} deleted successfully!'),
                    backgroundColor: Colors.red,
                  ),
                );
                
                Navigator.pop(context, {'deleted': true});
              },
              child: Text('Delete', style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.bold)),
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
        title: Text('Edit Item', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
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
                Text('Modification Specifics', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
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
                  labelText: 'Item Code',
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
                      value: ['Electric', 'Electronic', 'Tools', 'Mechanical'].contains(_selectedCategory) ? _selectedCategory : 'Electric',
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryBlue),
                      style: GoogleFonts.inter(color: const Color(0xFF1F2937), fontSize: 15, fontWeight: FontWeight.w600),
                      items: ['Electric', 'Electronic', 'Tools', 'Mechanical'].map((String category) {
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
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          Icon(Icons.check_circle_outline, color: _isAvailable ? const Color(0xFF16A34A) : Colors.red),
                          const SizedBox(width: 12),
                          Text(_isAvailable ? 'Available' : 'Not Available', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF1F2937))),
                        ],
                      ),
                      Switch(
                        activeColor: const Color(0xFF16A34A),
                        inactiveThumbColor: Colors.red,
                        inactiveTrackColor: Colors.red.shade200,
                        value: _isAvailable,
                        onChanged: (val) => setState(() => _isAvailable = val),
                      ),
                    ],
                  ),
                ),
                
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
                  : PrimaryButton(text: 'SAVE CHANGES', onPressed: _submitItem),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _deleteItem,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('DELETE ITEM', style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
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
    super.dispose();
  }
}
