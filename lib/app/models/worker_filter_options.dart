import 'package:cloud_firestore/cloud_firestore.dart';

/// Filter options for worker discovery
class WorkerFilterOptions {
  final String? location; // Service area/city
  final double? minRating; // Minimum average rating
  final double? maxPrice; // Maximum price for the service
  final bool? availableNow; // Filter by current availability
  final String? sortBy; // 'rating', 'price', 'reviews', 'experience'
  final bool sortAscending; // Sort direction
  final int? limit; // Pagination limit
  final DocumentSnapshot? startAfter; // For pagination
  
  const WorkerFilterOptions({
    this.location,
    this.minRating,
    this.maxPrice,
    this.availableNow,
    this.sortBy,
    this.sortAscending = false,
    this.limit,
    this.startAfter,
  });
  
  /// Create a copy with updated values
  WorkerFilterOptions copyWith({
    String? location,
    double? minRating,
    double? maxPrice,
    bool? availableNow,
    String? sortBy,
    bool? sortAscending,
    int? limit,
    DocumentSnapshot? startAfter,
  }) {
    return WorkerFilterOptions(
      location: location ?? this.location,
      minRating: minRating ?? this.minRating,
      maxPrice: maxPrice ?? this.maxPrice,
      availableNow: availableNow ?? this.availableNow,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      limit: limit ?? this.limit,
      startAfter: startAfter ?? this.startAfter,
    );
  }
}

