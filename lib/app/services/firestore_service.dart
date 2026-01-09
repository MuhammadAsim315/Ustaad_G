import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'notification_service.dart';
import 'analytics_service.dart';
import '../models/worker_filter_options.dart';

/// Service class for Firestore database operations
class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection names
  static const String _usersCollection = 'users';
  static const String _historyCollection = 'history';
  static const String _iconsCollection = 'icons';
  static const String _bookingsCollection = 'bookings';
  static const String _reviewsCollection = 'reviews';
  static const String _faqsCollection = 'faqs';
  static const String _reportsCollection = 'reports';
  static const String _notificationsCollection = 'notifications';
  static const String _cashoutsCollection = 'cashouts';

  /// Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  /// ==================== USER DATA ====================
  
  /// Save or update user data
  static Future<void> saveUserData({
    required String userId,
    required String name,
    required String email,
    String? phone,
    String? profileImageUrl,
    String? role, // 'customer' | 'worker' | 'admin'
  }) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).set({
        'name': name,
        'email': email,
        'phone': phone ?? '',
        'profileImageUrl': profileImageUrl ?? '',
        'role': role ?? 'customer', // Default to customer if not specified
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  /// Get user data
  static Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  /// Update user profile
  static Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? profileImageUrl,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;

      await _firestore.collection(_usersCollection).doc(userId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Update user role (admin only)
  static Future<void> updateUserRole(String userId, String role) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  /// Update user status (ban/unban)
  static Future<void> updateUserStatus(String userId, bool isBanned, {String? reason}) async {
    try {
      final updateData = <String, dynamic>{
        'isBanned': isBanned,
        'bannedAt': isBanned ? FieldValue.serverTimestamp() : null,
        'banReason': reason ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await _firestore.collection(_usersCollection).doc(userId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }

  /// Update user with worker-specific data (for onboarding)
  static Future<void> updateUserWorkerData(String userId, Map<String, dynamic> workerData) async {
    try {
      debugPrint('FirestoreService: Updating worker data for user: $userId');
      debugPrint('FirestoreService: Worker data to save: $workerData');
      
      final updateData = <String, dynamic>{
        ...workerData,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      debugPrint('FirestoreService: Final update data (including updatedAt): $updateData');
      
      // Use set with merge to handle cases where document might not exist or have missing fields
      await _firestore.collection(_usersCollection).doc(userId).set(updateData, SetOptions(merge: true));
      
      debugPrint('FirestoreService: Worker data saved successfully');
      debugPrint('FirestoreService: Role being set to: ${workerData['role']}');
      
      // Note: We don't verify by reading back immediately because:
      // 1. The write operation succeeded (no exception thrown)
      // 2. Reading immediately after write might fail due to Firestore propagation delays
      // 3. Reading requires read permissions which might be different from write permissions
      // The role verification will happen in the controller after a delay
    } catch (e, stackTrace) {
      debugPrint('FirestoreService: Error updating worker data: $e');
      debugPrint('FirestoreService: Stack trace: $stackTrace');
      throw Exception('Failed to update worker data: $e');
    }
  }

  /// Get all users (admin only)
  static Stream<QuerySnapshot> getAllUsers() {
    return _firestore
        .collection(_usersCollection)
        .orderBy('createdAt', descending: true)
        .limit(100) // Add limit to prevent large queries
        .snapshots();
  }

  /// Get users by role
  /// Requires composite index: users: role (Ascending), createdAt (Descending)
  static Stream<QuerySnapshot> getUsersByRole(String role) {
    return _firestore
        .collection(_usersCollection)
        .where('role', isEqualTo: role)
        .orderBy('createdAt', descending: true)
        .limit(100) // Add limit to prevent large queries
        .snapshots();
  }

  /// Get all bookings (admin only)
  static Stream<QuerySnapshot> getAllBookings() {
    return _firestore
        .collection(_bookingsCollection)
        .orderBy('createdAt', descending: true)
        .limit(100) // Add limit to prevent large queries
        .snapshots();
  }

  /// Get bookings by status (admin)
  /// Requires composite index: bookings: status (Ascending), createdAt (Descending)
  static Stream<QuerySnapshot> getBookingsByStatus(String status) {
    return _firestore
        .collection(_bookingsCollection)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .limit(100) // Add limit to prevent large queries
        .snapshots();
  }

  /// Get all reports (admin only)
  static Stream<QuerySnapshot> getAllReports() {
    return _firestore
        .collection(_reportsCollection)
        .orderBy('createdAt', descending: true)
        .limit(100) // Add limit to prevent large queries
        .snapshots();
  }

  /// Get reports by status
  /// Requires composite index: reports: status (Ascending), createdAt (Descending)
  static Stream<QuerySnapshot> getReportsByStatus(String status) {
    return _firestore
        .collection(_reportsCollection)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .limit(100) // Add limit to prevent large queries
        .snapshots();
  }

  /// Update report status (admin only)
  static Future<void> updateReportStatus(String reportId, String status, {String? adminNotes}) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (adminNotes != null) {
        updateData['adminNotes'] = adminNotes;
      }
      
      if (status == 'resolved' || status == 'dismissed') {
        updateData['resolvedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore.collection(_reportsCollection).doc(reportId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update report status: $e');
    }
  }

  /// Delete booking (admin only)
  static Future<void> deleteBookingAdmin(String bookingId) async {
    try {
      await _firestore.collection(_bookingsCollection).doc(bookingId).delete();
    } catch (e) {
      throw Exception('Failed to delete booking: $e');
    }
  }

  /// Get dashboard statistics
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Get counts
      final usersSnapshot = await _firestore.collection(_usersCollection).get();
      final bookingsSnapshot = await _firestore.collection(_bookingsCollection).get();
      final reportsSnapshot = await _firestore.collection(_reportsCollection).get();
      final reviewsSnapshot = await _firestore.collection(_reviewsCollection).get();

      // Count by role
      int customers = 0;
      int workers = 0;
      int admins = 0;
      int banned = 0;

      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        final role = data['role'] as String? ?? 'customer';
        final isBanned = data['isBanned'] as bool? ?? false;

        if (isBanned) banned++;
        if (role == 'customer') customers++;
        if (role == 'worker') workers++;
        if (role == 'admin') admins++;
      }

      // Count bookings by status
      int pendingBookings = 0;
      int activeBookings = 0;
      int completedBookings = 0;
      double totalRevenue = 0.0;

      for (var doc in bookingsSnapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String? ?? 'pending';
        final amount = (data['amount'] as num? ?? 0).toDouble();

        if (status == 'pending') pendingBookings++;
        if (status == 'accepted' || status == 'in_progress') activeBookings++;
        if (status == 'completed') {
          completedBookings++;
          totalRevenue += amount;
        }
      }

      // Count reports by status
      int pendingReports = 0;
      int resolvedReports = 0;

      for (var doc in reportsSnapshot.docs) {
        final status = doc.data()['status'] as String? ?? 'pending';
        if (status == 'pending') pendingReports++;
        if (status == 'resolved' || status == 'dismissed') resolvedReports++;
      }

      return {
        'totalUsers': usersSnapshot.docs.length,
        'customers': customers,
        'workers': workers,
        'admins': admins,
        'bannedUsers': banned,
        'totalBookings': bookingsSnapshot.docs.length,
        'pendingBookings': pendingBookings,
        'activeBookings': activeBookings,
        'completedBookings': completedBookings,
        'totalRevenue': totalRevenue,
        'totalReports': reportsSnapshot.docs.length,
        'pendingReports': pendingReports,
        'resolvedReports': resolvedReports,
        'totalReviews': reviewsSnapshot.docs.length,
      };
    } catch (e) {
      debugPrint('Error getting dashboard stats: $e');
      rethrow;
    }
  }

  /// ==================== HISTORY ====================
  
  /// Save booking/service history
  static Future<void> saveHistory({
    required String userId,
    required String serviceName,
    required String serviceSvgPath,
    required int serviceColorValue,
    required String providerName,
    required DateTime date,
    required String time,
    required String address,
    required double amount,
    required String status,
  }) async {
    try {
      await _firestore.collection(_historyCollection).add({
        'userId': userId,
        'serviceName': serviceName,
        'serviceSvgPath': serviceSvgPath,
        'serviceColor': serviceColorValue.toString(),
        'providerName': providerName,
        'date': Timestamp.fromDate(date),
        'time': time,
        'address': address,
        'amount': amount,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save history: $e');
    }
  }

  /// Get user history
  /// Requires composite index: history: userId (Ascending), createdAt (Descending)
  static Stream<QuerySnapshot> getUserHistory(String userId) {
    return _firestore
        .collection(_historyCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50) // Add limit for pagination
        .snapshots();
  }

  /// Get user history by status
  /// Requires composite index: history: userId (Ascending), status (Ascending), createdAt (Descending)
  static Stream<QuerySnapshot> getUserHistoryByStatus(String userId, String status) {
    return _firestore
        .collection(_historyCollection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .limit(50) // Add limit for pagination
        .snapshots();
  }

  /// ==================== ICONS ====================
  
  /// Save icon configuration
  static Future<void> saveIconConfig({
    required String categoryName,
    required String svgPath,
    required String colorHex,
  }) async {
    try {
      await _firestore.collection(_iconsCollection).doc(categoryName.toLowerCase()).set({
        'categoryName': categoryName,
        'svgPath': svgPath,
        'colorHex': colorHex,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save icon config: $e');
    }
  }

  /// Get icon configuration
  static Future<Map<String, dynamic>?> getIconConfig(String categoryName) async {
    try {
      final doc = await _firestore.collection(_iconsCollection).doc(categoryName.toLowerCase()).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get icon config: $e');
    }
  }

  /// Get all icon configurations
  static Future<List<Map<String, dynamic>>> getAllIconConfigs() async {
    try {
      final snapshot = await _firestore.collection(_iconsCollection).get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get icon configs: $e');
    }
  }

  /// ==================== BOOKINGS ====================
  
  /// Save booking
  static Future<String> saveBooking({
    required String userId,
    required String serviceName,
    required String serviceSvgPath,
    required int serviceColorValue,
    required String providerName,
    required DateTime date,
    required String time,
    required String address,
    required double amount,
    required String status,
    String? workerId, // Worker ID (if booking is for a specific worker)
  }) async {
    try {
      final docRef = await _firestore.collection(_bookingsCollection).add({
        'customerId': userId, // Renamed from userId for clarity
        'workerId': workerId ?? '', // Worker ID (empty if not assigned yet)
        'serviceName': serviceName,
        'serviceSvgPath': serviceSvgPath,
        'serviceColor': serviceColorValue.toString(),
        'providerName': providerName, // Keep for backward compatibility
        'date': Timestamp.fromDate(date),
        'time': time,
        'address': address,
        'amount': amount,
        'status': status, // 'pending' | 'accepted' | 'rejected' | 'in_progress' | 'completed' | 'cancelled'
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Send notification to worker if booking is for a specific worker
      if (workerId != null && workerId.isNotEmpty) {
        await _sendBookingRequestNotification(workerId, docRef.id, serviceName, amount);
      }
      
      // Track booking created event
      await AnalyticsService.logBookingCreated(
        bookingId: docRef.id,
        serviceName: serviceName,
        amount: amount,
        workerId: workerId,
      );
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save booking: $e');
    }
  }

  /// Get user bookings (customer bookings)
  /// Requires composite index: bookings: customerId (Ascending), createdAt (Descending)
  static Stream<QuerySnapshot> getUserBookings(String userId) {
    return _firestore
        .collection(_bookingsCollection)
        .where('customerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50) // Add limit for pagination
        .snapshots();
  }

  /// Get user bookings by status (customer bookings)
  /// Requires composite index: bookings: customerId (Ascending), status (Ascending), createdAt (Descending)
  static Stream<QuerySnapshot> getUserBookingsByStatus(String userId, String status) {
    return _firestore
        .collection(_bookingsCollection)
        .where('customerId', isEqualTo: userId)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .limit(50) // Add limit for pagination
        .snapshots();
  }

  /// Get worker bookings (bookings assigned to a worker)
  /// Requires composite index: bookings: workerId (Ascending), createdAt (Descending)
  static Stream<QuerySnapshot> getWorkerBookings(String workerId) {
    debugPrint('FirestoreService: getWorkerBookings called with workerId: $workerId');
    try {
      final query = _firestore
          .collection(_bookingsCollection)
          .where('workerId', isEqualTo: workerId)
          .orderBy('createdAt', descending: true)
          .limit(50); // Add limit for pagination
      
      debugPrint('FirestoreService: Query created successfully');
      return query.snapshots();
    } catch (e) {
      debugPrint('FirestoreService: Error creating query: $e');
      rethrow;
    }
  }

  /// Get worker bookings by status
  /// Requires composite index: bookings: workerId (Ascending), status (Ascending), createdAt (Descending)
  static Stream<QuerySnapshot> getWorkerBookingsByStatus(String workerId, String status) {
    return _firestore
        .collection(_bookingsCollection)
        .where('workerId', isEqualTo: workerId)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .limit(50) // Add limit for pagination
        .snapshots();
  }

  /// Update booking status with permission checks
  static Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get booking data to check permissions
      final bookingDoc = await _firestore.collection(_bookingsCollection).doc(bookingId).get();
      if (!bookingDoc.exists) {
        throw Exception('Booking not found');
      }

      final bookingData = bookingDoc.data()!;
      final currentStatus = bookingData['status'] as String? ?? 'pending';
      final customerId = bookingData['customerId'] as String? ?? '';
      final workerId = bookingData['workerId'] as String? ?? '';

      // Get user role
      final userData = await getUserData(userId);
      final userRole = userData?['role'] as String? ?? 'customer';

      // Validate status transition and permissions
      final validTransitions = {
        'pending': ['accepted', 'rejected', 'cancelled'],
        'accepted': ['in_progress', 'cancelled'],
        'in_progress': ['completed', 'cancelled'],
        'rejected': [], // Cannot transition from rejected
        'completed': [], // Cannot transition from completed
        'cancelled': [], // Cannot transition from cancelled
      };

      final allowedTransitions = validTransitions[currentStatus] ?? [];
      if (!allowedTransitions.contains(status)) {
        throw Exception('Invalid status transition from $currentStatus to $status');
      }

      // Permission checks
      if (status == 'accepted' || status == 'rejected') {
        // Only worker can accept/reject
        if (userRole != 'admin' && (workerId != userId || workerId.isEmpty)) {
          throw Exception('Only the assigned worker can accept or reject bookings');
        }
      } else if (status == 'in_progress' || status == 'completed') {
        // Only worker can mark as in_progress or completed
        if (userRole != 'admin' && (workerId != userId || workerId.isEmpty)) {
          throw Exception('Only the assigned worker can update booking to $status');
        }
      } else if (status == 'cancelled') {
        // Customer or worker can cancel
        if (userRole != 'admin' && customerId != userId && workerId != userId) {
          throw Exception('Only customer or worker can cancel bookings');
        }
        // Customer can only cancel before in_progress
        if (userRole == 'customer' && currentStatus == 'in_progress') {
          throw Exception('Cannot cancel booking that is already in progress');
        }
      }

      // Track booking status change
      await AnalyticsService.logBookingStatusChange(
        bookingId: bookingId,
        oldStatus: currentStatus,
        newStatus: status,
        userId: userId,
      );
      
      // Track booking completed event
      if (status == 'completed') {
        final serviceName = bookingData['serviceName'] as String? ?? '';
        final amount = (bookingData['amount'] as num?)?.toDouble() ?? 0.0;
        await AnalyticsService.logBookingCompleted(
          bookingId: bookingId,
          serviceName: serviceName,
          amount: amount,
        );
      }

      // Prepare update data
      final updateData = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add timestamps based on status
      if (status == 'accepted') {
        updateData['workerAcceptedAt'] = FieldValue.serverTimestamp();
      } else if (status == 'cancelled') {
        if (customerId == userId) {
          updateData['customerCancelledAt'] = FieldValue.serverTimestamp();
        } else if (workerId == userId) {
          updateData['workerCancelledAt'] = FieldValue.serverTimestamp();
        }
      } else if (status == 'completed') {
        updateData['completedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore.collection(_bookingsCollection).doc(bookingId).update(updateData);

      // Send notification about status change
      await _sendBookingStatusNotification(
        bookingId: bookingId,
        status: status,
        customerId: customerId,
        workerId: workerId,
        bookingData: bookingData,
      );
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  /// Send notification when a new booking request is created
  static Future<void> _sendBookingRequestNotification(
    String workerId,
    String bookingId,
    String serviceName,
    double amount,
  ) async {
    try {
      final customerData = await getUserData(currentUserId ?? '');
      final customerName = customerData?['name'] ?? 'A customer';
      
      await NotificationService.sendNotificationToUser(
        userId: workerId,
        title: 'New Booking Request',
        body: '$customerName requested $serviceName for PKR ${amount.toStringAsFixed(0)}',
        type: 'booking_request',
        data: {
          'bookingId': bookingId,
          'customerId': currentUserId ?? '',
          'customerName': customerName,
        },
      );
    } catch (e) {
      debugPrint('Error sending booking request notification: $e');
    }
  }

  /// Send notification when booking status changes
  static Future<void> _sendBookingStatusNotification({
    required String bookingId,
    required String status,
    required String customerId,
    required String workerId,
    required Map<String, dynamic> bookingData,
  }) async {
    try {
      final serviceName = bookingData['serviceName'] ?? 'service';
      
      String title;
      String body;
      String notificationType;
      String recipientId;
      
      switch (status) {
        case 'accepted':
          title = 'Booking Accepted';
          body = 'Your $serviceName booking has been accepted';
          notificationType = 'booking_accepted';
          recipientId = customerId;
          break;
        case 'rejected':
          title = 'Booking Rejected';
          body = 'Your $serviceName booking has been rejected';
          notificationType = 'booking_rejected';
          recipientId = customerId;
          break;
        case 'in_progress':
          title = 'Service Started';
          body = 'Your $serviceName service has started';
          notificationType = 'booking_started';
          recipientId = customerId;
          break;
        case 'completed':
          title = 'Service Completed';
          body = 'Your $serviceName service has been completed';
          notificationType = 'booking_completed';
          recipientId = customerId;
          break;
        case 'cancelled':
          final cancelledBy = currentUserId;
          if (cancelledBy == customerId) {
            // Customer cancelled - notify worker
            title = 'Booking Cancelled';
            body = 'A customer cancelled their $serviceName booking';
            notificationType = 'booking_cancelled';
            recipientId = workerId;
          } else {
            // Worker cancelled - notify customer
            title = 'Booking Cancelled';
            body = 'Your $serviceName booking has been cancelled';
            notificationType = 'booking_cancelled';
            recipientId = customerId;
          }
          break;
        default:
          return; // No notification for other statuses
      }
      
      if (recipientId.isNotEmpty) {
        await NotificationService.sendNotificationToUser(
          userId: recipientId,
          title: title,
          body: body,
          type: notificationType,
          data: {
            'bookingId': bookingId,
            'customerId': customerId,
            'workerId': workerId,
          },
        );
      }
    } catch (e) {
      debugPrint('Error sending booking status notification: $e');
    }
  }

  /// Accept a booking (worker only)
  static Future<void> acceptBooking(String bookingId) async {
    await updateBookingStatus(bookingId, 'accepted');
  }

  /// Reject a booking (worker only)
  static Future<void> rejectBooking(String bookingId) async {
    await updateBookingStatus(bookingId, 'rejected');
  }

  /// Start a booking (worker only)
  static Future<void> startBooking(String bookingId) async {
    await updateBookingStatus(bookingId, 'in_progress');
  }

  /// Complete a booking (worker only)
  static Future<void> completeBooking(String bookingId) async {
    await updateBookingStatus(bookingId, 'completed');
  }

  /// Cancel a booking (customer or worker)
  static Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(bookingId, 'cancelled');
  }

  /// Delete booking
  static Future<void> deleteBooking(String bookingId) async {
    try {
      await _firestore.collection(_bookingsCollection).doc(bookingId).delete();
    } catch (e) {
      throw Exception('Failed to delete booking: $e');
    }
  }

  /// ==================== REVIEWS ====================
  
  /// Save review
  static Future<String> saveReview({
    required String workerId,
    required String reviewerId,
    required String reviewerName,
    required int rating,
    String? review,
    String? bookingId,
  }) async {
    try {
      final docRef = await _firestore.collection(_reviewsCollection).add({
        'workerId': workerId,
        'reviewerId': reviewerId,
        'reviewerName': reviewerName,
        'rating': rating,
        'review': review ?? '',
        'bookingId': bookingId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Track review submission
      await AnalyticsService.logReviewSubmitted(
        workerId: workerId,
        rating: rating,
        bookingId: bookingId ?? '',
      );
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save review: $e');
    }
  }

  /// Get reviews for a worker
  static Stream<QuerySnapshot> getWorkerReviews(String workerId) {
    return _firestore
        .collection(_reviewsCollection)
        .where('workerId', isEqualTo: workerId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get reviews for a worker (one-time)
  static Future<List<Map<String, dynamic>>> getWorkerReviewsOnce(String workerId) async {
    try {
      final snapshot = await _firestore
          .collection(_reviewsCollection)
          .where('workerId', isEqualTo: workerId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      throw Exception('Failed to get reviews: $e');
    }
  }

  /// ==================== WORKERS ====================
  
  /// Get workers by service category (backward compatible)
  static Future<List<Map<String, dynamic>>> getWorkersByService(String serviceName) async {
    return getWorkersByServiceWithFilters(serviceName);
  }
  
  /// Get workers by service category with enhanced filtering
  static Future<List<Map<String, dynamic>>> getWorkersByServiceWithFilters(
    String serviceName, {
    WorkerFilterOptions? filters,
  }) async {
    try {
      // Start with base query
      // Note: This query requires composite indexes:
      // - users: role (Ascending), servicesOffered (Arrays), workerStatus (Ascending)
      // - users: role (Ascending), servicesOffered (Arrays), workerStatus (Ascending), serviceArea (Ascending)
      Query query = _firestore
          .collection(_usersCollection)
          .where('role', isEqualTo: 'worker')
          .where('servicesOffered', arrayContains: serviceName)
          .where('workerStatus', isEqualTo: 'active'); // Only active workers
      
      // Apply location filter if provided
      // Note: Adding location requires a composite index with all previous where clauses
      if (filters?.location != null && filters!.location!.isNotEmpty) {
        query = query.where('serviceArea', isEqualTo: filters.location);
      }
      
      // Apply pagination
      if (filters?.startAfter != null) {
        query = query.startAfterDocument(filters!.startAfter!);
      }
      
      if (filters?.limit != null) {
        query = query.limit(filters!.limit!);
      } else {
        // Default limit to prevent large queries
        query = query.limit(50);
      }
      
      // Execute query
      final snapshot = await query.get();
      
      // Map to worker data
      List<Map<String, dynamic>> workers = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        final result = <String, dynamic>{
          'id': doc.id,
          '_documentSnapshot': doc, // Store for pagination
        };
        if (data != null) {
          result.addAll(data);
        }
        return result;
      }).toList();
      
      // Apply in-memory filters (for fields that can't be queried directly)
      if (filters != null) {
        // Filter by price (check servicePricing map)
        if (filters.maxPrice != null) {
          workers = workers.where((worker) {
            final pricing = worker['servicePricing'] as Map<String, dynamic>?;
            if (pricing == null) return false;
            final price = pricing[serviceName];
            if (price == null) return false;
            return (price as num).toDouble() <= filters.maxPrice!;
          }).toList();
        }
        
        // Filter by minimum rating (will be calculated later, but we can filter after)
        // This will be handled after rating calculation
        
        // Filter by availability (check if worker is available now)
        if (filters.availableNow == true) {
          workers = _filterByAvailability(workers);
        }
      }
      
      // Batch fetch all reviews for all workers (optimize N+1 query problem)
      final workerIds = workers.map((w) => w['id'] as String).where((id) => id.isNotEmpty).toList();
      final ratingsMap = await _batchCalculateRatings(workerIds);
      
      // Apply ratings to workers
      for (var worker in workers) {
        final workerId = worker['id'] as String? ?? '';
        if (workerId.isNotEmpty && ratingsMap.containsKey(workerId)) {
          final ratingData = ratingsMap[workerId]!;
          worker['averageRating'] = ratingData['averageRating'];
          worker['totalReviews'] = ratingData['totalReviews'];
        } else {
          worker['averageRating'] = 0.0;
          worker['totalReviews'] = 0;
        }
      }
      
      // Apply minimum rating filter after calculation
      if (filters?.minRating != null) {
        workers = workers.where((worker) {
          final rating = worker['averageRating'] as double? ?? 0.0;
          return rating >= filters!.minRating!;
        }).toList();
      }
      
      // Apply sorting
      if (filters?.sortBy != null) {
        workers = _sortWorkers(workers, filters!.sortBy!, filters.sortAscending, serviceName);
      } else {
        // Default sort by rating (descending)
        workers = _sortWorkers(workers, 'rating', false, serviceName);
      }
      
      return workers;
    } catch (e, stackTrace) {
      debugPrint('Error getting workers by service: $e');
      debugPrint('Stack trace: $stackTrace');
      // If the query fails (e.g., no index), return empty list
      return [];
    }
  }
  
  /// Batch calculate ratings for multiple workers (optimizes N+1 query problem)
  static Future<Map<String, Map<String, dynamic>>> _batchCalculateRatings(List<String> workerIds) async {
    if (workerIds.isEmpty) return {};
    
    final ratingsMap = <String, Map<String, dynamic>>{};
    
    try {
      // Initialize all workers with default ratings
      for (final workerId in workerIds) {
        ratingsMap[workerId] = {
          'averageRating': 0.0,
          'totalReviews': 0,
        };
      }
      
      // Fetch all reviews for all workers in batches (Firestore 'in' query limit is 10)
      final batches = <List<String>>[];
      for (int i = 0; i < workerIds.length; i += 10) {
        batches.add(workerIds.sublist(i, i + 10 > workerIds.length ? workerIds.length : i + 10));
      }
      
      // Process each batch
      for (final batch in batches) {
        try {
          // Query reviews for this batch of workers
          final reviewsSnapshot = await _firestore
              .collection(_reviewsCollection)
              .where('workerId', whereIn: batch)
              .get();
          
          // Group reviews by workerId
          final reviewsByWorker = <String, List<Map<String, dynamic>>>{};
          for (final doc in reviewsSnapshot.docs) {
            final reviewData = doc.data();
            final workerId = reviewData['workerId'] as String?;
            if (workerId != null && batch.contains(workerId)) {
              reviewsByWorker.putIfAbsent(workerId, () => []).add({
                'id': doc.id,
                ...reviewData,
              });
            }
          }
          
          // Calculate ratings for each worker in this batch
          for (final workerId in batch) {
            final reviews = reviewsByWorker[workerId] ?? [];
            if (reviews.isNotEmpty) {
              final ratings = reviews
                  .where((review) => review['rating'] != null)
                  .map((review) => (review['rating'] as num).toDouble())
                  .toList();
              
              if (ratings.isNotEmpty) {
                final totalRating = ratings.fold(0.0, (total, rating) => total + rating);
                ratingsMap[workerId] = {
                  'averageRating': totalRating / ratings.length,
                  'totalReviews': reviews.length,
                };
              }
            }
          }
        } catch (e) {
          debugPrint('Error batch fetching reviews: $e');
          // Continue with other batches even if one fails
        }
      }
    } catch (e) {
      debugPrint('Error in batch rating calculation: $e');
    }
    
    return ratingsMap;
  }
  
  /// Filter workers by current availability
  static List<Map<String, dynamic>> _filterByAvailability(List<Map<String, dynamic>> workers) {
    final now = DateTime.now();
    final currentDay = _getDayName(now.weekday);
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    return workers.where((worker) {
      final availability = worker['availability'] as Map<String, dynamic>?;
      if (availability == null) return false;
      
      final days = availability['days'] as List<dynamic>?;
      if (days == null || !days.contains(currentDay)) return false;
      
      final startTime = availability['startTime'] as String?;
      final endTime = availability['endTime'] as String?;
      
      if (startTime == null || endTime == null) return false;
      
      // Check if current time is within working hours
      return _isTimeInRange(currentTime, startTime, endTime);
    }).toList();
  }
  
  /// Get day name from weekday number (1=Monday, 7=Sunday)
  static String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }
  
  /// Check if time is within range (HH:mm format)
  static bool _isTimeInRange(String time, String startTime, String endTime) {
    try {
      final timeParts = time.split(':');
      final startParts = startTime.split(':');
      final endParts = endTime.split(':');
      
      final timeMinutes = int.parse(timeParts[0]) * 60 + int.parse(timeParts[1]);
      final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
      
      return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
    } catch (e) {
      return false;
    }
  }
  
  /// Sort workers by specified criteria
  static List<Map<String, dynamic>> _sortWorkers(
    List<Map<String, dynamic>> workers,
    String sortBy,
    bool ascending,
    String serviceName,
  ) {
    workers.sort((a, b) {
      int comparison = 0;
      
      switch (sortBy) {
        case 'rating':
          final ratingA = (a['averageRating'] as double? ?? 0.0);
          final ratingB = (b['averageRating'] as double? ?? 0.0);
          comparison = ratingA.compareTo(ratingB);
          break;
          
        case 'price':
          final pricingA = a['servicePricing'] as Map<String, dynamic>?;
          final pricingB = b['servicePricing'] as Map<String, dynamic>?;
          final priceA = pricingA?[serviceName] as num? ?? 0.0;
          final priceB = pricingB?[serviceName] as num? ?? 0.0;
          comparison = priceA.compareTo(priceB);
          break;
          
        case 'reviews':
          final reviewsA = (a['totalReviews'] as int? ?? 0);
          final reviewsB = (b['totalReviews'] as int? ?? 0);
          comparison = reviewsA.compareTo(reviewsB);
          break;
          
        case 'experience':
          final expA = (a['yearsOfExperience'] as int? ?? 0);
          final expB = (b['yearsOfExperience'] as int? ?? 0);
          comparison = expA.compareTo(expB);
          break;
          
        default:
          comparison = 0;
      }
      
      return ascending ? comparison : -comparison;
    });
    
    return workers;
  }

  /// ==================== FAQs ====================
  
  /// Get FAQs for a worker
  static Future<List<Map<String, dynamic>>> getWorkerFAQs(String workerId) async {
    try {
      final snapshot = await _firestore
          .collection(_faqsCollection)
          .where('workerId', isEqualTo: workerId)
          .orderBy('order', descending: false)
          .get();
      
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      debugPrint('Error getting worker FAQs: $e');
      return [];
    }
  }

  /// Save FAQ for a worker
  static Future<String> saveFAQ({
    required String workerId,
    required String question,
    required String answer,
    int? order,
  }) async {
    try {
      final docRef = await _firestore.collection(_faqsCollection).add({
        'workerId': workerId,
        'question': question,
        'answer': answer,
        'order': order ?? 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save FAQ: $e');
    }
  }

  /// ==================== REPORTS ====================
  
  /// Save a report
  static Future<String> saveReport({
    required String reportedUserId,
    required String reporterId,
    required String reportType,
    required String description,
    String? bookingId,
  }) async {
    try {
      final docRef = await _firestore.collection(_reportsCollection).add({
        'reportedUserId': reportedUserId,
        'reporterId': reporterId,
        'reportType': reportType,
        'description': description,
        'bookingId': bookingId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save report: $e');
    }
  }

  /// ==================== NOTIFICATIONS ====================
  
  /// Save notification to Firestore
  static Future<String> saveNotification(String userId, Map<String, dynamic> notificationData) async {
    try {
      final docRef = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_notificationsCollection)
          .add({
        ...notificationData,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save notification: $e');
    }
  }

  /// Get user notifications
  static Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_notificationsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Mark notification as read
  static Future<void> markNotificationAsRead(String userId, String notificationId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_notificationsCollection)
          .doc(notificationId)
          .update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read
  static Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_notificationsCollection)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  /// Delete notification
  static Future<void> deleteNotification(String userId, String notificationId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_notificationsCollection)
          .doc(notificationId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  /// Get unread notifications count
  static Future<int> getUnreadNotificationsCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_notificationsCollection)
          .where('isRead', isEqualTo: false)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting unread notifications count: $e');
      return 0;
    }
  }

  /// Update user FCM token
  static Future<void> updateUserFCMToken(String userId, String? token) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update FCM token: $e');
    }
  }

  /// Get booking by ID
  static Future<Map<String, dynamic>?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore.collection(_bookingsCollection).doc(bookingId).get();
      if (!doc.exists) return null;
      return {
        'id': doc.id,
        ...doc.data()!,
      };
    } catch (e) {
      debugPrint('Error getting booking: $e');
      return null;
    }
  }

  /// ==================== CASHOUTS ====================

  /// Request cashout
  static Future<String> requestCashout({
    required String workerId,
    required double amount,
    required String accountNumber,
    required String accountName,
  }) async {
    try {
      final docRef = await _firestore.collection(_cashoutsCollection).add({
        'workerId': workerId,
        'amount': amount,
        'accountNumber': accountNumber,
        'accountName': accountName,
        'status': 'pending', // pending, approved, completed, rejected
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to request cashout: $e');
    }
  }

  /// Get worker cashouts
  /// Requires composite index: cashouts: workerId (Ascending), createdAt (Descending)
  static Stream<QuerySnapshot> getWorkerCashouts(String workerId) {
    return _firestore
        .collection(_cashoutsCollection)
        .where('workerId', isEqualTo: workerId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  /// Get worker cashouts by status
  /// Requires composite index: cashouts: workerId (Ascending), status (Ascending), createdAt (Descending)
  static Stream<QuerySnapshot> getWorkerCashoutsByStatus(String workerId, String status) {
    return _firestore
        .collection(_cashoutsCollection)
        .where('workerId', isEqualTo: workerId)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }
}

