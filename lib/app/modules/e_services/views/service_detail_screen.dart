import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utils/icon_helper.dart';
import '../controllers/service_detail_controller.dart';

class ServiceDetailScreen extends StatelessWidget {
  final String serviceName;
  final String? serviceSvgPath;
  final Color serviceColor;

  const ServiceDetailScreen({
    super.key,
    required this.serviceName,
    this.serviceSvgPath,
    required this.serviceColor,
  });

  @override
  Widget build(BuildContext context) {
    final ServiceDetailController controller = Get.put(
      ServiceDetailController(serviceName: serviceName),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.black87,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      serviceName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Service icon and workers list
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service icon display
                      Center(
                        child: _buildServiceIcon(),
                      ),
                      const SizedBox(height: 30),

                      // Description section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Service Description',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Professional $serviceName services with experienced and verified service providers. We ensure quality work and customer satisfaction.',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[700],
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Available providers section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Available Providers',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (controller.workers.isNotEmpty)
                                      Text(
                                        '${controller.workers.length} available',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    const SizedBox(width: 12),
                                    // Filter button
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => _showFilterDialog(context, controller),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.tune,
                                                size: 18,
                                                color: Color(0xFF4CAF50),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Filter',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Provider cards
                            if (controller.workers.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(40),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No workers available',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ...controller.workers.map((worker) {
                                final pricing = worker['servicePricing'] as Map<String, dynamic>?;
                                final price = pricing?[serviceName] as num?;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildProviderCard(
                                    workerId: worker['id'] ?? '',
                                    name: worker['name'] ?? 'Worker',
                                    rating: (worker['averageRating'] ?? worker['rating'] ?? 0.0) as double,
                                    reviews: (worker['totalReviews'] ?? worker['reviews'] ?? 0) as int,
                                    experience: worker['yearsOfExperience'] != null 
                                        ? '${worker['yearsOfExperience']} years'
                                        : (worker['experience'] ?? 'N/A'),
                                    location: worker['serviceArea'] as String?,
                                    price: price?.toDouble(),
                                  ),
                                );
                              }),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Build service icon (SVG or fallback)
  Widget _buildServiceIcon() {
    final svgPath = serviceSvgPath ?? IconHelper.getSvgIconPath(serviceName);
    
    if (svgPath != null) {
      return SvgPicture.asset(
        svgPath,
        width: 120,
        height: 120,
        fit: BoxFit.contain,
        placeholderBuilder: (BuildContext context) => Icon(
          Icons.category,
          size: 100,
          color: serviceColor,
        ),
      );
    }
    
    // Fallback to default icon
    return Icon(
      Icons.category,
      size: 100,
      color: serviceColor,
    );
  }

  Widget _buildProviderCard({
    required String workerId,
    required String name,
    required double rating,
    required int reviews,
    required String experience,
    String? location,
    double? price,
  }) {
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Get.toNamed('/worker-profile', arguments: {
            'workerId': workerId,
            'workerName': name,
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF4A5C7A),
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating > 0 ? rating.toStringAsFixed(1) : 'New',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        if (reviews > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '($reviews)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (location != null && location.isNotEmpty) ...[
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          experience,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (price != null && price > 0) ...[
                          const Spacer(),
                          Text(
                            'PKR ${price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Show filter dialog
  void _showFilterDialog(BuildContext context, ServiceDetailController controller) {
    String? tempLocation = controller.selectedLocation.value;
    double? tempMinRating = controller.minRating.value;
    double? tempMaxPrice = controller.maxPrice.value;
    bool tempAvailableNow = controller.availableNow.value;
    String tempSortBy = controller.sortBy.value;
    bool tempSortAscending = controller.sortAscending.value;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Workers',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          tempLocation = null;
                          tempMinRating = null;
                          tempMaxPrice = null;
                          tempAvailableNow = false;
                          tempSortBy = 'rating';
                          tempSortAscending = false;
                        },
                        child: const Text('Clear All'),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location filter
                    _buildFilterSection(
                      'Location',
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'e.g., Lahore, Karachi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) => tempLocation = value.isEmpty ? null : value,
                        controller: TextEditingController(text: tempLocation ?? ''),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Rating filter
                    _buildFilterSection(
                      'Minimum Rating',
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Column(
                            children: [
                              if (tempMinRating != null)
                                Text('${tempMinRating!.toStringAsFixed(1)} stars'),
                              Slider(
                                value: tempMinRating ?? 0.0,
                                min: 0.0,
                                max: 5.0,
                                divisions: 10,
                                label: tempMinRating != null ? tempMinRating!.toStringAsFixed(1) : 'Any',
                                onChanged: (value) {
                                  setState(() => tempMinRating = value);
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() => tempMinRating = null);
                                    },
                                    child: const Text('Clear'),
                                  ),
                                  Text((tempMinRating ?? 0.0).toStringAsFixed(1)),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Price filter
                    _buildFilterSection(
                      'Maximum Price (PKR)',
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter max price',
                          prefixText: 'PKR ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          tempMaxPrice = value.isEmpty ? null : double.tryParse(value);
                        },
                        controller: TextEditingController(
                          text: tempMaxPrice?.toString() ?? '',
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Available now filter
                    _buildFilterSection(
                      'Availability',
                      StatefulBuilder(
                        builder: (context, setState) {
                          return SwitchListTile(
                            title: const Text('Available Now'),
                            subtitle: const Text('Show only workers available at this moment'),
                            value: tempAvailableNow,
                            onChanged: (value) {
                              setState(() => tempAvailableNow = value);
                            },
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Sort options
                    _buildFilterSection(
                      'Sort By',
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Column(
                            children: [
                              RadioGroup<String>(
                                groupValue: tempSortBy,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => tempSortBy = value);
                                  }
                                },
                                child: Column(
                                  children: [
                                    const RadioListTile<String>(
                                      title: Text('Rating'),
                                      value: 'rating',
                                    ),
                                    const RadioListTile<String>(
                                      title: Text('Price'),
                                      value: 'price',
                                    ),
                                    const RadioListTile<String>(
                                      title: Text('Reviews'),
                                      value: 'reviews',
                                    ),
                                    const RadioListTile<String>(
                                      title: Text('Experience'),
                                      value: 'experience',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              SwitchListTile(
                                title: const Text('Ascending Order'),
                                value: tempSortAscending,
                                onChanged: (value) {
                                  setState(() => tempSortAscending = value);
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Apply button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.applyFilters(
                      location: tempLocation,
                      minRatingValue: tempMinRating,
                      maxPriceValue: tempMaxPrice,
                      availableNowValue: tempAvailableNow,
                      sortByValue: tempSortBy,
                      sortAscendingValue: tempSortAscending,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

