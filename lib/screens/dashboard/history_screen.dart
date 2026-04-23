import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import 'category_dashboard_screen.dart';
import 'history_filtered_screen.dart';
import 'all_items_screen.dart';
import 'history_item_details_screen.dart';
import '../../data/mock_data.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _currentIndex = 2;
  
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _selectedDuration = 'All Time';
  List<Map<String, dynamic>> _filteredHistory = [];

  @override
  void initState() {
    super.initState();
    _filteredHistory = MockData.historyData;
  }

  void _applyFilters() {
    setState(() {
      String query = _searchController.text.toLowerCase();
      
      _filteredHistory = MockData.historyData.where((item) {
        // 1. Check Category
        bool matchesCategory = true;
        if (_selectedFilter == 'Electric') {
          matchesCategory = item['type'] == 'Electric';
        } else if (_selectedFilter == 'Electronic') {
          matchesCategory = item['type'] == 'Electronic';
        }

        // 2. Check Search Keyword
        bool matchesSearch = true;
        if (query.isNotEmpty) {
          final itemName = item['item'].toString().toLowerCase();
          final itemCode = item['code'].toString().toLowerCase();
          final itemUser = item['user'].toString().toLowerCase();
          
          matchesSearch = itemName.contains(query) || 
                          itemCode.contains(query) || 
                          itemUser.contains(query);
        }

        // 3. Check Time Duration
        bool matchesDuration = true;
        if (_selectedDuration != 'All Time') {
          final dateStr = item['takenDate'];
          if (dateStr == null || dateStr == '—') {
            matchesDuration = false;
          } else {
            try {
              final takenDate = DateFormat('dd MMM yyyy').parse(dateStr);
              final difference = DateTime.now().difference(takenDate).inDays;
              
              if (_selectedDuration == '7 Days History') {
                matchesDuration = difference <= 7;
              } else if (_selectedDuration == '1 Month History') {
                matchesDuration = difference <= 30;
              } else if (_selectedDuration == '3 Months History') {
                matchesDuration = difference <= 90;
              } else if (_selectedDuration == '6 Months History') {
                matchesDuration = difference <= 180;
              } else if (_selectedDuration == '1 Year History') {
                matchesDuration = difference <= 365;
              }
            } catch (e) {
              matchesDuration = false;
            }
          }
        }

        return matchesCategory && matchesSearch && matchesDuration;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CategoryDashboard())),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('History', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            Text('View who took items and when they were returned', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 12)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.calendar_month, color: Colors.white),
              onSelected: (value) {
                _selectedDuration = value;
                _applyFilters();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'All Time', child: Text('All Time')),
                const PopupMenuItem(value: '7 Days History', child: Text('7 Days History')),
                const PopupMenuItem(value: '1 Month History', child: Text('1 Month History')),
                const PopupMenuItem(value: '3 Months History', child: Text('3 Months History')),
                const PopupMenuItem(value: '6 Months History', child: Text('6 Months History')),
                const PopupMenuItem(value: '1 Year History', child: Text('1 Year History')),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Blue Arch extension
          Container(
            height: 30,
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Search & Filter
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) => _applyFilters(),
                              decoration: InputDecoration(
                                hintText: 'Search history...',
                                hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            _selectedFilter = value;
                            _applyFilters();
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'All', child: Text('All Categories')),
                            const PopupMenuItem(value: 'Electric', child: Text('Electrical Items')),
                            const PopupMenuItem(value: 'Electronic', child: Text('Electronic Items')),
                          ],
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.filter_alt_outlined, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Text(
                                  // Update the label to reflect the selection if not "All"
                                  _selectedFilter == 'All' ? 'Filter' : _selectedFilter, 
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold)
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Stat Cards
                    Builder(
                      builder: (context) {
                        int totalRecords = MockData.historyData.length;
                        int itemsTaken = MockData.historyData.where((e) => e['status'] != 'Returned').length;
                        int returnableCount = MockData.historyData.where((e) => e['isReturnable'] == true).length;
                        int nonReturnableCount = MockData.historyData.where((e) => e['isReturnable'] == false).length;
                        int overdueCount = MockData.historyData.where((e) => e['status'] == 'Overdue').length;

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildStatCard(totalRecords.toString(), 'Total Records', 'All activities', Icons.inventory_2, const Color(0xFFEFF6FF), const Color(0xFF3B82F6), () => _openFiltered('Total Records')),
                              const SizedBox(width: 12),
                              _buildStatCard(itemsTaken.toString(), 'Items Taken', 'By users', Icons.add, const Color(0xFFF0FDF4), const Color(0xFF22C55E), () => _openFiltered('Items Taken')),
                              const SizedBox(width: 12),
                              _buildStatCard(returnableCount.toString(), 'Returnable', 'To inventory', Icons.undo, const Color(0xFFFFFBEB), const Color(0xFFF59E0B), () => _openFiltered('Returnable')),
                              const SizedBox(width: 12),
                              _buildStatCard(nonReturnableCount.toString(), 'Non-Returnable', 'Consumables', Icons.nightlight_round, const Color(0xFFFAF5FF), const Color(0xFFA855F7), () => _openFiltered('Non-Returnable')),
                              const SizedBox(width: 12),
                              _buildStatCard(overdueCount.toString(), 'Overdue', 'Past deadline', Icons.warning_amber_rounded, const Color(0xFFFEF2F2), const Color(0xFFEF4444), () => _openFiltered('Overdue')),
                            ],
                          ),
                        );
                      }
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Data Table (Scrollable horizontally)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(const Color(0xFFF9FAFB)),
                          dataRowMaxHeight: 70,
                          dataRowMinHeight: 70,
                          columnSpacing: 24,
                          columns: [
                            DataColumn(label: Text('Item', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.grey.shade600))),
                            DataColumn(label: Text('Item Code', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.grey.shade600))),
                            DataColumn(label: Text('Taken By', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.grey.shade600))),
                            DataColumn(label: Text('Taken On', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.grey.shade600))),
                            DataColumn(label: Text('Returned On', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.grey.shade600))),
                            DataColumn(label: Text('Status', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.grey.shade600))),
                            const DataColumn(label: Text('')),
                          ],
                          rows: _filteredHistory.map((data) {
                            return DataRow(
                              cells: [
                                DataCell(Row(
                                  children: [
                                    Container(
                                      width: 45,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: data['type'] == 'Electric' ? const Color(0xFFDCFCE7) : const Color(0xFFE0E7FF), 
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: Icon(data['icon'], color: data['type'] == 'Electric' ? const Color(0xFF16A34A) : AppTheme.primaryBlue),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(data['item'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
                                        Text(
                                          data['type'], 
                                          style: GoogleFonts.inter(
                                            color: data['type'] == 'Electric' ? Colors.green.shade600 : (data['type'] == 'Electronic' ? Colors.blue.shade700 : Colors.grey.shade500), 
                                            fontSize: 12,
                                            fontWeight: data['type'] == 'Electric' || data['type'] == 'Electronic' ? FontWeight.w600 : FontWeight.normal,
                                          )
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                                DataCell(Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20)),
                                  child: Text(data['code'], style: GoogleFonts.inter(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                                )),
                                DataCell(Row(
                                  children: [
                                    CircleAvatar(radius: 16, backgroundColor: Colors.grey.shade300, child: const Icon(Icons.person, color: Colors.white, size: 20)),
                                    const SizedBox(width: 8),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(data['user'], style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF1F2937))),
                                        Text(data['role'], style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 12)),
                                        if (data['contact'] != null && data['contact'].toString().isNotEmpty)
                                          Text(data['contact'], style: GoogleFonts.inter(color: AppTheme.primaryBlue, fontSize: 11, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ],
                                )),
                                DataCell(Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data['takenDate'], style: GoogleFonts.inter(color: const Color(0xFF1F2937))),
                                    Text(data['takenTime'], style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 12)),
                                  ],
                                )),
                                DataCell(Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data['returnedDate'], style: GoogleFonts.inter(color: const Color(0xFF1F2937))),
                                    if(data['returnedTime'] != '') Text(data['returnedTime'], style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 12)),
                                  ],
                                )),
                                DataCell(Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(color: data['statusBg'], borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(data['statusIcon'], color: data['statusColor'], size: 14),
                                      const SizedBox(width: 4),
                                      Text(data['status'], style: GoogleFonts.inter(color: data['statusColor'], fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                )),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right, color: Colors.grey),
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryItemDetailsScreen(data: data)));
                                    },
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Info Row
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.info, color: AppTheme.primaryBlue, size: 18),
                          const SizedBox(width: 8),
                          Text('History shows who took the item, when it was taken, and when it was returned.', 
                               style: GoogleFonts.inter(color: const Color(0xFF4B5563), fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.grid_view, 'Category'),
                _buildNavItem(1, Icons.inventory_2_outlined, 'Products'),
                _buildNavItem(2, Icons.history, 'History'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openFiltered(String filterName) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryFilteredScreen(filterType: filterName, fullData: MockData.historyData)));
  }

  Widget _buildStatCard(String value, String title, String subtitle, IconData icon, Color bgColor, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 150,
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF1F2937))),
                Text(title, style: GoogleFonts.inter(color: const Color(0xFF4B5563), fontSize: 12, fontWeight: FontWeight.bold)),
                Text(subtitle, style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (index != 2) {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CategoryDashboard()));
          } else if (index == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AllItemsScreen()));
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade500),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade500, fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
