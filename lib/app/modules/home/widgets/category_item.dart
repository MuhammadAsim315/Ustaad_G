import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utils/responsive_helper.dart';
import '../../../utils/icon_helper.dart';

class CategoryItem extends StatelessWidget {
  final String name;
  final Color color;
  final bool isGrid;

  const CategoryItem({
    super.key,
    required this.name,
    required this.color,
    this.isGrid = false,
  });

  // Professional background color (subtle, not cartoony)
  Color _getBackgroundColor() {
    return Colors.white;
  }
  
  // Get SVG path from icon helper
  String? _getSvgPath() {
    return IconHelper.getSvgIconPath(name);
  }
  
  // Build SVG icon widget with proper sizing
  Widget _buildSvgIcon(double size) {
    final svgPath = _getSvgPath();
    
    if (svgPath != null) {
      // Debug: Print the path being used
      debugPrint('Loading SVG for category "$name" with path: "$svgPath"');
      
      // Try loading the asset - need to use 'assets/' prefix since we explicitly listed them in pubspec.yaml
      // First try with 'assets/' prefix, then without
      String? pathToTry = svgPath.startsWith('assets/') ? svgPath : 'assets/$svgPath';
      
      try {
        // Scale up the SVG to zoom in and crop whitespace, then clip to remove extra space
        // All icons use the same rendering pipeline for consistent quality like welder and mechanic
        // Increased scale and using BoxFit.fitWidth for better clarity and size
        return ClipRect(
          clipBehavior: Clip.hardEdge,
          child: Transform.scale(
            scale: 1.6, // Increased scale for better clarity and size like welder/mechanic
            child: SvgPicture.asset(
              pathToTry,
              width: size * 1.1, // Slightly larger width for better clarity
              height: size * 1.1, // Slightly larger height for better clarity
              fit: BoxFit.fitWidth, // Use fitWidth for better clarity
              alignment: Alignment.center,
              allowDrawingOutsideViewBox: false,
              semanticsLabel: name,
              placeholderBuilder: (BuildContext context) {
                debugPrint('⚠️ CategoryItem: Placeholder shown for SVG: "$pathToTry" (asset may be loading)');
                return Icon(
                  Icons.category,
                  size: size,
                  color: color,
                );
              },
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                debugPrint('❌ CategoryItem: ERROR loading SVG asset: "$pathToTry" for category: "$name"');
                debugPrint('❌ Error type: ${error.runtimeType}');
                debugPrint('❌ Error details: $error');
                
                // Try the path without 'assets/' prefix as fallback
                final fallbackPath = pathToTry.startsWith('assets/') ? pathToTry.substring(7) : pathToTry;
                debugPrint('⚠️ CategoryItem: Trying fallback path: "$fallbackPath"');
                
                // Return a widget that tries the fallback path
                return ClipRect(
                  clipBehavior: Clip.hardEdge,
                  child: Transform.scale(
                    scale: 1.6, // Increased scale for better clarity and size like welder/mechanic
                    child: SvgPicture.asset(
                      fallbackPath,
                      width: size * 1.1, // Slightly larger width for better clarity
                      height: size * 1.1, // Slightly larger height for better clarity
                      fit: BoxFit.fitWidth, // Use fitWidth for better clarity
                      alignment: Alignment.center,
                      allowDrawingOutsideViewBox: false,
                      semanticsLabel: name,
                      errorBuilder: (context, error2, stackTrace2) {
                        debugPrint('❌ CategoryItem: Fallback path also failed: "$fallbackPath"');
                        return Icon(
                          Icons.category,
                          size: size,
                          color: color,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      } catch (e, stackTrace) {
        debugPrint('❌ CategoryItem: Exception loading SVG "$pathToTry": $e');
        debugPrint('❌ Stack trace: $stackTrace');
        return Icon(
          Icons.category,
          size: size,
          color: color,
        );
      }
    }
    
    // Fallback to a default icon if SVG not found
    debugPrint('No SVG path found for category: $name');
    return Icon(
      Icons.category,
      size: size,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.toNamed('/service-detail', arguments: {
              'serviceName': name,
              'serviceSvgPath': _getSvgPath(),
              'serviceColor': color,
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(ResponsiveHelper.responsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16)),
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon only - larger size for better clarity like welder/mechanic
                _buildSvgIcon(
                  ResponsiveHelper.responsiveIconSize(context, mobile: 80, tablet: 92, desktop: 104),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Get.toNamed('/service-detail', arguments: {
            'serviceName': name,
            'serviceSvgPath': _getSvgPath(),
            'serviceColor': color,
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.all(ResponsiveHelper.responsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16)),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon only - larger size for better clarity like welder/mechanic
              _buildSvgIcon(
                ResponsiveHelper.responsiveIconSize(context, mobile: 84, tablet: 96, desktop: 108),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

