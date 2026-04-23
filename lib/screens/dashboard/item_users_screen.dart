import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../data/mock_data.dart';

class ItemUsersScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const ItemUsersScreen({super.key, required this.item});

  @override
  State<ItemUsersScreen> createState() => _ItemUsersScreenState();
}

class _ItemUsersScreenState extends State<ItemUsersScreen> {
  Map<String, dynamic>? _historyRecord;
  int? _historyIndex;

  // Controllers for editing
  late TextEditingController _userNameController;
  late TextEditingController _contactController;
  late TextEditingController _takenDateController;
  late TextEditingController _returnedDateController;
  late TextEditingController _returnedTimeController;
  String _status = 'Not Returned';

  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  void _loadRecord() {
    final itemName = widget.item['title'] ?? widget.item['itemName'];
    
    // Find if this item has history
    _historyIndex = MockData.historyData.indexWhere((e) => e['item'] == itemName);
    if (_historyIndex != -1) {
      _historyRecord = Map.from(MockData.historyData[_historyIndex!]); // Make a copy
      _userNameController = TextEditingController(text: _historyRecord!['user']);
      _contactController = TextEditingController(text: _historyRecord!['contact'] ?? '');
      _takenDateController = TextEditingController(text: _historyRecord!['takenDate']);
      _returnedDateController = TextEditingController(text: _historyRecord!['returnedDate']);
      _returnedTimeController = TextEditingController(text: _historyRecord!['returnedTime']);
      _status = _historyRecord!['status'] ?? 'Not Returned';
    } else {
      // Initialize for a new entry
      _historyRecord = {
        'item': itemName,
        'type': widget.item['category'] ?? 'Miscellaneous',
        'code': widget.item['code'] ?? 'UNK-000',
        'icon': widget.item['icon'] ?? Icons.inventory_2,
        'user': 'No User Assigned',
        'role': '—',
        'takenDate': '—',
        'takenTime': '',
        'returnedDate': '—',
        'returnedTime': '',
        'status': 'Not Returned',
        'isReturnable': true,
        'contact': ''
      };
      _userNameController = TextEditingController(text: '');
      _contactController = TextEditingController(text: '');
      _takenDateController = TextEditingController(text: '');
      _returnedDateController = TextEditingController(text: '');
      _returnedTimeController = TextEditingController(text: '');
      _status = 'Not Returned';
    }
  }

  void _saveData() {
    final updatedRecord = {
      ..._historyRecord!,
      'user': _userNameController.text.isEmpty ? 'No User Assigned' : _userNameController.text,
      'contact': _contactController.text,
      'takenDate': _takenDateController.text.isEmpty ? '—' : _takenDateController.text,
      'returnedDate': _returnedDateController.text.isEmpty ? '—' : _returnedDateController.text,
      'returnedTime': _returnedTimeController.text,
      'status': _status,
      'statusBg': _status == 'Returned' ? const Color(0xFFDCFCE7) : _status == 'Overdue' ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7),
      'statusColor': _status == 'Returned' ? const Color(0xFF16A34A) : _status == 'Overdue' ? const Color(0xFFDC2626) : const Color(0xFFD97706),
      'statusIcon': _status == 'Returned' ? Icons.check_circle_outline : _status == 'Overdue' ? Icons.error_outline : Icons.schedule,
    };

    if (_historyIndex != null && _historyIndex != -1) {
      // Update existing record
      MockData.historyData[_historyIndex!] = updatedRecord;
    } else {
      // Add new record to history
      MockData.historyData.add(updatedRecord);
      // Update index so subsequent saves in same session work as updates
      _historyIndex = MockData.historyData.length - 1;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item Activity Updated and Saved to History!')));
    Navigator.pop(context, true); // Pop back requesting a refresh
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _contactController.dispose();
    _takenDateController.dispose();
    _returnedDateController.dispose();
    _returnedTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasUser = _historyRecord!['user'] != 'No User Assigned';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Item User Details', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header curve
            Container(
              height: 40,
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Item Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                          child: Icon(widget.item['icon'] ?? Icons.inventory_2, size: 35, color: AppTheme.primaryBlue),
                        ),
                        const SizedBox(height: 16),
                        Text(_historyRecord!['item'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20)),
                        const SizedBox(height: 4),
                        Text('Code: ${_historyRecord!['code']}', style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 14)),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // User Profile Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: hasUser ? const Color(0xFFF0FDF4) : Colors.grey.shade200,
                          child: Icon(Icons.person, color: hasUser ? const Color(0xFF16A34A) : Colors.grey.shade500, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Assigned To', style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 12)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _userNameController,
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                  hintText: 'Enter name',
                                ),
                              ),
                              TextField(
                                controller: _contactController,
                                style: GoogleFonts.inter(fontSize: 14, color: AppTheme.primaryBlue),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.only(top: 4, bottom: 4),
                                  border: InputBorder.none,
                                  hintText: 'Add contact number',
                                  hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                                  icon: const Icon(Icons.phone, size: 14, color: AppTheme.primaryBlue),
                                ),
                              ),
                              if (hasUser) Text(_historyRecord!['role'], style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  Text('Activity Log & Setup', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1F2937))),
                  const SizedBox(height: 12),
                  
                  // Settings Form
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Taken Date Editable
                        Text('Taken On', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF4B5563), fontSize: 13)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _takenDateController,
                          decoration: InputDecoration(
                            hintText: 'e.g. 24 Apr 2024',
                            suffixIcon: const Icon(Icons.outbox, size: 20, color: Colors.blueGrey),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                        
                        // Status Switcher
                        Text('Current Status', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF4B5563), fontSize: 13)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _status,
                          items: ['Not Returned', 'Returned', 'Overdue']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.inter(fontSize: 14))))
                              .toList(),
                          onChanged: (val) => setState(() => _status = val!),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Returned Date Setter
                        Text('Returned Date', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF4B5563), fontSize: 13)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _returnedDateController,
                          decoration: InputDecoration(
                            hintText: 'e.g. 25 Apr 2024',
                            suffixIcon: const Icon(Icons.calendar_month),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),

                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Update Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _saveData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text('Update and Save', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
