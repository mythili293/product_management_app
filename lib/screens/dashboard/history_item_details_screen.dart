import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class HistoryItemDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const HistoryItemDetailsScreen({super.key, required this.data});

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: isStatus
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: data['statusBg'] ?? Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (data['statusIcon'] != null) ...[
                            Icon(data['statusIcon'], color: data['statusColor'] ?? Colors.grey, size: 14),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            value,
                            style: GoogleFonts.inter(
                              color: data['statusColor'] ?? Colors.grey.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1F2937),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isElectric = data['type'] == 'Electric';
    final iconColor = isElectric ? const Color(0xFF16A34A) : AppTheme.primaryBlue;
    final iconBg = isElectric ? const Color(0xFFDCFCE7) : const Color(0xFFE0E7FF);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        title: Text('History Details', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Icon(data['icon'] ?? Icons.inventory, color: iconColor, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data['item'] ?? 'Unknown Item',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${data['type']} • ${data['code']}',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            // Details Card
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction Details',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 8),

                      _buildDetailRow('Item', data['item'] ?? 'N/A'),
                      _buildDetailRow('Item Code', data['code'] ?? 'N/A'),
                      
                      _buildDetailRow(
                        'Taken By', 
                        '${data['user'] ?? 'N/A'}${data['contact'] != null && data['contact'].toString().isNotEmpty ? '\n${data['contact']}' : ''}'
                      ),
                      
                      _buildDetailRow(
                        'Taken On', 
                        '${data['takenDate'] ?? 'N/A'} ${data['takenTime'] ?? ''}'
                      ),
                      
                      _buildDetailRow(
                        'Returned On', 
                        data['returnedDate'] == '—' || data['returnedDate'] == null 
                            ? 'Not Returned Yet' 
                            : '${data['returnedDate']} ${data['returnedTime'] ?? ''}'
                      ),
                      
                      _buildDetailRow('Status', data['status'] ?? 'N/A', isStatus: true),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
