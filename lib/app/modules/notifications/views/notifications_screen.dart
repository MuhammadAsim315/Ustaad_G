import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Booking Confirmed',
        'message': 'Your booking for Plumber service has been confirmed',
        'time': '2 hours ago',
        'icon': Icons.check_circle,
        'color': const Color(0xFF4CAF50),
        'isRead': false,
      },
      {
        'title': 'Service Provider Assigned',
        'message': 'Ahmed Ali has been assigned to your booking',
        'time': '5 hours ago',
        'icon': Icons.person_add,
        'color': Colors.blue,
        'isRead': false,
      },
      {
        'title': 'Payment Successful',
        'message': 'Your payment of PKR 2,200 has been processed',
        'time': '1 day ago',
        'icon': Icons.payment,
        'color': Colors.green,
        'isRead': true,
      },
      {
        'title': 'Service Completed',
        'message': 'Your Plumber service has been completed. Please rate your experience',
        'time': '2 days ago',
        'icon': Icons.done_all,
        'color': const Color(0xFF4CAF50),
        'isRead': true,
      },
      {
        'title': 'Reminder',
        'message': 'You have an upcoming booking tomorrow at 10:00 AM',
        'time': '3 days ago',
        'icon': Icons.notifications_active,
        'color': Colors.orange,
        'isRead': true,
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
                    'Notifications',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // Mark all as read
                    },
                    child: const Text(
                      'Mark all read',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Notifications list
            Expanded(
              child: notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No notifications',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return _buildNotificationCard(notification);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification['isRead'] ? Colors.white : const Color(0xFF4CAF50).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification['isRead'] ? Colors.grey[200]! : const Color(0xFF4CAF50).withValues(alpha: 0.3),
          width: notification['isRead'] ? 1 : 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (notification['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              notification['icon'],
              color: notification['color'],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: notification['isRead'] ? FontWeight.w600 : FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (!notification['isRead'])
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification['message'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification['time'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

