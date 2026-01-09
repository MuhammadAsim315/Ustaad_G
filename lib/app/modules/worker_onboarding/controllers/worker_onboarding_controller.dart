import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firestore_service.dart';
import '../../../services/role_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/analytics_service.dart';
import '../../root/controllers/role_controller.dart';

/// Controller for worker onboarding flow
class WorkerOnboardingController extends GetxController {
  // Step tracking
  var currentStep = 0.obs;
  final int totalSteps = 4;

  // Step 1: Services & Pricing
  var selectedServices = <String>[].obs;
  var servicePricing = <String, double>{}.obs; // serviceName -> price

  // Step 2: Availability
  var selectedDays = <String>[].obs; // ['Monday', 'Tuesday', ...]
  var startTime = const TimeOfDay(hour: 9, minute: 0).obs;
  var endTime = const TimeOfDay(hour: 17, minute: 0).obs;

  // Step 3: Location & Experience
  var serviceArea = ''.obs; // City/Region
  var yearsOfExperience = 0.obs;
  var bio = ''.obs;
  var skills = <String>[].obs;

  // Step 4: Profile Photo (optional)
  var profileImagePath = Rx<String?>('');

  // Loading state
  var isLoading = false.obs;
  var isSubmitting = false.obs;

  // Validation
  bool get canProceedToStep2 => selectedServices.isNotEmpty;
  bool get canProceedToStep3 => selectedDays.isNotEmpty;
  bool get canProceedToStep4 => serviceArea.value.isNotEmpty && yearsOfExperience.value > 0;
  bool get canSubmit => canProceedToStep4 && bio.value.isNotEmpty;

  void nextStep() {
    if (currentStep.value < totalSteps - 1) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void toggleService(String serviceName) {
    if (selectedServices.contains(serviceName)) {
      selectedServices.remove(serviceName);
      servicePricing.remove(serviceName);
    } else {
      selectedServices.add(serviceName);
      servicePricing[serviceName] = 0.0; // Default price
    }
  }

  void updateServicePrice(String serviceName, double price) {
    if (selectedServices.contains(serviceName)) {
      servicePricing[serviceName] = price;
    }
  }

  void toggleDay(String day) {
    if (selectedDays.contains(day)) {
      selectedDays.remove(day);
    } else {
      selectedDays.add(day);
    }
  }

  Future<void> submitOnboarding() async {
    try {
      isSubmitting.value = true;

      final userId = AuthService.currentUserId;
      if (userId == null) {
        Get.snackbar('Error', 'Please login to continue');
        isSubmitting.value = false;
        return;
      }

      debugPrint('WorkerOnboarding: Starting submission for user: $userId');

      // Check if user is already a worker
      final currentRole = await RoleService.getCurrentUserRole();
      debugPrint('WorkerOnboarding: Current role: $currentRole');
      
      if (currentRole == 'worker') {
        Get.snackbar('Info', 'You are already registered as a worker');
        Get.back();
        isSubmitting.value = false;
        return;
      }

      // Prepare worker data
      final workerData = {
        'role': 'worker',
        'servicesOffered': selectedServices.toList(),
        'servicePricing': servicePricing.map((key, value) => MapEntry(key, value)),
        'availability': {
          'days': selectedDays.toList(),
          'startTime': '${startTime.value.hour}:${startTime.value.minute.toString().padLeft(2, '0')}',
          'endTime': '${endTime.value.hour}:${endTime.value.minute.toString().padLeft(2, '0')}',
        },
        'serviceArea': serviceArea.value,
        'yearsOfExperience': yearsOfExperience.value,
        'bio': bio.value,
        'skills': skills.toList(),
        'profileImageUrl': profileImagePath.value ?? '',
        'workerStatus': 'active', // active, inactive, suspended
        'onboardingCompleted': true,
        'onboardingCompletedAt': FieldValue.serverTimestamp(),
      };

      debugPrint('WorkerOnboarding: Worker data prepared: $workerData');

      // Update user data with worker information
      await FirestoreService.updateUserWorkerData(userId, workerData);
      
      // Track worker registration event
      await AnalyticsService.logWorkerRegistration(
        userId: userId,
        services: selectedServices.toList(),
        location: serviceArea.value.isNotEmpty ? serviceArea.value : null,
      );
      await AnalyticsService.setUserRole('worker');
      
      debugPrint('WorkerOnboarding: Worker data saved successfully');

      // Wait a bit for Firestore to propagate the changes
      await Future.delayed(const Duration(milliseconds: 500));

      // Verify the role was updated (try up to 3 times with delays)
      String? updatedRole;
      for (int i = 0; i < 3; i++) {
        await Future.delayed(const Duration(milliseconds: 300));
        updatedRole = await RoleService.getCurrentUserRole();
        debugPrint('WorkerOnboarding: Role check ${i + 1}: $updatedRole');
        if (updatedRole == 'worker') {
          break;
        }
      }
      
      debugPrint('WorkerOnboarding: Final role after update: $updatedRole');
      
      if (updatedRole != 'worker') {
        debugPrint('WorkerOnboarding: WARNING - Role was not updated correctly!');
        Get.snackbar(
          'Warning',
          'Profile updated but role may not have changed. Please refresh the app.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        // Show success message
        Get.snackbar(
          'Success',
          'Worker profile created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }

      // Navigate back and refresh
      Get.back();
      
      // Refresh role controller if it exists
      if (Get.isRegistered<RoleController>()) {
        await Get.find<RoleController>().loadUserRole();
        debugPrint('WorkerOnboarding: Role controller refreshed');
      }

    } catch (e, stackTrace) {
      debugPrint('Error submitting worker onboarding: $e');
      debugPrint('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to create worker profile: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void reset() {
    currentStep.value = 0;
    selectedServices.clear();
    servicePricing.clear();
    selectedDays.clear();
    startTime.value = const TimeOfDay(hour: 9, minute: 0);
    endTime.value = const TimeOfDay(hour: 17, minute: 0);
    serviceArea.value = '';
    yearsOfExperience.value = 0;
    bio.value = '';
    skills.clear();
    profileImagePath.value = '';
  }
}

