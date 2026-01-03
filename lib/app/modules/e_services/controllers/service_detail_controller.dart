import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../../../services/firestore_service.dart';

class ServiceDetailController extends GetxController {
  final String serviceName;
  
  var workers = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  
  ServiceDetailController({required this.serviceName});

  @override
  void onInit() {
    super.onInit();
    loadWorkers();
  }

  /// Load workers for this service category
  Future<void> loadWorkers() async {
    try {
      isLoading.value = true;
      
      // Try to get workers from Firestore
      final workersList = await FirestoreService.getWorkersByService(serviceName);
      
      if (workersList.isNotEmpty) {
        // Calculate ratings for each worker
        for (var worker in workersList) {
          final workerId = worker['id'] ?? '';
          if (workerId.isNotEmpty) {
            final reviews = await FirestoreService.getWorkerReviewsOnce(workerId);
            if (reviews.isNotEmpty) {
              final totalRating = reviews
                  .where((review) => review['rating'] != null)
                  .map((review) => (review['rating'] as num).toDouble())
                  .fold(0.0, (total, rating) => total + rating);
              worker['averageRating'] = totalRating / reviews.length;
              worker['totalReviews'] = reviews.length;
            } else {
              worker['averageRating'] = 0.0;
              worker['totalReviews'] = 0;
            }
          }
        }
        workers.value = workersList;
      } else {
        // If no workers found in database, use mock data for demo
        workers.value = _getMockWorkers();
      }
    } catch (e) {
      debugPrint('Error loading workers: $e');
      // Fallback to mock data
      workers.value = _getMockWorkers();
    } finally {
      isLoading.value = false;
    }
  }

  /// Get mock workers for demo purposes
  List<Map<String, dynamic>> _getMockWorkers() {
    return [
      {
        'id': 'ahmed_ali',
        'name': 'Ahmed Ali',
        'rating': 4.8,
        'reviews': 124,
        'experience': '5 years',
        'profileImageUrl': '',
        'location': 'Lahore',
        'phone': '+92 300 1234567',
      },
      {
        'id': 'hassan_khan',
        'name': 'Hassan Khan',
        'rating': 4.9,
        'reviews': 89,
        'experience': '7 years',
        'profileImageUrl': '',
        'location': 'Karachi',
        'phone': '+92 300 2345678',
      },
      {
        'id': 'usman_malik',
        'name': 'Usman Malik',
        'rating': 4.7,
        'reviews': 156,
        'experience': '4 years',
        'profileImageUrl': '',
        'location': 'Islamabad',
        'phone': '+92 300 3456789',
      },
    ];
  }

  /// Refresh workers list
  @override
  Future<void> refresh() async {
    await loadWorkers();
  }
}

