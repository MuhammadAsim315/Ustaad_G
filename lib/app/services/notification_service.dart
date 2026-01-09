import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import 'firestore_service.dart';
import 'auth_service.dart';

/// Service for handling push notifications via Firebase Cloud Messaging
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static bool _initialized = false;

  /// Initialize notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Request permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('Notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted notification permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('User granted provisional notification permission');
      } else {
        debugPrint('User declined or has not accepted notification permission');
        return;
      }

      // Note: Local notifications can be added later if needed
      // For now, we'll rely on FCM for notifications

      // Get FCM token
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
        debugPrint('FCM Token: $token');
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _saveTokenToFirestore(newToken);
        debugPrint('FCM Token refreshed: $newToken');
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background message taps (when app is in background)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

      // Check if app was opened from a notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleBackgroundMessageTap(initialMessage);
      }

      _initialized = true;
      debugPrint('NotificationService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
    }
  }

  /// Save FCM token to Firestore
  static Future<void> _saveTokenToFirestore(String token) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) return;

      await FirestoreService.updateUserFCMToken(userId, token);
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  /// Handle foreground messages (when app is open)
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message received: ${message.messageId}');
    
    // Save notification to Firestore
    await _saveNotificationToFirestore(message);
    
    // Show snackbar or update UI
    Get.snackbar(
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  /// Handle notification tap when app is in background
  static void _handleBackgroundMessageTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    _navigateFromNotification(message);
  }


  /// Save notification to Firestore
  static Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) return;

      final notificationData = {
        'title': message.notification?.title ?? 'Notification',
        'body': message.notification?.body ?? '',
        'type': message.data['type'] ?? 'general',
        'bookingId': message.data['bookingId'],
        'workerId': message.data['workerId'],
        'customerId': message.data['customerId'],
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await FirestoreService.saveNotification(userId, notificationData);
    } catch (e) {
      debugPrint('Error saving notification to Firestore: $e');
    }
  }

  /// Navigate to appropriate screen based on notification data
  static void _navigateFromNotification(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] ?? 'general';

    switch (type) {
      case 'booking_request':
        // Navigate to worker bookings
        Get.toNamed('/worker-bookings');
        break;
      case 'booking_accepted':
      case 'booking_rejected':
      case 'booking_started':
      case 'booking_completed':
      case 'booking_cancelled':
        final bookingId = data['bookingId'];
        if (bookingId != null) {
          // Navigate to booking detail
          Get.toNamed('/booking-detail', arguments: {'bookingId': bookingId});
        } else {
          Get.toNamed('/my-bookings');
        }
        break;
      case 'chat_message':
        final workerId = data['workerId'];
        final workerName = data['workerName'] ?? 'Service Provider';
        if (workerId != null) {
          Get.toNamed('/chat', arguments: {
            'workerId': workerId,
            'workerName': workerName,
          });
        }
        break;
      default:
        Get.toNamed('/notifications');
    }
  }

  /// Send notification to a user (for client-side notifications)
  /// Note: For production, use Cloud Functions to send notifications
  static Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get user's FCM token
      final userData = await FirestoreService.getUserData(userId);
      final fcmToken = userData?['fcmToken'] as String?;

      if (fcmToken == null) {
        debugPrint('User $userId does not have an FCM token');
        return;
      }

      // In production, this should be done via Cloud Functions
      // For now, we'll just save the notification to Firestore
      final notificationData = {
        'title': title,
        'body': body,
        'type': type ?? 'general',
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
        ...?data,
      };

      await FirestoreService.saveNotification(userId, notificationData);
      debugPrint('Notification saved for user $userId');
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  /// Delete FCM token on logout
  static Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      final userId = AuthService.currentUserId;
      if (userId != null) {
        await FirestoreService.updateUserFCMToken(userId, null);
      }
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }
}

/// Top-level function for handling background messages
/// Must be top-level or static function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');
  // Handle background message if needed
}

