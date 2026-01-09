import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../../../services/firestore_service.dart';

class AdminDashboardController extends GetxController {
  var isLoading = true.obs;
  var stats = <String, dynamic>{}.obs;
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final dashboardStats = await FirestoreService.getDashboardStats();
      stats.value = dashboardStats;
    } catch (e) {
      debugPrint('Error loading dashboard stats: $e');
      error.value = 'Failed to load statistics: $e';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() async {
    await loadStats();
  }
}

