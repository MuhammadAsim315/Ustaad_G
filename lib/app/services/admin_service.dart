import 'package:flutter/foundation.dart' show debugPrint;
import 'firestore_service.dart';
import 'role_service.dart';

/// Service for admin functionality and role checking
class AdminService {
  /// Check if current user is admin
  static Future<bool> isAdmin() async {
    return await RoleService.isAdmin();
  }

  /// Check if a specific user is admin
  static Future<bool> isUserAdmin(String userId) async {
    final role = await RoleService.getUserRole(userId);
    return role == 'admin';
  }

  /// Get current user role
  static Future<String?> getCurrentUserRole() async {
    return await RoleService.getCurrentUserRole();
  }

  /// Set user role (admin only)
  static Future<void> setUserRole(String userId, String role) async {
    try {
      // Verify current user is admin
      if (!await isAdmin()) {
        throw Exception('Only admins can change user roles');
      }

      // Validate role
      if (!['customer', 'worker', 'admin'].contains(role)) {
        throw Exception('Invalid role: $role');
      }

      await FirestoreService.updateUserRole(userId, role);
    } catch (e) {
      debugPrint('Error setting user role: $e');
      rethrow;
    }
  }

  /// Ban/unban user
  static Future<void> setUserStatus(String userId, bool isBanned, {String? reason}) async {
    try {
      if (!await isAdmin()) {
        throw Exception('Only admins can ban/unban users');
      }

      await FirestoreService.updateUserStatus(userId, isBanned, reason: reason);
    } catch (e) {
      debugPrint('Error setting user status: $e');
      rethrow;
    }
  }
}

