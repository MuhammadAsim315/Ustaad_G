import 'dart:ui' show PlatformDispatcher;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, FlutterError;

/// Service for Firebase Analytics and Crashlytics
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Initialize Crashlytics
  static Future<void> initialize() async {
    try {
      // Enable Crashlytics collection (disable in debug mode for development)
      await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
      
      // Set up Flutter error handler
      FlutterError.onError = (errorDetails) {
        _crashlytics.recordFlutterError(errorDetails);
      };
      
      // Set up platform error handler
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics.recordError(error, stack, fatal: true);
        return true;
      };
      
      debugPrint('AnalyticsService: Crashlytics initialized');
    } catch (e) {
      debugPrint('AnalyticsService: Error initializing Crashlytics: $e');
    }
  }

  /// Log a custom event
  static Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      debugPrint('AnalyticsService: Event logged - $name');
    } catch (e) {
      debugPrint('AnalyticsService: Error logging event: $e');
    }
  }

  /// Set user properties
  static Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      debugPrint('AnalyticsService: User property set - $name: $value');
    } catch (e) {
      debugPrint('AnalyticsService: Error setting user property: $e');
    }
  }

  /// Set user ID
  static Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
      await _crashlytics.setUserIdentifier(userId ?? 'anonymous');
      debugPrint('AnalyticsService: User ID set - $userId');
    } catch (e) {
      debugPrint('AnalyticsService: Error setting user ID: $e');
    }
  }

  /// Log signup event
  static Future<void> logSignUp({
    required String method,
    String? userId,
  }) async {
    await logEvent(
      name: 'sign_up',
      parameters: <String, Object>{
        'method': method,
        if (userId != null) 'user_id': userId,
      },
    );
  }

  /// Log login event
  static Future<void> logLogin({
    required String method,
    String? userId,
  }) async {
    await logEvent(
      name: 'login',
      parameters: <String, Object>{
        'method': method,
        if (userId != null) 'user_id': userId,
      },
    );
  }

  /// Log booking created event
  static Future<void> logBookingCreated({
    required String bookingId,
    required String serviceName,
    required double amount,
    String? workerId,
  }) async {
    await logEvent(
      name: 'booking_created',
      parameters: <String, Object>{
        'booking_id': bookingId,
        'service_name': serviceName,
        'amount': amount,
        'currency': 'PKR',
        if (workerId != null && workerId.isNotEmpty) 'worker_id': workerId,
      },
    );
  }

  /// Log booking status change event
  static Future<void> logBookingStatusChange({
    required String bookingId,
    required String oldStatus,
    required String newStatus,
    String? userId,
  }) async {
    await logEvent(
      name: 'booking_status_changed',
      parameters: <String, Object>{
        'booking_id': bookingId,
        'old_status': oldStatus,
        'new_status': newStatus,
        if (userId != null) 'user_id': userId,
      },
    );
  }

  /// Log booking completed event
  static Future<void> logBookingCompleted({
    required String bookingId,
    required String serviceName,
    required double amount,
  }) async {
    await logEvent(
      name: 'booking_completed',
      parameters: <String, Object>{
        'booking_id': bookingId,
        'service_name': serviceName,
        'amount': amount,
        'currency': 'PKR',
      },
    );
  }

  /// Log worker registration event
  static Future<void> logWorkerRegistration({
    required String userId,
    required List<String> services,
    String? location,
  }) async {
    await logEvent(
      name: 'worker_registered',
      parameters: <String, Object>{
        'user_id': userId,
        'services_count': services.length,
        'services': services.join(', '),
        if (location != null) 'location': location,
      },
    );
  }

  /// Log service viewed event
  static Future<void> logServiceViewed({
    required String serviceName,
  }) async {
    await logEvent(
      name: 'view_item',
      parameters: {
        'item_id': serviceName,
        'item_name': serviceName,
        'item_category': 'service',
      },
    );
  }

  /// Log worker profile viewed event
  static Future<void> logWorkerProfileViewed({
    required String workerId,
    required String workerName,
  }) async {
    await logEvent(
      name: 'view_item',
      parameters: <String, Object>{
        'item_id': workerId,
        'item_name': workerName,
        'item_category': 'worker',
      },
    );
  }

  /// Log review submitted event
  static Future<void> logReviewSubmitted({
    required String workerId,
    required int rating,
    required String bookingId,
  }) async {
    await logEvent(
      name: 'review_submitted',
      parameters: <String, Object>{
        'worker_id': workerId,
        'rating': rating,
        'booking_id': bookingId,
      },
    );
  }

  /// Log chat message sent event
  static Future<void> logChatMessageSent({
    required String chatId,
    required String recipientId,
  }) async {
    await logEvent(
      name: 'chat_message_sent',
      parameters: <String, Object>{
        'chat_id': chatId,
        'recipient_id': recipientId,
      },
    );
  }

  /// Log screen view
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      debugPrint('AnalyticsService: Screen viewed - $screenName');
    } catch (e) {
      debugPrint('AnalyticsService: Error logging screen view: $e');
    }
  }

  /// Log custom error to Crashlytics
  static Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
      debugPrint('AnalyticsService: Error logged to Crashlytics');
    } catch (e) {
      debugPrint('AnalyticsService: Error logging to Crashlytics: $e');
    }
  }

  /// Log custom message to Crashlytics
  static Future<void> logMessage(String message) async {
    try {
      await _crashlytics.log(message);
      debugPrint('AnalyticsService: Message logged - $message');
    } catch (e) {
      debugPrint('AnalyticsService: Error logging message: $e');
    }
  }

  /// Set user role for analytics
  static Future<void> setUserRole(String role) async {
    await setUserProperty(name: 'user_role', value: role);
  }

  /// Clear user data (on logout)
  static Future<void> clearUserData() async {
    try {
      await _analytics.setUserId(id: null);
      await _crashlytics.setUserIdentifier('anonymous');
      debugPrint('AnalyticsService: User data cleared');
    } catch (e) {
      debugPrint('AnalyticsService: Error clearing user data: $e');
    }
  }
}

