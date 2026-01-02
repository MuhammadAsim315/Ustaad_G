import 'package:flutter/foundation.dart' show debugPrint;
import '../services/firestore_service.dart';

/// Utility class to initialize Firestore with default data
class FirestoreInit {
  /// Initialize icon configurations in Firestore
  /// Call this once to populate the database with icon paths
  static Future<void> initializeIcons() async {
    try {
      final icons = [
        {'name': 'Plumber', 'path': 'icon/plumber.svg', 'color': '#2196F3'},
        {'name': 'Carpenter', 'path': 'icon/carpenter.svg', 'color': '#795548'},
        {'name': 'Welder', 'path': 'icon/welder.svg', 'color': '#FF9800'},
        {'name': 'Electrician', 'path': 'icon/electrician.svg', 'color': '#FDD835'},
        {'name': 'Painter', 'path': 'icon/painter.svg', 'color': '#9C27B0'},
        {'name': 'Laundry', 'path': 'icon/laundry.svg', 'color': '#00BCD4'},
        {'name': 'Mechanic', 'path': 'icon/mechanic.svg', 'color': '#F44336'},
        {'name': 'Cleaner', 'path': 'icon/cleaner.svg', 'color': '#009688'},
        {'name': 'Contractor', 'path': 'icon/contractor.svg', 'color': '#9E9E9E'},
      ];

      for (var icon in icons) {
        await FirestoreService.saveIconConfig(
          categoryName: icon['name']!,
          svgPath: icon['path']!,
          colorHex: icon['color']!,
        );
      }

      debugPrint('✅ Icons initialized in Firestore');
    } catch (e) {
      debugPrint('❌ Error initializing icons: $e');
    }
  }

  /// Check if icons are already initialized
  static Future<bool> areIconsInitialized() async {
    try {
      final configs = await FirestoreService.getAllIconConfigs();
      return configs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

