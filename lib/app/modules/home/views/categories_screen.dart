import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/category_item.dart';
import '../../root/controllers/navigation_controller.dart';
import '../../../utils/responsive_helper.dart';

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
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Center content on larger screens
            if (isDesktop) {
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: ResponsiveHelper.maxContentWidth(context)),
                  child: _buildContent(context, horizontalPadding),
                ),
              );
            }
            return _buildContent(context, horizontalPadding);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, double horizontalPadding) {
    return Column(
      children: [
        // Enhanced header with back button
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4CAF50),
                Color(0xFF66BB6A),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: ResponsiveHelper.responsiveSpacing(context, mobile: 20, tablet: 24, desktop: 28),
            ),
            child: Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Get.find<NavigationController>().changePage(0);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.responsiveFontSize(context, mobile: 28, tablet: 32, desktop: 36),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Categories grid
        Expanded(
          child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    ResponsiveHelper.responsiveSpacing(context, mobile: 30, tablet: 36, desktop: 40),
                    horizontalPadding,
                    ResponsiveHelper.responsiveSpacing(context, mobile: 20, tablet: 24, desktop: 28),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = ResponsiveHelper.gridCrossAxisCount(
                        context,
                        mobile: 3,
                        tablet: 4,
                        desktop: 5,
                      );
                      return GridView.builder(
                        padding: EdgeInsets.only(
                          bottom: ResponsiveHelper.responsiveSpacing(context, mobile: 20, tablet: 24, desktop: 28),
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: ResponsiveHelper.responsiveSpacing(context, mobile: 20, tablet: 24, desktop: 28),
                          mainAxisSpacing: ResponsiveHelper.responsiveSpacing(context, mobile: 20, tablet: 24, desktop: 28),
                          childAspectRatio: ResponsiveHelper.isMobile(context) ? 0.95 : 1.0,
                        ),
                    itemCount: CategoriesScreen.categories.length,
                        itemBuilder: (context, index) {
                          final category = CategoriesScreen.categories[index];
                          return CategoryItem(
                            name: category['name'] as String,
                            icon: category['icon'] as IconData,
                            color: category['color'] as Color,
                            isGrid: true,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
  }
}

