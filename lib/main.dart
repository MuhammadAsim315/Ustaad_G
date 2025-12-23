import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/modules/home/views/onboarding_screen.dart';
import 'app/modules/root/views/main_navigation_screen.dart';

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
      ],
    );
  }
}
