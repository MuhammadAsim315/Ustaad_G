import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'firestore_service.dart';

/// Service for role management and checking
class RoleService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user role
  static Future<String?> getCurrentUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userData = await FirestoreService.getUserData(user.uid);
      return userData?['role'] as String? ?? 'customer'; // Default to customer
    } catch (e) {
      debugPrint('Error getting user role: $e');
      return 'customer'; // Default fallback
    }
  }

  /// Check if current user is customer
  static Future<bool> isCustomer() async {
    final role = await getCurrentUserRole();
    return role == 'customer';
  }

  /// Check if current user is worker
  static Future<bool> isWorker() async {
    final role = await getCurrentUserRole();
    return role == 'worker';
  }

  /// Check if current user is admin
  static Future<bool> isAdmin() async {
    final role = await getCurrentUserRole();
    return role == 'admin';
  }

  /// Check if user has specific role
  static Future<bool> hasRole(String role) async {
    final userRole = await getCurrentUserRole();
    return userRole == role;
  }

  /// Get user role for a specific user ID
  static Future<String?> getUserRole(String userId) async {
    try {
      final userData = await FirestoreService.getUserData(userId);
      return userData?['role'] as String? ?? 'customer';
    } catch (e) {
      debugPrint('Error getting user role: $e');
      return 'customer';
    }
  }

  /// Check if user is banned
  static Future<bool> isUserBanned(String userId) async {
    try {
      final userData = await FirestoreService.getUserData(userId);
      return userData?['isBanned'] as bool? ?? false;
    } catch (e) {
      debugPrint('Error checking user ban status: $e');
      return false;
    }
  }

  /// Check if current user is banned
  static Future<bool> isCurrentUserBanned() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      return await isUserBanned(user.uid);
    } catch (e) {
      debugPrint('Error checking current user ban status: $e');
      return false;
    }
  }
}

