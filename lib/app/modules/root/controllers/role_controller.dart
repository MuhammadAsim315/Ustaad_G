import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../../../services/role_service.dart';

/// Controller to manage user role state
class RoleController extends GetxController {
  var userRole = Rx<String?>('customer');
  var isLoading = true.obs;
  var isCustomer = false.obs;
  var isWorker = false.obs;
  var isAdmin = false.obs;
  var isBanned = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserRole();
  }

  /// Load current user role
  Future<void> loadUserRole() async {
    try {
      isLoading.value = true;
      
      final role = await RoleService.getCurrentUserRole();
      userRole.value = role ?? 'customer';
      
      // Update role flags
      isCustomer.value = role == 'customer';
      isWorker.value = role == 'worker';
      isAdmin.value = role == 'admin';
      
      // Check if user is banned
      isBanned.value = await RoleService.isCurrentUserBanned();
      
      debugPrint('User role loaded: $role');
    } catch (e) {
      debugPrint('Error loading user role: $e');
      // Default to customer on error
      userRole.value = 'customer';
      isCustomer.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh user role
  @override
  Future<void> refresh() async {
    await loadUserRole();
  }

  /// Check if user can access worker features
  bool canAccessWorkerFeatures() {
    return isWorker.value || isAdmin.value;
  }

  /// Check if user can access admin features
  bool canAccessAdminFeatures() {
    return isAdmin.value;
  }
}

