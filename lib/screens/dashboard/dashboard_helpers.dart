import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';

class DashboardHelpers {
  static bool isElectricCategory(String category) =>
      category.toLowerCase() == 'electric';

  static IconData categoryIcon(String category) {
    return isElectricCategory(category)
        ? Icons.electrical_services
        : Icons.memory;
  }

  static Color categoryAccent(String category) {
    return isElectricCategory(category)
        ? const Color(0xFF16A34A)
        : AppTheme.primaryBlue;
  }

  static Color categoryBackground(String category) {
    return isElectricCategory(category)
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFE0E7FF);
  }

  static Color statusColor(String status) {
    switch (status) {
      case 'Returned':
        return const Color(0xFF16A34A);
      case 'Overdue':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFD97706);
    }
  }

  static Color statusBackground(String status) {
    switch (status) {
      case 'Returned':
        return const Color(0xFFDCFCE7);
      case 'Overdue':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFFEF3C7);
    }
  }

  static IconData statusIcon(String status) {
    switch (status) {
      case 'Returned':
        return Icons.check_circle_outline;
      case 'Overdue':
        return Icons.error_outline;
      default:
        return Icons.schedule;
    }
  }

  static String formatDate(DateTime? value) {
    if (value == null) {
      return '-';
    }
    return DateFormat('dd MMM yyyy').format(value);
  }

  static String formatTime(DateTime? value) {
    if (value == null) {
      return '';
    }
    return DateFormat('hh:mm a').format(value);
  }

  static DateTime? parseDate(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    const patterns = ['dd MMM yyyy', 'd MMM yyyy', 'MMM d, yyyy', 'yyyy-MM-dd'];

    for (final pattern in patterns) {
      try {
        return DateFormat(pattern).parseStrict(trimmed);
      } catch (_) {
        continue;
      }
    }

    return DateTime.tryParse(trimmed);
  }
}
