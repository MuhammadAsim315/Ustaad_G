import 'package:flutter/material.dart';

/// Helper class for responsive design
/// Provides utilities to make the app work on all screen sizes
class ResponsiveHelper {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return screenWidth(context) < mobileBreakpoint;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = screenWidth(context);
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= tabletBreakpoint;
  }

  /// Get responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 20);
    }
  }

  /// Get responsive horizontal padding
  static double horizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return 16;
    } else if (isTablet(context)) {
      return 32;
    } else {
      return 48;
    }
  }

  /// Get responsive font size
  static double responsiveFontSize(BuildContext context, {
    double mobile = 14,
    double? tablet,
    double? desktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 1.2;
    } else {
      return desktop ?? mobile * 1.4;
    }
  }

  /// Get responsive icon size
  static double responsiveIconSize(BuildContext context, {
    double mobile = 24,
    double? tablet,
    double? desktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 1.2;
    } else {
      return desktop ?? mobile * 1.4;
    }
  }

  /// Get responsive grid cross axis count
  static int gridCrossAxisCount(BuildContext context, {
    int mobile = 2,
    int? tablet,
    int? desktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? 3;
    } else {
      return desktop ?? 4;
    }
  }

  /// Get responsive item count per row
  static int itemsPerRow(BuildContext context, {
    int mobile = 2,
    int? tablet,
    int? desktop,
  }) {
    return gridCrossAxisCount(context, mobile: mobile, tablet: tablet, desktop: desktop);
  }

  /// Get max content width for centered layouts
  static double maxContentWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 768;
    } else {
      return 1200;
    }
  }

  /// Get responsive spacing
  static double responsiveSpacing(BuildContext context, {
    double mobile = 8,
    double? tablet,
    double? desktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 1.5;
    } else {
      return desktop ?? mobile * 2;
    }
  }
}

