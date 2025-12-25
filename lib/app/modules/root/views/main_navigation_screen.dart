import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/views/home_screen.dart';
import '../../home/views/categories_screen.dart';
import '../../search/views/search_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/navigation_controller.dart';

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
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: (index) {
            controller.changePage(index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF4CAF50),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: controller.selectedIndex.value == 0
                    ? BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      )
                    : null,
                child: Icon(
                  controller.selectedIndex.value == 0
                      ? Icons.home_rounded
                      : Icons.home_outlined,
                  size: 24,
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: controller.selectedIndex.value == 1
                    ? BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      )
                    : null,
                child: Icon(
                  controller.selectedIndex.value == 1
                      ? Icons.grid_view_rounded
                      : Icons.grid_view_outlined,
                  size: 24,
                ),
              ),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: controller.selectedIndex.value == 2
                    ? BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      )
                    : null,
                child: Icon(
                  controller.selectedIndex.value == 2
                      ? Icons.search_rounded
                      : Icons.search_outlined,
                  size: 24,
                ),
              ),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: controller.selectedIndex.value == 3
                    ? BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      )
                    : null,
                child: Icon(
                  controller.selectedIndex.value == 3
                      ? Icons.person_rounded
                      : Icons.person_outline_rounded,
                  size: 24,
                ),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    ));
  }
}

