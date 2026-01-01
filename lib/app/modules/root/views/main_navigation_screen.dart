import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/views/home_screen.dart';
import '../../home/views/categories_screen.dart';
import '../../search/views/search_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/navigation_controller.dart';
import '../../../utils/responsive_helper.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController controller = Get.put(NavigationController());
    // Initialize ProfileController early so it's available throughout the app
    Get.put(ProfileController());

    final List<Widget> screens = [
      const HomeScreen(),
      const CategoriesScreen(),
      const SearchScreen(),
      const ProfileScreen(),
    ];

    return Obx(() => Scaffold(
      body: IndexedStack(
        index: controller.selectedIndex.value,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              spreadRadius: 0,
              blurRadius: 30,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: BottomNavigationBar(
            currentIndex: controller.selectedIndex.value,
            onTap: (index) {
              controller.changePage(index);
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF4CAF50),
            unselectedItemColor: Colors.grey[500],
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: ResponsiveHelper.responsiveFontSize(context, mobile: 12, tablet: 13, desktop: 14),
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveHelper.responsiveFontSize(context, mobile: 12, tablet: 13, desktop: 14),
            ),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: controller.selectedIndex.value == 0
                      ? BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        )
                      : null,
                  child: Icon(
                    controller.selectedIndex.value == 0
                        ? Icons.home_rounded
                        : Icons.home_outlined,
                    size: 26,
                    color: controller.selectedIndex.value == 0
                        ? Colors.white
                        : Colors.grey[500],
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: controller.selectedIndex.value == 1
                      ? BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        )
                      : null,
                  child: Icon(
                    controller.selectedIndex.value == 1
                        ? Icons.grid_view_rounded
                        : Icons.grid_view_outlined,
                    size: 26,
                    color: controller.selectedIndex.value == 1
                        ? Colors.white
                        : Colors.grey[500],
                  ),
                ),
                label: 'Categories',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: controller.selectedIndex.value == 2
                      ? BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        )
                      : null,
                  child: Icon(
                    controller.selectedIndex.value == 2
                        ? Icons.search_rounded
                        : Icons.search_outlined,
                    size: 26,
                    color: controller.selectedIndex.value == 2
                        ? Colors.white
                        : Colors.grey[500],
                  ),
                ),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: controller.selectedIndex.value == 3
                      ? BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        )
                      : null,
                  child: Icon(
                    controller.selectedIndex.value == 3
                        ? Icons.person_rounded
                        : Icons.person_outline_rounded,
                    size: 26,
                    color: controller.selectedIndex.value == 3
                        ? Colors.white
                        : Colors.grey[500],
                  ),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

