import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/views/onboarding_screen.dart';
import '../../auth/views/login_screen.dart';
import '../../../utils/preferences_helper.dart';

/// Initial screen that checks if onboarding has been seen
/// and routes to appropriate screen
class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final hasSeenOnboarding = await PreferencesHelper.hasSeenOnboarding();
    
    // Small delay to show splash if needed
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    if (hasSeenOnboarding) {
      Get.offNamed('/login');
    } else {
      Get.offNamed('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Name
            const Text(
              'UstaadG',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          ],
        ),
      ),
    );
  }
}

