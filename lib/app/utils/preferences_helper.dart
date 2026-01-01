import 'package:shared_preferences/shared_preferences.dart';

/// Helper class to manage app preferences
class PreferencesHelper {
  static const String _keyOnboardingSeen = 'onboarding_seen';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyIsGuest = 'is_guest';

  /// Check if onboarding has been seen
  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingSeen) ?? false;
  }

  /// Mark onboarding as seen
  static Future<void> setOnboardingSeen(bool seen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingSeen, seen);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Set login status
  static Future<void> setLoggedIn(bool loggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, loggedIn);
  }

  /// Check if user is guest
  static Future<bool> isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsGuest) ?? false;
  }

  /// Set guest status
  static Future<void> setGuest(bool isGuest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsGuest, isGuest);
  }

  /// Clear login/guest status (for logout) but keep onboarding seen
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.setBool(_keyIsGuest, false);
    // Note: We keep onboarding_seen as true so onboarding doesn't show again
  }

  /// Clear all preferences (for complete reset)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

