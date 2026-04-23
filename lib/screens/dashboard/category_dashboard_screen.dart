import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'electric_items_screen.dart';
import 'electronic_items_screen.dart';
import 'history_screen.dart';
import 'add_item_screen.dart';
import 'all_items_screen.dart';

class CategoryDashboard extends StatefulWidget {
  const CategoryDashboard({super.key});

  @override
  State<CategoryDashboard> createState() => _CategoryDashboardState();
}

class _CategoryDashboardState extends State<CategoryDashboard> {
  int _currentIndex = 0; // "Category" tab selected natively matching image

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Soft off-white matching image
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
          // The Blue Top Background Wave
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: TopWaveClipper(),
              child: Container(
                height: 180,
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Custom App Bar Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 28),
                      Text(
                        'Category',
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 28),
                    ],
                  ),
                ),
                
                const SizedBox(height: 50),
                
                // Header Texts
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Text(
                        'What would you like to explore?',
                        style: GoogleFonts.inter(color: const Color(0xFF1F2937), fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose a category to manage products',
                        style: GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Cards Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Electronic Card
                        Expanded(
                          child: _buildCategoryCard(
                            context,
                            title: 'Electronic',
                            description: 'Manage electronic items like phones, laptops, and gadgets.',
                            iconData: Icons.memory,
                            colorScheme: const Color(0xFFE0E7FF), // outer light blue
                            iconBgColor: const Color(0xFFDBEAFE),
                            iconColor: const Color(0xFF2563EB),
                            btnColor: const Color(0xFFDBEAFE),
                            btnTextColor: const Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Electric Card
                        Expanded(
                          child: _buildCategoryCard(
                            context,
                            title: 'Electric',
                            description: 'Manage electrical items like wires, switches, and appliances.',
                            iconData: Icons.electrical_services,
                            colorScheme: const Color(0xFFF0FDF4), // outer light green
                            iconBgColor: const Color(0xFFDCFCE7),
                            iconColor: const Color(0xFF16A34A),
                            btnColor: const Color(0xFFDCFCE7),
                            btnTextColor: const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Bottom Navigation Bar
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
        if (index == 1) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AllItemsScreen()));
        } else if (index == 2) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
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

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData iconData,
    required Color colorScheme,
    required Color iconBgColor,
    required Color iconColor,
    required Color btnColor,
    required Color btnTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon Circle
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, size: 45, color: iconColor),
          ),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.inter(color: iconColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            // Navigate dynamically based on card
            if (title == 'Electric') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ElectricItemsScreen()));
            } else if (title == 'Electronic') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ElectronicItemsScreen()));
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: btnColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('View Products', style: GoogleFonts.inter(color: btnTextColor, fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, color: btnTextColor, size: 16),
              ],
            ),
          ),
        )
        ],
      ),
    );
  }
}

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    // Smooth bezier curve mimicking the design header
    path.quadraticBezierTo(size.width * 0.25, size.height, size.width * 0.5, size.height - 30);
    path.quadraticBezierTo(size.width * 0.75, size.height - 60, size.width, size.height - 20);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
