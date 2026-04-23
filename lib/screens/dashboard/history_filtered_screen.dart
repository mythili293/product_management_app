import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import 'history_item_details_screen.dart';

class HistoryFilteredScreen extends StatelessWidget {
  final String filterType;
  final List<Map<String, dynamic>> fullData;

  const HistoryFilteredScreen({super.key, required this.filterType, required this.fullData});

  List<Map<String, dynamic>> get _displayList {
    if (filterType == 'Total Records') {
      return fullData;
    } else if (filterType == 'Items Taken') {
      return fullData.where((e) => e['status'] != 'Returned').toList();
    } else if (filterType == 'Returnable') {
      return fullData.where((e) => e['isReturnable'] == true).toList();
    } else if (filterType == 'Non-Returnable') {
      return fullData.where((e) => e['isReturnable'] == false).toList();
    } else if (filterType == 'Overdue') {
      return fullData.where((e) => e['status'] == 'Overdue').toList();
    }
    return fullData;
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
        title: Text(filterType, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
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
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _displayList.length, 
              itemBuilder: (context, index) {
                final data = _displayList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryItemDetailsScreen(data: data)));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Icon
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: data['type'] == 'Electric' ? const Color(0xFFDCFCE7) : const Color(0xFFE0E7FF), 
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Icon(data['icon'], color: data['type'] == 'Electric' ? const Color(0xFF16A34A) : AppTheme.primaryBlue),
                        ),
                        const SizedBox(width: 16),
                        
                        // Body Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['item'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1F2937))),
                              const SizedBox(height: 2),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${data['type']} ',
                                      style: GoogleFonts.inter(
                                        color: data['type'] == 'Electric' ? Colors.blue.shade700 : (data['type'] == 'Electronic' ? Colors.green.shade600 : Colors.grey.shade500),
                                        fontWeight: data['type'] == 'Electric' || data['type'] == 'Electronic' ? FontWeight.w600 : FontWeight.normal,
                                        fontSize: 12,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '• ${data['code']}',
                                      style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              const Divider(height: 1, color: Color(0xFFF3F4F6)),
                              const SizedBox(height: 12),
                              
                              Row(
                                children: [
                                  CircleAvatar(radius: 12, backgroundColor: Colors.grey.shade300, child: const Icon(Icons.person, color: Colors.white, size: 14)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(data['user'], style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF1F2937), fontSize: 12)),
                                        Text(data['role'], style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 10)),
                                        if (data['contact'] != null && data['contact'].toString().isNotEmpty)
                                          Text(data['contact'], style: GoogleFonts.inter(color: AppTheme.primaryBlue, fontSize: 10, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('Activity Date', style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 10)),
                                      Text(data['takenDate'], style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF1F2937), fontSize: 12)),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (data['isReturnable'] != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: data['isReturnable'] == true ? const Color(0xFFEFF6FF) : const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: data['isReturnable'] == true ? const Color(0xFFBFDBFE) : const Color(0xFFE5E7EB)),
                                      ),
                                      child: Text(
                                        data['isReturnable'] == true ? 'Returnable' : 'Non-Returnable',
                                        style: GoogleFonts.inter(
                                          color: data['isReturnable'] == true ? const Color(0xFF1D4ED8) : const Color(0xFF4B5563),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  else
                                    const SizedBox.shrink(),

                                  Container(
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
