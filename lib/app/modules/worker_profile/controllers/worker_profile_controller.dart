import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../../../services/firestore_service.dart';

class WorkerProfileController extends GetxController {
  final String workerId;
  final String? workerName;
  
  var workerData = Rx<Map<String, dynamic>?>(null);
  var reviews = <Map<String, dynamic>>[].obs;
  var faqs = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var averageRating = 0.0.obs;
  var totalReviews = 0.obs;
  var servicesOffered = <String>[].obs;
  
  WorkerProfileController({
    required this.workerId,
    this.workerName,
  });

  @override
  void onInit() {
    super.onInit();
    loadWorkerData();
    loadReviews();
    loadFAQs();
  }

  /// Load worker profile data
  Future<void> loadWorkerData() async {
    try {
      isLoading.value = true;
      
      // Get worker data from users collection
      final userData = await FirestoreService.getUserData(workerId);
      
      if (userData != null) {
        workerData.value = userData;
        
        // Extract services offered (if stored in user data)
        if (userData['servicesOffered'] != null) {
          servicesOffered.value = List<String>.from(userData['servicesOffered']);
        }
      } else {
        // If no data found, create a basic structure
        workerData.value = {
          'name': workerName ?? 'Service Provider',
          'phone': '',
          'email': '',
          'profileImageUrl': '',
          'experience': '0 years',
          'location': '',
        };
      }
    } catch (e) {
      debugPrint('Error loading worker data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load reviews for this worker
  Future<void> loadReviews() async {
    try {
      // Get reviews from Firestore
      final reviewsSnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('workerId', isEqualTo: workerId)
          .orderBy('createdAt', descending: true)
          .get();

      final reviewsList = reviewsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      reviews.value = reviewsList;
      totalReviews.value = reviewsList.length;

      // Calculate average rating
      if (reviewsList.isNotEmpty) {
        final totalRating = reviewsList
            .where((review) => review['rating'] != null)
            .map((review) => (review['rating'] as num).toDouble())
            .fold(0.0, (total, rating) => total + rating);
        averageRating.value = totalRating / reviewsList.length;
      }
    } catch (e) {
      debugPrint('Error loading reviews: $e');
    }
  }

  /// Load FAQs for this worker
  Future<void> loadFAQs() async {
    try {
      final faqsList = await FirestoreService.getWorkerFAQs(workerId);
      faqs.value = faqsList;
    } catch (e) {
      debugPrint('Error loading FAQs: $e');
    }
  }

  /// Refresh data
  @override
  Future<void> refresh() async {
    await loadWorkerData();
    await loadReviews();
    await loadFAQs();
  }
}

