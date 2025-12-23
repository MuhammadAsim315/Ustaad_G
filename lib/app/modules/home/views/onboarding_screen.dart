import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Main illustration area
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Enhanced illustration with gradient and shadow
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF4CAF50).withOpacity(0.1),
                            const Color(0xFF4CAF50).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background decorative circles
                          Positioned(
                            top: 20,
                            left: 20,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 30,
                            right: 30,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          // Main icon
                          const Icon(
                            Icons.build_circle,
                            size: 140,
                            color: Color(0xFF4CAF50),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    
                    // Enhanced pagination dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(0),
                        const SizedBox(width: 10),
                        _buildDot(1),
                        const SizedBox(width: 10),
                        _buildDot(2),
                      ],
                    ),
                    const SizedBox(height: 50),
                    
                    // Enhanced title with gradient text effect
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                      ).createShader(bounds),
                      child: const Text(
                        'Find Services You Need',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Enhanced description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Ustad G is a service provider platform we create this app to help our users to easily find skilled workers online so that they don\'t have to search manually saves both money & time',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.6,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Enhanced next button with shadow and animation
            Padding(
              padding: const EdgeInsets.all(30),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Get.offNamed('/main');
                  },
                  borderRadius: BorderRadius.circular(35),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        shape: _currentPage == index ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: _currentPage == index ? BorderRadius.circular(4) : null,
        color: _currentPage == index
            ? const Color(0xFF4CAF50)
            : Colors.grey[300],
      ),
    );
  }
}

