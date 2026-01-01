/// Helper class to map category names to SVG icon paths
class IconHelper {
  /// Maps category name to SVG icon path
  /// Returns null if icon doesn't exist
  static String? getSvgIconPath(String categoryName) {
    // Convert category name to lowercase for matching
    final normalizedName = categoryName.toLowerCase();
    
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
      return 'icon/$iconFileName';
    }
    
    return null;
  }
  
  /// Check if SVG icon exists for a category
  static bool hasSvgIcon(String categoryName) {
    return getSvgIconPath(categoryName) != null;
  }
}

