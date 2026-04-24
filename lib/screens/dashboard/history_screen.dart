import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';
import '../../models/inventory_activity.dart';
import '../../services/database_service.dart';
import '../dashboard/category_dashboard_screen.dart';
import '../dashboard/history_filtered_screen.dart';
import 'all_items_screen.dart';
import 'dashboard_helpers.dart';
import 'history_item_details_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  final int _currentIndex = 2;
  String _selectedFilter = 'All';
  String _selectedDuration = 'All Time';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<InventoryActivity>>(
      stream: _databaseService.getInventoryActivities(),
      builder: (context, snapshot) {
        final activities = snapshot.data ?? const <InventoryActivity>[];
        final query = _searchController.text.trim().toLowerCase();

        final filteredActivities = activities.where((activity) {
          final matchesCategory = switch (_selectedFilter) {
            'Electric' => activity.category == 'Electric',
            'Electronic' => activity.category == 'Electronic',
            _ => true,
          };

          final matchesSearch =
              query.isEmpty ||
              activity.itemName.toLowerCase().contains(query) ||
              activity.itemCode.toLowerCase().contains(query) ||
              activity.assignedToName.toLowerCase().contains(query);

          final matchesDuration = _matchesDuration(activity);

          return matchesCategory && matchesSearch && matchesDuration;
        }).toList();

        final totalRecords = activities.length;
        final itemsTaken = activities
            .where((activity) => activity.status != 'Returned')
            .length;
        final returnableCount = activities
            .where((activity) => activity.isReturnable == true)
            .length;
        final nonReturnableCount = activities
            .where((activity) => activity.isReturnable == false)
            .length;
        final overdueCount = activities
            .where((activity) => activity.status == 'Overdue')
            .length;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: AppTheme.primaryBlue,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CategoryDashboard()),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'History',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'View who took items and when they were returned',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.calendar_month, color: Colors.white),
                  onSelected: (value) {
                    setState(() => _selectedDuration = value);
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'All Time', child: Text('All Time')),
                    PopupMenuItem(
                      value: '7 Days History',
                      child: Text('7 Days History'),
                    ),
                    PopupMenuItem(
                      value: '1 Month History',
                      child: Text('1 Month History'),
                    ),
                    PopupMenuItem(
                      value: '3 Months History',
                      child: Text('3 Months History'),
                    ),
                    PopupMenuItem(
                      value: '6 Months History',
                      child: Text('6 Months History'),
                    ),
                    PopupMenuItem(
                      value: '1 Year History',
                      child: Text('1 Year History'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                height: 30,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
              ),
              Expanded(
                child:
                    snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      child: TextField(
                                        controller: _searchController,
                                        onChanged: (_) => setState(() {}),
                                        decoration: InputDecoration(
                                          hintText: 'Search history...',
                                          hintStyle: GoogleFonts.inter(
                                            color: Colors.grey.shade400,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.search,
                                            color: Colors.grey.shade400,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                vertical: 15,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      setState(() => _selectedFilter = value);
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(
                                        value: 'All',
                                        child: Text('All Categories'),
                                      ),
                                      PopupMenuItem(
                                        value: 'Electric',
                                        child: Text('Electrical Items'),
                                      ),
                                      PopupMenuItem(
                                        value: 'Electronic',
                                        child: Text('Electronic Items'),
                                      ),
                                    ],
                                    child: Container(
                                      height: 50,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.filter_alt_outlined,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _selectedFilter == 'All'
                                                ? 'Filter'
                                                : _selectedFilter,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Colors.grey.shade600,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildStatCard(
                                      totalRecords.toString(),
                                      'Total Records',
                                      'All activities',
                                      Icons.inventory_2,
                                      const Color(0xFFEFF6FF),
                                      const Color(0xFF3B82F6),
                                      () => _openFiltered(
                                        'Total Records',
                                        activities,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    _buildStatCard(
                                      itemsTaken.toString(),
                                      'Items Taken',
                                      'By users',
                                      Icons.add,
                                      const Color(0xFFF0FDF4),
                                      const Color(0xFF22C55E),
                                      () => _openFiltered(
                                        'Items Taken',
                                        activities,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    _buildStatCard(
                                      returnableCount.toString(),
                                      'Returnable',
                                      'To inventory',
                                      Icons.undo,
                                      const Color(0xFFFFFBEB),
                                      const Color(0xFFF59E0B),
                                      () => _openFiltered(
                                        'Returnable',
                                        activities,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    _buildStatCard(
                                      nonReturnableCount.toString(),
                                      'Non-Returnable',
                                      'Consumables',
                                      Icons.nightlight_round,
                                      const Color(0xFFFAF5FF),
                                      const Color(0xFFA855F7),
                                      () => _openFiltered(
                                        'Non-Returnable',
                                        activities,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    _buildStatCard(
                                      overdueCount.toString(),
                                      'Overdue',
                                      'Past deadline',
                                      Icons.warning_amber_rounded,
                                      const Color(0xFFFEF2F2),
                                      const Color(0xFFEF4444),
                                      () =>
                                          _openFiltered('Overdue', activities),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(
                                      const Color(0xFFF9FAFB),
                                    ),
                                    dataRowMaxHeight: 70,
                                    dataRowMinHeight: 70,
                                    columnSpacing: 24,
                                    columns: [
                                      _column('Item'),
                                      _column('Item Code'),
                                      _column('Taken By'),
                                      _column('Taken On'),
                                      _column('Returned On'),
                                      _column('Status'),
                                      const DataColumn(label: Text('')),
                                    ],
                                    rows: filteredActivities.map((activity) {
                                      final accent =
                                          DashboardHelpers.categoryAccent(
                                            activity.category,
                                          );
                                      final background =
                                          DashboardHelpers.categoryBackground(
                                            activity.category,
                                          );

                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Row(
                                              children: [
                                                Container(
                                                  width: 45,
                                                  height: 45,
                                                  decoration: BoxDecoration(
                                                    color: background,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    DashboardHelpers.categoryIcon(
                                                      activity.category,
                                                    ),
                                                    color: accent,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      activity.itemName,
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: const Color(
                                                          0xFF1F2937,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      activity.category,
                                                      style: GoogleFonts.inter(
                                                        color: accent,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          DataCell(
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEFF6FF),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                activity.itemCode,
                                                style: GoogleFonts.inter(
                                                  color: AppTheme.primaryBlue,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 16,
                                                  backgroundColor:
                                                      Colors.grey.shade300,
                                                  child: const Icon(
                                                    Icons.person,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      activity.assignedToName,
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: const Color(
                                                          0xFF1F2937,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      activity.assignedRole,
                                                      style: GoogleFonts.inter(
                                                        color: Colors
                                                            .grey
                                                            .shade500,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    if (activity
                                                        .contact
                                                        .isNotEmpty)
                                                      Text(
                                                        activity.contact,
                                                        style:
                                                            GoogleFonts.inter(
                                                              color: AppTheme
                                                                  .primaryBlue,
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          DataCell(
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  DashboardHelpers.formatDate(
                                                    activity.takenAt,
                                                  ),
                                                  style: GoogleFonts.inter(
                                                    color: const Color(
                                                      0xFF1F2937,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  DashboardHelpers.formatTime(
                                                    activity.takenAt,
                                                  ),
                                                  style: GoogleFonts.inter(
                                                    color: Colors.grey.shade500,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          DataCell(
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  DashboardHelpers.formatDate(
                                                    activity.returnedAt,
                                                  ),
                                                  style: GoogleFonts.inter(
                                                    color: const Color(
                                                      0xFF1F2937,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  DashboardHelpers.formatTime(
                                                    activity.returnedAt,
                                                  ),
                                                  style: GoogleFonts.inter(
                                                    color: Colors.grey.shade500,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          DataCell(
                                            _statusChip(activity.status),
                                          ),
                                          DataCell(
                                            IconButton(
                                              icon: const Icon(
                                                Icons.chevron_right,
                                                color: Colors.grey,
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        HistoryItemDetailsScreen(
                                                          activity: activity,
                                                        ),
                                                  ),
                                                );
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
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.info,
                                      color: AppTheme.primaryBlue,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'History shows who took the item, when it was taken, and when it was returned.',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF4B5563),
                                        fontSize: 12,
                                      ),
                                    ),
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
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
      },
    );
  }

  bool _matchesDuration(InventoryActivity activity) {
    if (_selectedDuration == 'All Time') {
      return true;
    }

    final takenAt = activity.takenAt;
    if (takenAt == null) {
      return false;
    }

    final difference = DateTime.now().difference(takenAt).inDays;

    return switch (_selectedDuration) {
      '7 Days History' => difference <= 7,
      '1 Month History' => difference <= 30,
      '3 Months History' => difference <= 90,
      '6 Months History' => difference <= 180,
      '1 Year History' => difference <= 365,
      _ => true,
    };
  }

  void _openFiltered(String filterName, List<InventoryActivity> fullData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            HistoryFilteredScreen(filterType: filterName, fullData: fullData),
      ),
    );
  }

  DataColumn _column(String label) {
    return DataColumn(
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: DashboardHelpers.statusBackground(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            DashboardHelpers.statusIcon(status),
            color: DashboardHelpers.statusColor(status),
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: GoogleFonts.inter(
              color: DashboardHelpers.statusColor(status),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String title,
    String subtitle,
    IconData icon,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 150,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF4B5563),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: Colors.grey.shade500,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (index != 2) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CategoryDashboard()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AllItemsScreen()),
            );
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
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade500,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade500,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
