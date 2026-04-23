import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import 'category_dashboard_screen.dart'; // For generic nav and TopWaveClipper
import 'item_details_screen.dart';
import 'history_screen.dart';
import 'add_item_screen.dart';
import 'all_items_screen.dart';
import '../../data/mock_data.dart';

class ElectricItemsScreen extends StatefulWidget {
  const ElectricItemsScreen({super.key});

  @override
  State<ElectricItemsScreen> createState() => _ElectricItemsScreenState();
}

class _ElectricItemsScreenState extends State<ElectricItemsScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    // Initially only show Electric items
    _filteredItems = MockData.allItems.where((item) => item['category'] == 'Electric').toList();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = MockData.allItems.where((item) => item['category'] == 'Electric').toList();
      } else {
        final searchLower = query.toLowerCase();
        _filteredItems = MockData.allItems.where((item) {
          if (item['category'] != 'Electric') return false;
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
      body: Stack(
        children: [
          // Background Blue Wave
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: TopWaveClipper(),
              child: Container(
                height: 220, // Increased height for search bar overlap
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Top Custom Header Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 45,
                        height: 45,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.electrical_services, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Electric Items',
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${MockData.allItems.where((item) => item['category'] == 'Electric').length} items in management',
                              style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 28),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Search Bar + Filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _filterItems,
                            decoration: InputDecoration(
                              hintText: 'Search electric items...',
                              hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Icon(Icons.filter_alt_outlined, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // List of Items
                Expanded(
                  child: _filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text('No matching items found', style: GoogleFonts.inter(color: Colors.grey.shade500)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          final bool isElectric = item['category'] == 'Electric';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              leading: Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: isElectric ? const Color(0xFFDCFCE7) : const Color(0xFFE0E7FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(item['icon'] as IconData, color: isElectric ? const Color(0xFF16A34A) : AppTheme.primaryBlue),
                              ),
                              title: Text(
                                item['title'],
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF1F2937), fontSize: 14),
                              ),
                              subtitle: Text(
                                item['subtitle'] ?? 'Category: ${item['category']}',
                                style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 12),
                              ),
                              trailing: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEFF6FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.chevron_right, color: Color(0xFF3B82F6), size: 18),
                              ),
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ItemDetailsScreen(item: item, categoryName: item['category'] ?? 'Electric'),
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
