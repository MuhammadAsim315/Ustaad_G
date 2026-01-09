import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../../../services/firestore_service.dart';
import '../../../services/analytics_service.dart';
import '../../../models/worker_filter_options.dart';

class ServiceDetailController extends GetxController {
  final String serviceName;
  
  var workers = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var hasMore = true.obs; // For pagination
  
  // Filter state
  var selectedLocation = Rx<String?>(null);
  var minRating = Rx<double?>(null);
  var maxPrice = Rx<double?>(null);
  var availableNow = false.obs;
  var sortBy = 'rating'.obs; // 'rating', 'price', 'reviews', 'experience'
  var sortAscending = false.obs;
  
  ServiceDetailController({required this.serviceName});

  @override
  void onInit() {
    super.onInit();
    // Track service view
    AnalyticsService.logServiceViewed(serviceName: serviceName);
    loadWorkers();
  }

  /// Load workers for this service category with current filters
  Future<void> loadWorkers({bool reset = false}) async {
    try {
      isLoading.value = true;
      
      if (reset) {
        workers.clear();
        hasMore.value = true;
      }
      
      // Build filter options
      final filters = WorkerFilterOptions(
        location: selectedLocation.value,
        minRating: minRating.value,
        maxPrice: maxPrice.value,
        availableNow: availableNow.value,
        sortBy: sortBy.value,
        sortAscending: sortAscending.value,
        limit: 20, // Load 20 at a time
      );
      
      // Get workers from Firestore with filters
      final workersList = await FirestoreService.getWorkersByServiceWithFilters(
        serviceName,
        filters: filters,
      );
      
      if (workersList.isNotEmpty) {
        // Ratings are already calculated in the service method
        if (reset) {
          workers.value = workersList;
        } else {
          workers.addAll(workersList);
        }
        hasMore.value = workersList.length >= 20; // More might be available
      } else {
        // If no workers found in database, use mock data for demo
        if (reset) {
          workers.value = _getMockWorkers();
        }
      }
    } catch (e) {
      debugPrint('Error loading workers: $e');
      // Fallback to mock data only if reset
      if (reset) {
        workers.value = _getMockWorkers();
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Apply filters and reload
  Future<void> applyFilters({
    String? location,
    double? minRatingValue,
    double? maxPriceValue,
    bool? availableNowValue,
    String? sortByValue,
    bool? sortAscendingValue,
  }) async {
    if (location != null) selectedLocation.value = location.isEmpty ? null : location;
    if (minRatingValue != null) minRating.value = minRatingValue;
    if (maxPriceValue != null) maxPrice.value = maxPriceValue;
    if (availableNowValue != null) availableNow.value = availableNowValue;
    if (sortByValue != null) sortBy.value = sortByValue;
    if (sortAscendingValue != null) sortAscending.value = sortAscendingValue;
    
    await loadWorkers(reset: true);
  }
  
  /// Clear all filters
  Future<void> clearFilters() async {
    selectedLocation.value = null;
    minRating.value = null;
    maxPrice.value = null;
    availableNow.value = false;
    sortBy.value = 'rating';
    sortAscending.value = false;
    await loadWorkers(reset: true);
  }
  
  /// Load more workers (pagination)
  Future<void> loadMore() async {
    if (!hasMore.value || isLoading.value) return;
    await loadWorkers(reset: false);
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

