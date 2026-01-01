import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import '../../root/controllers/navigation_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../widgets/category_item.dart';
import '../widgets/nav_icon_item.dart';
import '../widgets/service_item.dart';
import '../../../utils/responsive_helper.dart';

// Conditional import for File (only on non-web platforms)
// ignore: unused_import
import 'dart:io' if (dart.library.html) 'dart:html';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure ProfileController is initialized
    Get.put(ProfileController());
  }

  ImageProvider? _getImageProvider(ProfileController controller) {
    if (kIsWeb) {
      if (controller.profileImageBytes.value != null) {
        return MemoryImage(controller.profileImageBytes.value!);
      }
    } else {
      if (controller.profileImage.value != null) {
        return FileImage(controller.profileImage.value!);
      }
    }
    return null;
  }

  final List<Map<String, dynamic>> categories = [
    {'name': 'Plumber', 'color': Colors.blue},
    {'name': 'Carpenter', 'color': Colors.brown},
    {'name': 'Welder', 'color': Colors.orange},
    {'name': 'Electrician', 'color': Colors.yellow[700]!},
  ];

  final List<Map<String, dynamic>> services = [
    {'name': 'Plumber', 'color': Colors.blue},
    {'name': 'Carpenter', 'color': Colors.brown},
    {'name': 'Welder', 'color': Colors.orange},
    {'name': 'Electrician', 'color': Colors.yellow[700]!},
  ];

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Center content on larger screens
            if (isDesktop) {
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveHelper.maxContentWidth(context),
                  ),
                  child: _buildContent(
                    context,
                    horizontalPadding,
                    isMobile,
                    isTablet,
                    isDesktop,
                  ),
                ),
              );
            }
            return _buildContent(
              context,
              horizontalPadding,
              isMobile,
              isTablet,
              isDesktop,
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    double horizontalPadding,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Enhanced top bar with profile
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: ResponsiveHelper.responsiveSpacing(
                context,
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),
            child: Row(
              children: [
                Obx(() {
                  final ProfileController profileController =
                      Get.find<ProfileController>();
                  final ImageProvider? imageProvider = _getImageProvider(
                    profileController,
                  );

                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4CAF50).withValues(alpha: 0.2),
                          const Color(0xFF66BB6A).withValues(alpha: 0.1),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius:
                          ResponsiveHelper.responsiveIconSize(
                            context,
                            mobile: 20,
                            tablet: 22,
                            desktop: 24,
                          ) /
                          2,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: imageProvider != null
                            ? Image(
                                image: imageProvider,
                                fit: BoxFit.cover,
                                width: ResponsiveHelper.responsiveIconSize(
                                  context,
                                  mobile: 40,
                                  tablet: 44,
                                  desktop: 48,
                                ),
                                height: ResponsiveHelper.responsiveIconSize(
                                  context,
                                  mobile: 40,
                                  tablet: 44,
                                  desktop: 48,
                                ),
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(
                                            0xFF4CAF50,
                                          ).withValues(alpha: 0.1),
                                          const Color(
                                            0xFF66BB6A,
                                          ).withValues(alpha: 0.05),
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Color(0xFF4CAF50),
                                      size: 16,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(
                                        0xFF4CAF50,
                                      ).withValues(alpha: 0.1),
                                      const Color(
                                        0xFF66BB6A,
                                      ).withValues(alpha: 0.05),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Color(0xFF4CAF50),
                                  size: 16,
                                ),
                              ),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: ResponsiveHelper.responsiveFontSize(
                          context,
                          mobile: 12,
                          tablet: 13,
                          desktop: 14,
                        ),
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Obx(() {
                      final ProfileController profileController =
                          Get.find<ProfileController>();
                      return Text(
                        profileController.name.value,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.responsiveFontSize(
                            context,
                            mobile: 18,
                            tablet: 20,
                            desktop: 22,
                          ),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      );
                    }),
                  ],
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      Get.toNamed('/notifications');
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.person_outline, color: Colors.black87),
                    onPressed: () {
                      // Navigate to profile tab
                      Get.find<NavigationController>().changePage(3);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Enhanced search bar
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: ResponsiveHelper.responsiveSpacing(
                context,
                mobile: 10,
                tablet: 12,
                desktop: 15,
              ),
            ),
            child: Container(
              height: ResponsiveHelper.isMobile(context) ? 56 : 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for services',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Color(0xFF4CAF50),
                      size: 16,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
              ),
            ),
          ),

          // Enhanced banner with gradient
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: ResponsiveHelper.responsiveSpacing(
                context,
                mobile: 10,
                tablet: 12,
                desktop: 15,
              ),
            ),
            child: Container(
              height: ResponsiveHelper.isMobile(context)
                  ? 160
                  : ResponsiveHelper.isTablet(context)
                  ? 180
                  : 200,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Decorative circles
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -10,
                    left: -10,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    top: 0,
                    bottom: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GET YOUR',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Needed Service',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Book Now',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 24,
                    top: 20,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.build_circle,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Navigation icons
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: ResponsiveHelper.responsiveSpacing(
                context,
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: ResponsiveHelper.responsiveSpacing(
                    context,
                    mobile: 8,
                    tablet: 16,
                    desktop: 24,
                  ),
                  runSpacing: ResponsiveHelper.responsiveSpacing(
                    context,
                    mobile: 8,
                    tablet: 12,
                    desktop: 16,
                  ),
                  children: [
                    NavIconItem(
                      icon: Icons.article_outlined,
                      label: 'Newsfeed',
                      isSelected: false,
                      route: '/newsfeed',
                    ),
                    NavIconItem(
                      icon: Icons.dashboard,
                      label: 'Dashboard',
                      isSelected: true,
                    ),
                    NavIconItem(
                      icon: Icons.build,
                      label: 'My Services',
                      isSelected: false,
                      route: '/my-services',
                    ),
                    NavIconItem(
                      icon: Icons.attach_money,
                      label: 'Earnings',
                      isSelected: false,
                      route: '/earnings',
                    ),
                  ],
                );
              },
            ),
          ),

          // Categories section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: ResponsiveHelper.responsiveSpacing(
                    context,
                    mobile: 12,
                    tablet: 16,
                    desktop: 20,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.responsiveFontSize(
                              context,
                              mobile: 22,
                              tablet: 24,
                              desktop: 26,
                            ),
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(
                          height: ResponsiveHelper.responsiveSpacing(
                            context,
                            mobile: 4,
                            tablet: 6,
                            desktop: 8,
                          ),
                        ),
                        Text(
                          'All categories of services',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.responsiveFontSize(
                              context,
                              mobile: 13,
                              tablet: 14,
                              desktop: 15,
                            ),
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Navigate to categories tab in main navigation
                          Get.find<NavigationController>().changePage(1);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'See all',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: Color(0xFF4CAF50),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: ResponsiveHelper.responsiveSpacing(
                    context,
                    mobile: 10,
                    tablet: 12,
                    desktop: 15,
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemsPerRow = ResponsiveHelper.itemsPerRow(
                      context,
                      mobile: 4,
                      tablet: 4,
                      desktop: 4,
                    );
                    final itemWidth =
                        (constraints.maxWidth -
                            (horizontalPadding * 2) -
                            (ResponsiveHelper.responsiveSpacing(
                                  context,
                                  mobile: 8,
                                  tablet: 12,
                                  desktop: 16,
                                ) *
                                (itemsPerRow - 1))) /
                        itemsPerRow;

                    return Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      spacing: ResponsiveHelper.responsiveSpacing(
                        context,
                        mobile: 8,
                        tablet: 12,
                        desktop: 16,
                      ),
                      runSpacing: ResponsiveHelper.responsiveSpacing(
                        context,
                        mobile: 12,
                        tablet: 16,
                        desktop: 20,
                      ),
                      children: categories.take(4).map((category) {
                        return SizedBox(
                          width: ResponsiveHelper.isMobile(context)
                              ? null
                              : itemWidth,
                          child: CategoryItem(
                            name: category['name'] as String,
                            color: category['color'] as Color,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),

              // Services you may need section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: ResponsiveHelper.responsiveSpacing(
                    context,
                    mobile: 20,
                    tablet: 24,
                    desktop: 28,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Services you may need',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.responsiveFontSize(
                          context,
                          mobile: 22,
                          tablet: 24,
                          desktop: 26,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Navigate to categories tab
                          Get.find<NavigationController>().changePage(1);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'See all',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: Color(0xFF4CAF50),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: ResponsiveHelper.responsiveSpacing(
                    context,
                    mobile: 10,
                    tablet: 12,
                    desktop: 15,
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemsPerRow = ResponsiveHelper.itemsPerRow(
                      context,
                      mobile: 4,
                      tablet: 4,
                      desktop: 4,
                    );
                    final itemWidth =
                        (constraints.maxWidth -
                            (horizontalPadding * 2) -
                            (ResponsiveHelper.responsiveSpacing(
                                  context,
                                  mobile: 8,
                                  tablet: 12,
                                  desktop: 16,
                                ) *
                                (itemsPerRow - 1))) /
                        itemsPerRow;

                    return Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      spacing: ResponsiveHelper.responsiveSpacing(
                        context,
                        mobile: 8,
                        tablet: 12,
                        desktop: 16,
                      ),
                      runSpacing: ResponsiveHelper.responsiveSpacing(
                        context,
                        mobile: 12,
                        tablet: 16,
                        desktop: 20,
                      ),
                      children: services.take(4).map((service) {
                        return SizedBox(
                          width: ResponsiveHelper.isMobile(context)
                              ? null
                              : itemWidth,
                          child: ServiceItem(
                            name: service['name'] as String,
                            color: service['color'] as Color,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),

              SizedBox(
                height: ResponsiveHelper.responsiveSpacing(
                  context,
                  mobile: 20,
                  tablet: 24,
                  desktop: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
