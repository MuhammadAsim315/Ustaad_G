import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/worker_onboarding_controller.dart';
import '../../../utils/responsive_helper.dart';
import '../../home/views/categories_screen.dart';

/// Multi-step worker onboarding screen
class WorkerOnboardingScreen extends StatelessWidget {
  const WorkerOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WorkerOnboardingController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Become a Worker'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(controller),
          
          // Form content
          Expanded(
            child: Obx(() => _buildStepContent(controller, context)),
          ),
          
          // Navigation buttons
          _buildNavigationButtons(controller, context),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(WorkerOnboardingController controller) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(
              controller.totalSteps,
              (index) => Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(
                    right: index < controller.totalSteps - 1 ? 8 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: index <= controller.currentStep.value
                        ? const Color(0xFF4CAF50)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Step ${controller.currentStep.value + 1} of ${controller.totalSteps}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildStepContent(WorkerOnboardingController controller, BuildContext context) {
    switch (controller.currentStep.value) {
      case 0:
        return _buildStep1Services(controller);
      case 1:
        return _buildStep2Availability(controller, context);
      case 2:
        return _buildStep3LocationExperience(controller);
      case 3:
        return _buildStep4Review(controller);
      default:
        return const SizedBox();
    }
  }

  // Step 1: Services & Pricing
  Widget _buildStep1Services(WorkerOnboardingController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Services You Offer',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the services you can provide to customers',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Service selection
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: CategoriesScreen.categories.map((category) {
              final serviceName = category['name'] as String;
              final isSelected = controller.selectedServices.contains(serviceName);
              
              return FilterChip(
                label: Text(serviceName),
                selected: isSelected,
                onSelected: (selected) {
                  controller.toggleService(serviceName);
                },
                selectedColor: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                checkmarkColor: const Color(0xFF4CAF50),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF4CAF50) : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // Pricing for selected services
          if (controller.selectedServices.isNotEmpty) ...[
            const Text(
              'Set Your Pricing',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...controller.selectedServices.map((serviceName) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        serviceName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Price (PKR)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixText: 'PKR ',
                        ),
                        onChanged: (value) {
                          final price = double.tryParse(value) ?? 0.0;
                          controller.updateServicePrice(serviceName, price);
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  // Step 2: Availability
  Widget _buildStep2Availability(WorkerOnboardingController controller, BuildContext context) {
    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Set Your Availability',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the days and hours you\'re available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Days selection
          const Text(
            'Available Days',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: daysOfWeek.map((day) {
              final isSelected = controller.selectedDays.contains(day);
              
              return FilterChip(
                label: Text(day),
                selected: isSelected,
                onSelected: (selected) {
                  controller.toggleDay(day);
                },
                selectedColor: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                checkmarkColor: const Color(0xFF4CAF50),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF4CAF50) : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // Time selection
          const Text(
            'Working Hours',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimePicker(
                  label: 'Start Time',
                  time: controller.startTime.value,
                  onTimeSelected: (time) => controller.startTime.value = time,
                  context: context,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimePicker(
                  label: 'End Time',
                  time: controller.endTime.value,
                  onTimeSelected: (time) => controller.endTime.value = time,
                  context: context,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay time,
    required Function(TimeOfDay) onTimeSelected,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) {
          onTimeSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 3: Location & Experience
  Widget _buildStep3LocationExperience(WorkerOnboardingController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location & Experience',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about your service area and experience',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Service Area
          TextField(
            decoration: InputDecoration(
              labelText: 'Service Area (City/Region)',
              hintText: 'e.g., Lahore, Karachi',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.location_on),
            ),
            onChanged: (value) => controller.serviceArea.value = value,
          ),
          
          const SizedBox(height: 20),
          
          // Years of Experience
          const Text(
            'Years of Experience',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Slider(
            value: controller.yearsOfExperience.value.toDouble(),
            min: 0,
            max: 50,
            divisions: 50,
            label: '${controller.yearsOfExperience.value} years',
            onChanged: (value) {
              controller.yearsOfExperience.value = value.toInt();
            },
          )),
          Obx(() => Text(
            '${controller.yearsOfExperience.value} years',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
            textAlign: TextAlign.center,
          )),
          
          const SizedBox(height: 24),
          
          // Bio
          TextField(
            decoration: InputDecoration(
              labelText: 'Bio / Description',
              hintText: 'Tell customers about yourself and your services...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.description),
            ),
            maxLines: 5,
            onChanged: (value) => controller.bio.value = value,
          ),
        ],
      ),
    );
  }

  // Step 4: Review & Submit
  Widget _buildStep4Review(WorkerOnboardingController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Your Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please review your information before submitting',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          _buildReviewCard(
            'Services',
            controller.selectedServices.join(', '),
            Icons.build,
          ),
          
          const SizedBox(height: 16),
          
          _buildReviewCard(
            'Availability',
            '${controller.selectedDays.join(', ')}\n${_formatTime(controller.startTime.value)} - ${_formatTime(controller.endTime.value)}',
            Icons.calendar_today,
          ),
          
          const SizedBox(height: 16),
          
          _buildReviewCard(
            'Location & Experience',
            '${controller.serviceArea.value}\n${controller.yearsOfExperience.value} years of experience',
            Icons.location_on,
          ),
          
          const SizedBox(height: 16),
          
          if (controller.bio.value.isNotEmpty)
            _buildReviewCard(
              'Bio',
              controller.bio.value,
              Icons.description,
            ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF4CAF50), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(WorkerOnboardingController controller, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (controller.currentStep.value > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: controller.previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF4CAF50)),
                ),
                child: const Text('Previous'),
              ),
            ),
          if (controller.currentStep.value > 0) const SizedBox(width: 12),
          Expanded(
            flex: controller.currentStep.value == 0 ? 1 : 1,
            child: Obx(() {
              if (controller.currentStep.value == controller.totalSteps - 1) {
                return ElevatedButton(
                  onPressed: controller.canSubmit && !controller.isSubmitting.value
                      ? controller.submitOnboarding
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: controller.isSubmitting.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Submit'),
                );
              } else {
                return ElevatedButton(
                  onPressed: () {
                    // Validate current step
                    bool canProceed = false;
                    switch (controller.currentStep.value) {
                      case 0:
                        canProceed = controller.canProceedToStep2;
                        break;
                      case 1:
                        canProceed = controller.canProceedToStep3;
                        break;
                      case 2:
                        canProceed = controller.canProceedToStep4;
                        break;
                    }
                    
                    if (canProceed) {
                      controller.nextStep();
                    } else {
                      Get.snackbar(
                        'Validation',
                        'Please complete all required fields',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Next'),
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
