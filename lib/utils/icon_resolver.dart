import 'package:flutter/material.dart';

/// Maps an icon name string (stored in Supabase) to a Flutter [IconData].
/// Falls back to [Icons.inventory_2] for unknown names.
IconData resolveIcon(String? iconName) {
  switch (iconName) {
    case 'thermostat':
      return Icons.thermostat;
    case 'speed':
      return Icons.speed;
    case 'cable':
      return Icons.cable;
    case 'water_drop':
      return Icons.water_drop;
    case 'sensors':
      return Icons.sensors;
    case 'electrical_services':
      return Icons.electrical_services;
    case 'build':
      return Icons.build;
    case 'cloud':
      return Icons.cloud;
    case 'science':
      return Icons.science;
    case 'loop':
      return Icons.loop;
    case 'desktop_windows':
      return Icons.desktop_windows;
    case 'power':
      return Icons.power;
    case 'analytics':
      return Icons.analytics;
    case 'waves':
      return Icons.waves;
    case 'calculate':
      return Icons.calculate;
    case 'bar_chart':
      return Icons.bar_chart;
    case 'vibration':
      return Icons.vibration;
    case 'bolt':
      return Icons.bolt;
    case 'dvr':
      return Icons.dvr;
    case 'scale':
      return Icons.scale;
    case 'av_timer':
      return Icons.av_timer;
    case 'devices':
      return Icons.devices;
    default:
      return Icons.inventory_2;
  }
}
