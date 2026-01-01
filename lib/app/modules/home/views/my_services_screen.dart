import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utils/icon_helper.dart';

class MyServicesScreen extends StatelessWidget {
  const MyServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> myServices = [
      {
        'name': 'Plumber',
        'status': 'Active',
        'bookings': 12,
        'rating': 4.8,
      },
      {
        'name': 'Electrician',
        'status': 'Active',
        'bookings': 8,
        'rating': 4.9,
      },
      {
        'name': 'Carpenter',
        'status': 'Inactive',
        'bookings': 5,
        'rating': 4.7,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                  const Text(
                    'My Services',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: myServices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.build_circle_outlined,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No services yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first service to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: myServices.length,
                      itemBuilder: (context, index) {
                        final service = myServices[index];
                        return _buildServiceCard(service);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final bool isActive = service['status'] == 'Active';
    final serviceName = service['name'] as String;
    final svgPath = IconHelper.getSvgIconPath(serviceName);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: svgPath != null
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      svgPath,
                      width: 46,
                      height: 46,
                      fit: BoxFit.contain,
                    ),
                  )
                : Icon(
                    Icons.category,
                    color: const Color(0xFF4A5C7A),
                    size: 35,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        service['status'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? const Color(0xFF4CAF50)
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${service['rating']}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${service['bookings']} bookings',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
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
    );
  }
}

