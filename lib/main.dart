import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/modules/home/views/onboarding_screen.dart';
import 'app/modules/root/views/main_navigation_screen.dart';
import 'app/modules/e_services/views/service_detail_screen.dart';
import 'app/modules/bookings/views/booking_screen.dart';
import 'app/modules/bookings/views/my_bookings_screen.dart';
import 'app/modules/bookings/views/booking_success_screen.dart';
import 'app/modules/checkout/views/checkout_screen.dart';
import 'app/modules/profile/views/edit_profile_screen.dart';
import 'app/modules/settings/views/settings_screen.dart';
import 'app/modules/help_privacy/views/help_support_screen.dart';
import 'app/modules/notifications/views/notifications_screen.dart';
import 'app/modules/reviews/views/review_screen.dart';
import 'app/modules/home/views/newsfeed_screen.dart';
import 'app/modules/home/views/my_services_screen.dart';
import 'app/modules/home/views/earnings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ustad G',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50), // Green color from mockup
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF4CAF50),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const OnboardingScreen()),
        GetPage(name: '/main', page: () => const MainNavigationScreen()),
        GetPage(name: '/service-detail', page: () {
          final args = Get.arguments as Map<String, dynamic>;
          return ServiceDetailScreen(
            serviceName: args['serviceName'],
            serviceSvgPath: args['serviceSvgPath'],
            serviceColor: args['serviceColor'] ?? Colors.blue,
          );
        }),
        GetPage(name: '/booking', page: () => const BookingScreen()),
        GetPage(name: '/checkout', page: () => const CheckoutScreen()),
        GetPage(name: '/booking-success', page: () => const BookingSuccessScreen()),
        GetPage(name: '/my-bookings', page: () => const MyBookingsScreen()),
        GetPage(name: '/edit-profile', page: () => const EditProfileScreen()),
        GetPage(name: '/settings', page: () => const SettingsScreen()),
        GetPage(name: '/help-support', page: () => const HelpSupportScreen()),
        GetPage(name: '/notifications', page: () => const NotificationsScreen()),
        GetPage(name: '/review', page: () => const ReviewScreen()),
        GetPage(name: '/newsfeed', page: () => const NewsfeedScreen()),
        GetPage(name: '/my-services', page: () => const MyServicesScreen()),
        GetPage(name: '/earnings', page: () => const EarningsScreen()),
      ],
    );
  }
}
