import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final List<Map<String, dynamic>> _adminHistoryData = [
    {
      'item': 'Temperature Sensor',
      'type': 'Electric',
      'user': 'Arun Kumar',
      'takenDate': '24 Apr 2024',
      'takenTime': '10:30 AM',
      'returnedDate': '25 Apr 2024',
      'returnedTime': '04:15 PM',
      'status': 'Returnable',
      'statusColor': const Color(0xFF16A34A),
      'statusBg': const Color(0xFFDCFCE7),
      'statusIcon': Icons.check_circle_outline,
    },
    {
      'item': 'Thermal Paste',
      'type': 'Electronic',
      'user': 'Priya Sharma',
      'takenDate': '22 Apr 2024',
      'takenTime': '03:15 PM',
      'returnedDate': '—',
      'returnedTime': '',
      'status': 'Non-returnable',
      'statusColor': const Color(0xFFDC2626),
      'statusBg': const Color(0xFFFEE2E2),
      'statusIcon': Icons.cancel_outlined,
    },
    {
      'item': 'Oscilloscope Probe',
      'type': 'Electronic',
      'user': 'Vikram Singh',
      'takenDate': '20 Apr 2024',
      'takenTime': '11:45 AM',
      'returnedDate': '—',
      'returnedTime': '',
      'status': 'Available',
      'statusColor': const Color(0xFF2563EB),
      'statusBg': const Color(0xFFDBEAFE),
      'statusIcon': Icons.inventory_2_outlined,
    },
    {
      'item': 'Multimeter',
      'type': 'Tools',
      'user': 'System',
      'takenDate': '—',
      'takenTime': '',
      'returnedDate': '—',
      'returnedTime': '',
      'status': 'Not Available',
      'statusColor': const Color(0xFF9CA3AF),
      'statusBg': const Color(0xFFF3F4F6),
      'statusIcon': Icons.not_interested,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B), // Admin specific dark header
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Panel',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              'Complete Global Inventory History',
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () =>
                Provider.of<AuthProvider>(context, listen: false).signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Dark Arch extension
          Container(
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Global Item Database',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Data Table
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
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
                            DataColumn(
                              label: Text(
                                'Item',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Taken By',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Time of Issue',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Time of Return',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Status',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                            const DataColumn(label: Text('')),
                          ],
                          rows: _adminHistoryData.map((data) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.devices,
                                          color: Color(0xFF1E293B),
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
                                            data['item'],
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF1F2937),
                                            ),
                                          ),
                                          Text(
                                            data['type'],
                                            style: GoogleFonts.inter(
                                              color: Colors.grey.shade500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Colors.grey.shade300,
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        data['user'],
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['takenDate'],
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                      if (data['takenTime'] != '')
                                        Text(
                                          data['takenTime'],
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['returnedDate'],
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                      if (data['returnedTime'] != '')
                                        Text(
                                          data['returnedTime'],
                                          style: GoogleFonts.inter(
                                            color: Colors.grey.shade500,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: data['statusBg'],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          data['statusIcon'],
                                          color: data['statusColor'],
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          data['status'],
                                          style: GoogleFonts.inter(
                                            color: data['statusColor'],
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const DataCell(
                                  Icon(
                                    Icons.edit,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
