import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/category_item.dart';
import '../../root/controllers/navigation_controller.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static final List<Map<String, dynamic>> categories = [
    {'name': 'Plumber', 'icon': Icons.plumbing, 'color': Colors.blue as Color},
    {'name': 'Carpenter', 'icon': Icons.carpenter, 'color': Colors.brown as Color},
    {'name': 'Welder', 'icon': Icons.build, 'color': Colors.orange as Color},
    {'name': 'Contractor', 'icon': Icons.construction, 'color': Colors.grey as Color},
    {'name': 'Electrician', 'icon': Icons.electrical_services, 'color': Colors.yellow[700]!},
    {'name': 'Painter', 'icon': Icons.format_paint, 'color': Colors.purple as Color},
    {'name': 'Laundry', 'icon': Icons.local_laundry_service, 'color': Colors.cyan as Color},
    {'name': 'Mechanic', 'icon': Icons.car_repair, 'color': Colors.red as Color},
    {'name': 'Cleaner', 'icon': Icons.cleaning_services, 'color': Colors.teal as Color},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced header with back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Switch to home tab since categories is part of main navigation
                        Get.find<NavigationController>().changePage(0);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.black87,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            
            // Categories grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: CategoriesScreen.categories.length,
                  itemBuilder: (context, index) {
                    final category = CategoriesScreen.categories[index];
                    return CategoryItem(
                      name: category['name'],
                      icon: category['icon'],
                      color: category['color'],
                      isGrid: true,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

