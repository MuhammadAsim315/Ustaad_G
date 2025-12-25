import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final bool isGrid;

  const CategoryItem({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
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
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 45,
                      color: const Color(0xFF4A5C7A), // Dark blue/purplish-blue
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        letterSpacing: 0.2,
                        height: 1.1,
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
      );
    }

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
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 38,
                color: const Color(0xFF4A5C7A), // Dark blue/purplish-blue
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

