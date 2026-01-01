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
  
  // Professional border color
  Color _getBorderColor() {
    return color.withValues(alpha: 0.15);
  }
  
  // Get SVG path from icon helper
  String? _getSvgPath() {
    return IconHelper.getSvgIconPath(name);
  }
  
  // Build SVG icon widget with proper sizing
  Widget _buildSvgIcon(double size) {
    final svgPath = _getSvgPath();
    
    if (svgPath != null) {
      return SvgPicture.asset(
        svgPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholderBuilder: (BuildContext context) => Icon(
          Icons.category,
          size: size,
          color: color,
        ),
      );
    }
    
    // Fallback to a default icon if SVG not found
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
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getBorderColor(),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveHelper.responsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: _buildSvgIcon(
                        ResponsiveHelper.responsiveIconSize(context, mobile: 48, tablet: 56, desktop: 64),
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.responsiveSpacing(context, mobile: 8, tablet: 10, desktop: 12)),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.responsiveSpacing(context, mobile: 4, tablet: 6, desktop: 8)),
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.responsiveFontSize(context, mobile: 11, tablet: 12, desktop: 13),
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[900],
                          letterSpacing: 0,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
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
          padding: EdgeInsets.all(ResponsiveHelper.responsiveSpacing(context, mobile: 10, tablet: 12, desktop: 14)),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _getBorderColor(),
              width: 1.5,
            ),
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
              _buildSvgIcon(
                ResponsiveHelper.responsiveIconSize(context, mobile: 56, tablet: 64, desktop: 72),
              ),
              SizedBox(height: ResponsiveHelper.responsiveSpacing(context, mobile: 10, tablet: 12, desktop: 14)),
              Text(
                name,
                style: TextStyle(
                  fontSize: ResponsiveHelper.responsiveFontSize(context, mobile: 12, tablet: 13, desktop: 14),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[900],
                  letterSpacing: 0,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

