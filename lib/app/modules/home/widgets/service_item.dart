import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/responsive_helper.dart';

class ServiceItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;

  const ServiceItem({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Get.toNamed('/service-detail', arguments: {
            'serviceName': name,
            'serviceIcon': icon,
            'serviceColor': color,
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.all(ResponsiveHelper.responsiveSpacing(context, mobile: 10, tablet: 12, desktop: 14)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withValues(alpha: 0.15),
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
              Container(
                width: ResponsiveHelper.responsiveIconSize(context, mobile: 60, tablet: 70, desktop: 80),
                height: ResponsiveHelper.responsiveIconSize(context, mobile: 60, tablet: 70, desktop: 80),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: ResponsiveHelper.responsiveIconSize(context, mobile: 28, tablet: 32, desktop: 36),
                  color: color,
                ),
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

