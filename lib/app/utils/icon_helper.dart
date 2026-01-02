import 'package:flutter/foundation.dart' show debugPrint;
import '../services/firestore_service.dart';

/// Helper class to map category names to SVG icon paths
/// Supports both local assets and Firestore database
class IconHelper {
  // Cache for Firestore icon configs
  static Map<String, String> _firestoreIconCache = {};
  static bool _cacheLoaded = false;
  static bool _isLoading = false;

  /// Initialize and load icon configs from Firestore (call this at app start)
  static Future<void> initialize() async {
    if (_isLoading || _cacheLoaded) {
      debugPrint('IconHelper: Already loaded or loading, skipping initialization');
      return;
    }
    
    _isLoading = true;
    try {
      debugPrint('IconHelper: Starting initialization from Firestore...');
      final configs = await FirestoreService.getAllIconConfigs();
      _firestoreIconCache = {};
      
      debugPrint('IconHelper: Received ${configs.length} icon configs from Firestore');
      
      for (var config in configs) {
        final categoryName = config['categoryName']?.toString().toLowerCase();
        final svgPath = config['svgPath']?.toString();
        if (categoryName != null && svgPath != null) {
          // Normalize the path to ensure it's in the correct format
          String normalizedPath = svgPath.trim();
          
          // Remove "assets/" prefix if present
          if (normalizedPath.startsWith('assets/')) {
            normalizedPath = normalizedPath.substring(7);
          }
          
          // Ensure it starts with "icon/" and ends with ".svg"
          if (!normalizedPath.startsWith('icon/')) {
            if (normalizedPath.endsWith('.svg')) {
              normalizedPath = 'icon/$normalizedPath';
            } else {
              normalizedPath = 'icon/$normalizedPath.svg';
            }
          }
          
          if (!normalizedPath.endsWith('.svg')) {
            normalizedPath = '$normalizedPath.svg';
          }
          
          _firestoreIconCache[categoryName] = normalizedPath;
          debugPrint('IconHelper: Loaded icon from Firestore: $categoryName -> $normalizedPath');
        } else {
          debugPrint('IconHelper: Skipping invalid config: categoryName=$categoryName, svgPath=$svgPath');
        }
      }
      debugPrint('IconHelper: Total icons loaded from Firestore: ${_firestoreIconCache.length}');
      debugPrint('IconHelper: Cache contents: $_firestoreIconCache');
      _cacheLoaded = true;
    } catch (e, stackTrace) {
      debugPrint('IconHelper: Error loading from Firestore: $e');
      debugPrint('IconHelper: Stack trace: $stackTrace');
      // If Firestore fails, use local assets
      _cacheLoaded = true; // Mark as loaded to prevent repeated attempts
    } finally {
      _isLoading = false;
    }
  }

  /// Maps category name to SVG icon path (synchronous)
  /// Returns null if icon doesn't exist
  /// First checks Firestore cache, then falls back to local assets
  /// Returns path relative to assets/ directory (e.g., "icon/carpenter.svg")
  static String? getSvgIconPath(String categoryName) {
    // Convert category name to lowercase for matching
    final normalizedName = categoryName.toLowerCase();
    
    // Check if cache is loaded (if not, use local assets immediately)
    if (!_cacheLoaded) {
      debugPrint('IconHelper: Cache not loaded yet, using local assets for $categoryName');
      return _getLocalSvgIconPath(normalizedName);
    }
    
    // Check Firestore cache first
    if (_firestoreIconCache.containsKey(normalizedName)) {
      final path = _firestoreIconCache[normalizedName];
      // Ensure path is correct format (should be "icon/filename.svg")
      if (path != null && path.isNotEmpty) {
        // Path should already be normalized from initialize(), but double-check
        String normalizedPath = path.trim();
        
        // If path already starts with "assets/", remove it (Flutter handles this)
        if (normalizedPath.startsWith('assets/')) {
          normalizedPath = normalizedPath.substring(7); // Remove "assets/" prefix
        }
        
        // Ensure path starts with "icon/" and ends with ".svg"
        if (!normalizedPath.startsWith('icon/')) {
          // Extract filename if path is just "filename.svg"
          if (normalizedPath.endsWith('.svg')) {
            normalizedPath = 'icon/$normalizedPath';
          } else {
            // If it's just a filename without extension, add both
            normalizedPath = 'icon/$normalizedPath.svg';
          }
        }
        
        // Ensure it ends with .svg
        if (!normalizedPath.endsWith('.svg')) {
          normalizedPath = '$normalizedPath.svg';
        }
        
        debugPrint('IconHelper: Path for "$categoryName" -> "$normalizedPath" (from Firestore cache)');
        // Return path with 'assets/' prefix since we explicitly listed them in pubspec.yaml
        return 'assets/$normalizedPath';
      }
    }
    
    // Fallback to local assets
    final localPath = _getLocalSvgIconPath(normalizedName);
    if (localPath != null) {
      debugPrint('IconHelper: Using local icon path for "$categoryName": "$localPath"');
    } else {
      debugPrint('IconHelper: ⚠️ No icon path found for "$categoryName" (checked Firestore cache and local assets)');
    }
    return localPath;
  }
  
  /// Get local SVG icon path (fallback)
  static String? _getLocalSvgIconPath(String normalizedName) {
    // Map of category names to SVG file names
    final iconMap = {
      'plumber': 'plumber.svg',
      'carpenter': 'carpenter.svg',
      'welder': 'welder.svg',
      'electrician': 'electrician.svg',
      'painter': 'painter.svg',
      'laundry': 'laundry.svg',
      'mechanic': 'mechanic.svg',
      'cleaner': 'cleaner.svg',
      'contractor': 'contractor.svg',
    };
    
    final iconFileName = iconMap[normalizedName];
    if (iconFileName != null) {
      // Return with 'assets/' prefix since we explicitly listed them in pubspec.yaml
      return 'assets/icon/$iconFileName';
    }
    
    return null;
  }
  
  /// Check if SVG icon exists for a category
  static bool hasSvgIcon(String categoryName) {
    return getSvgIconPath(categoryName) != null;
  }
  
  /// Clear cache (useful for testing or when icons are updated)
  static void clearCache() {
    _firestoreIconCache = {};
    _cacheLoaded = false;
  }
  
  /// Reload icons from Firestore
  static Future<void> reloadFromFirestore() async {
    _cacheLoaded = false;
    await initialize();
  }
}

