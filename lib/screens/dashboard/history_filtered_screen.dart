import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';
import '../../models/inventory_activity.dart';
import 'dashboard_helpers.dart';
import 'history_item_details_screen.dart';

class HistoryFilteredScreen extends StatelessWidget {
  final String filterType;
  final List<InventoryActivity> fullData;

  const HistoryFilteredScreen({
    super.key,
    required this.filterType,
    required this.fullData,
  });

  List<InventoryActivity> get _displayList {
    return switch (filterType) {
      'Items Taken' =>
        fullData.where((activity) => activity.status != 'Returned').toList(),
      'Returnable' =>
        fullData.where((activity) => activity.isReturnable == true).toList(),
      'Non-Returnable' =>
        fullData.where((activity) => activity.isReturnable == false).toList(),
      'Overdue' =>
        fullData.where((activity) => activity.status == 'Overdue').toList(),
      _ => fullData,
    };
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          filterType,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: 30,
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _displayList.length,
              itemBuilder: (context, index) {
                final activity = _displayList[index];
                final accent = DashboardHelpers.categoryAccent(
                  activity.category,
                );
                final background = DashboardHelpers.categoryBackground(
                  activity.category,
                );

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            HistoryItemDetailsScreen(activity: activity),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: background,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              DashboardHelpers.categoryIcon(activity.category),
                              color: accent,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity.itemName,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${activity.category} ',
                                        style: GoogleFonts.inter(
                                          color: accent,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '• ${activity.itemCode}',
                                        style: GoogleFonts.inter(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Divider(
                                  height: 1,
                                  color: Color(0xFFF3F4F6),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.grey.shade300,
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            activity.assignedToName,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF1F2937),
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            activity.assignedRole,
                                            style: GoogleFonts.inter(
                                              color: Colors.grey.shade500,
                                              fontSize: 10,
                                            ),
                                          ),
                                          if (activity.contact.isNotEmpty)
                                            Text(
                                              activity.contact,
                                              style: GoogleFonts.inter(
                                                color: AppTheme.primaryBlue,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Activity Date',
                                          style: GoogleFonts.inter(
                                            color: Colors.grey.shade500,
                                            fontSize: 10,
                                          ),
                                        ),
                                        Text(
                                          DashboardHelpers.formatDate(
                                            activity.takenAt,
                                          ),
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1F2937),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (activity.isReturnable != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: activity.isReturnable == true
                                              ? const Color(0xFFEFF6FF)
                                              : const Color(0xFFF3F4F6),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: activity.isReturnable == true
                                                ? const Color(0xFFBFDBFE)
                                                : const Color(0xFFE5E7EB),
                                          ),
                                        ),
                                        child: Text(
                                          activity.isReturnable == true
                                              ? 'Returnable'
                                              : 'Non-Returnable',
                                          style: GoogleFonts.inter(
                                            color: activity.isReturnable == true
                                                ? const Color(0xFF1D4ED8)
                                                : const Color(0xFF4B5563),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                                    else
                                      const SizedBox.shrink(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            DashboardHelpers.statusBackground(
                                              activity.status,
                                            ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            DashboardHelpers.statusIcon(
                                              activity.status,
                                            ),
                                            color: DashboardHelpers.statusColor(
                                              activity.status,
                                            ),
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            activity.status,
                                            style: GoogleFonts.inter(
                                              color:
                                                  DashboardHelpers.statusColor(
                                                    activity.status,
                                                  ),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
