import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';
import '../../models/inventory_activity.dart';
import '../../models/product.dart';
import '../../services/database_service.dart';
import 'dashboard_helpers.dart';

class ItemUsersScreen extends StatefulWidget {
  final Product product;

  const ItemUsersScreen({super.key, required this.product});

  @override
  State<ItemUsersScreen> createState() => _ItemUsersScreenState();
}

class _ItemUsersScreenState extends State<ItemUsersScreen> {
  final DatabaseService _databaseService = DatabaseService();
  late final TextEditingController _userNameController;
  late final TextEditingController _contactController;
  late final TextEditingController _takenDateController;
  late final TextEditingController _returnedDateController;

  InventoryActivity? _activity;
  bool _isLoading = true;
  String _status = 'Not Returned';

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController();
    _contactController = TextEditingController();
    _takenDateController = TextEditingController();
    _returnedDateController = TextEditingController();
    _loadRecord();
  }

  Future<void> _loadRecord() async {
    final activity = await _databaseService.getInventoryActivityForProduct(
      widget.product.productId,
    );
    final resolvedActivity =
        activity ?? InventoryActivity.emptyForProduct(widget.product);

    _activity = resolvedActivity;
    _userNameController.text =
        resolvedActivity.assignedToName == 'No User Assigned'
        ? ''
        : resolvedActivity.assignedToName;
    _contactController.text = resolvedActivity.contact;
    _takenDateController.text = DashboardHelpers.formatDate(
      resolvedActivity.takenAt,
    );
    _returnedDateController.text = DashboardHelpers.formatDate(
      resolvedActivity.returnedAt,
    );
    _status = resolvedActivity.status;

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveData() async {
    final currentActivity =
        _activity ?? InventoryActivity.emptyForProduct(widget.product);
    final assignedName = _userNameController.text.trim();
    final takenAt = DashboardHelpers.parseDate(_takenDateController.text);
    final returnedAt = DashboardHelpers.parseDate(_returnedDateController.text);

    final updatedActivity = currentActivity.copyWith(
      itemName: widget.product.productName,
      itemCode: widget.product.code,
      category: widget.product.category,
      assignedToName: assignedName.isEmpty ? 'No User Assigned' : assignedName,
      assignedRole: assignedName.isEmpty
          ? 'Unspecified'
          : (currentActivity.assignedRole == 'Unspecified'
                ? 'Team Member'
                : currentActivity.assignedRole),
      contact: _contactController.text.trim(),
      takenAt: takenAt,
      returnedAt: _status == 'Returned' ? returnedAt : null,
      status: _status,
      updatedAt: DateTime.now(),
      clearReturnedAt: _status != 'Returned',
    );

    await _databaseService.saveInventoryActivity(updatedActivity);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item activity updated and saved.')),
    );
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _contactController.dispose();
    _takenDateController.dispose();
    _returnedDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final activity =
        _activity ?? InventoryActivity.emptyForProduct(widget.product);
    final hasUser = _userNameController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Item User Details',
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 40,
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: AppTheme.primaryBlue.withValues(
                            alpha: 0.1,
                          ),
                          child: Icon(
                            DashboardHelpers.categoryIcon(
                              widget.product.category,
                            ),
                            size: 35,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.product.productName,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Code: ${widget.product.code}',
                          style: GoogleFonts.inter(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: hasUser
                              ? const Color(0xFFF0FDF4)
                              : Colors.grey.shade200,
                          child: Icon(
                            Icons.person,
                            color: hasUser
                                ? const Color(0xFF16A34A)
                                : Colors.grey.shade500,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Assigned To',
                                style: GoogleFonts.inter(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _userNameController,
                                onChanged: (_) => setState(() {}),
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                  hintText: 'Enter name',
                                ),
                              ),
                              TextField(
                                controller: _contactController,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppTheme.primaryBlue,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.only(
                                    top: 4,
                                    bottom: 4,
                                  ),
                                  border: InputBorder.none,
                                  hintText: 'Add contact number',
                                  hintStyle: GoogleFonts.inter(
                                    color: Colors.grey.shade400,
                                  ),
                                  icon: const Icon(
                                    Icons.phone,
                                    size: 14,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ),
                              if (hasUser)
                                Text(
                                  activity.assignedRole,
                                  style: GoogleFonts.inter(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Activity Log & Setup',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Taken On',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4B5563),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _takenDateController,
                          decoration: InputDecoration(
                            hintText: 'e.g. 24 Apr 2024',
                            suffixIcon: const Icon(
                              Icons.outbox,
                              size: 20,
                              color: Colors.blueGrey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        Text(
                          'Current Status',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4B5563),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _status,
                          items: ['Not Returned', 'Returned', 'Overdue']
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: GoogleFonts.inter(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _status = value);
                            }
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Returned Date',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4B5563),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _returnedDateController,
                          enabled: _status == 'Returned',
                          decoration: InputDecoration(
                            hintText: 'e.g. 25 Apr 2024',
                            suffixIcon: const Icon(Icons.calendar_month),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _saveData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Update and Save',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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
