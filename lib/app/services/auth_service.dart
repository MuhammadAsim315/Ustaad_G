import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../utils/preferences_helper.dart';
import 'analytics_service.dart';

/// Service for managing authentication state
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  /// Stream of authentication state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if user is logged in
  static bool get isLoggedIn => _auth.currentUser != null;

  /// Sign out user
  static Future<void> logout() async {
    try {
      // Clear analytics user data
      await AnalyticsService.clearUserData();
      
      await _auth.signOut();
      await PreferencesHelper.logout();
      debugPrint('User logged out successfully');
    } catch (e) {
      debugPrint('Error logging out: $e');
      rethrow;
    }
  }

  /// Delete user account
  static Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        await PreferencesHelper.logout();
        debugPrint('User account deleted successfully');
      }
    } catch (e) {
      debugPrint('Error deleting account: $e');
      rethrow;
    }
  }

  /// Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('Password reset email sent');
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      rethrow;
    }
  }

  /// Reload current user
  static Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      debugPrint('Error reloading user: $e');
    }
  }
}

