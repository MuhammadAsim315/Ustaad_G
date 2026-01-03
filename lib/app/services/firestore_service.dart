import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;

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
  }) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).set({
        'name': name,
        'email': email,
        'phone': phone ?? '',
        'profileImageUrl': profileImageUrl ?? '',
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
  static Stream<QuerySnapshot> getUserHistory(String userId) {
    return _firestore
        .collection(_historyCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get user history by status
  static Stream<QuerySnapshot> getUserHistoryByStatus(String userId, String status) {
    return _firestore
        .collection(_historyCollection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
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
  }) async {
    try {
      final docRef = await _firestore.collection(_bookingsCollection).add({
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
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save booking: $e');
    }
  }

  /// Get user bookings
  static Stream<QuerySnapshot> getUserBookings(String userId) {
    return _firestore
        .collection(_bookingsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get user bookings by status
  static Stream<QuerySnapshot> getUserBookingsByStatus(String userId, String status) {
    return _firestore
        .collection(_bookingsCollection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Update booking status
  static Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore.collection(_bookingsCollection).doc(bookingId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
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
  
  /// Get workers by service category
  static Future<List<Map<String, dynamic>>> getWorkersByService(String serviceName) async {
    try {
      // Query users collection for workers who offer this service
      // In production, you might have a 'servicesOffered' array field or a 'workers' collection
      final snapshot = await _firestore
          .collection(_usersCollection)
          .where('servicesOffered', arrayContains: serviceName)
          .get();
      
      final workers = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
      
      // If no workers found with servicesOffered field, return empty list
      // In a real app, you might want to have a separate 'workers' collection
      return workers;
    } catch (e) {
      // If the query fails (e.g., no index), return empty list
      debugPrint('Error getting workers by service: $e');
      return [];
    }
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
}

