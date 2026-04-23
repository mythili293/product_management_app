import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import 'item_details_screen.dart';
import 'history_screen.dart';
import 'category_dashboard_screen.dart';
import 'add_item_screen.dart';
import 'all_items_screen.dart';
import '../../data/mock_data.dart';

class ElectronicItemsScreen extends StatefulWidget {
  const ElectronicItemsScreen({super.key});

  @override
  State<ElectronicItemsScreen> createState() => _ElectronicItemsScreenState();
}

class _ElectronicItemsScreenState extends State<ElectronicItemsScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    // Initially only show Electronic items
    _filteredItems = MockData.allItems.where((item) => item['category'] == 'Electronic').toList();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = MockData.allItems.where((item) => item['category'] == 'Electronic').toList();
      } else {
        final searchLower = query.toLowerCase();
        _filteredItems = MockData.allItems.where((item) {
          if (item['category'] != 'Electronic') return false;
          final title = item['title'].toString().toLowerCase();
          return title.contains(searchLower);
        }).toList();
      }
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddItemScreen()));
        },
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Electronic Items', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Highlight Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E7FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.memory, color: AppTheme.primaryBlue, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Electronic', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1F2937))),
                        Text('Manage electronic products', style: GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${MockData.allItems.where((item) => item['category'] == 'Electronic').length} Items', style: GoogleFonts.inter(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Item List', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1F2937))),
                Text('${_filteredItems.length} Products', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          
          const SizedBox(height: 12),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterItems,
                decoration: InputDecoration(
                  hintText: 'Search electronic items...',
                  hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),

          // Items List
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('No results found', style: GoogleFonts.inter(color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final bool isElectronic = item['category'] == 'Electronic';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: isElectronic ? const Color(0xFFF0F4FA) : const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item['icon'] as IconData, color: isElectronic ? AppTheme.primaryBlue : const Color(0xFF16A34A)),
                          ),
                          title: Text(
                            item['title'],
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF1F2937), fontSize: 14),
                          ),
                          subtitle: Text(
                            item['subtitle'] ?? 'Category: ${item['category']}',
                            style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 11),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ItemDetailsScreen(item: item, categoryName: item['category'] ?? 'Electronic'),
                              ),
                            );
                            if (result != null && result is Map<String, dynamic> && result['deleted'] == true) {
                              _filterItems(_searchController.text);
                            }
                          },
                        ),
                      );
                    },
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

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        if (index == 2) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
        } else if (index == 0) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CategoryDashboard()));
        } else if (index == 1) {
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AllItemsScreen()));
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
