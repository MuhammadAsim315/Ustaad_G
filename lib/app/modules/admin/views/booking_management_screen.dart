import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../services/firestore_service.dart';
import '../../../services/admin_service.dart';

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Booking Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4CAF50),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4CAF50),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsList(FirestoreService.getAllBookings()),
          _buildBookingsList(FirestoreService.getBookingsByStatus('pending')),
          _buildBookingsList(FirestoreService.getBookingsByStatus('in_progress')),
          _buildBookingsList(FirestoreService.getBookingsByStatus('completed')),
        ],
      ),
    );
  }

  Widget _buildBookingsList(Stream<QuerySnapshot> stream) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No bookings found'),
          );
        }

        final bookings = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final bookingDoc = bookings[index];
            final bookingData = bookingDoc.data() as Map<String, dynamic>;
            return _buildBookingCard(bookingDoc.id, bookingData);
          },
        );
      },
    );
  }

  Widget _buildBookingCard(String bookingId, Map<String, dynamic> booking) {
    final serviceName = booking['serviceName'] ?? 'Unknown Service';
    final status = booking['status'] ?? 'pending';
    final amount = (booking['amount'] as num? ?? 0).toDouble();
    final customerId = booking['customerId'] ?? '';
    final workerId = booking['workerId'] ?? '';
    final date = booking['date'] as Timestamp?;
    final createdAt = booking['createdAt'] as Timestamp?;

    Color statusColor;
    String statusText;
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      case 'accepted':
        statusColor = Colors.blue;
        statusText = 'Accepted';
        break;
      case 'in_progress':
        statusColor = Colors.purple;
        statusText = 'In Progress';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Completed';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Cancelled';
        break;
      default:
        statusColor = Colors.grey;
        statusText = status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Booking ID: ${bookingId.substring(0, 8)}...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (date != null)
            _buildInfoRow(
              Icons.calendar_today,
              'Date: ${DateFormat('MMM dd, yyyy').format(date.toDate())}',
            ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.currency_rupee,
            'Amount: PKR ${NumberFormat('#,##0').format(amount)}',
          ),
          const SizedBox(height: 8),
          if (customerId.isNotEmpty)
            _buildInfoRow(
              Icons.person,
              'Customer: ${customerId.substring(0, 8)}...',
            ),
          if (workerId.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.work,
              'Worker: ${workerId.substring(0, 8)}...',
            ),
          ],
          if (createdAt != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time,
              'Created: ${DateFormat('MMM dd, yyyy HH:mm').format(createdAt.toDate())}',
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showBookingDetails(bookingId, booking),
                  child: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 8),
              if (status != 'completed' && status != 'cancelled')
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _deleteBooking(bookingId),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Delete'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  void _showBookingDetails(String bookingId, Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Booking ID', bookingId),
              _buildDetailRow('Service', booking['serviceName'] ?? 'N/A'),
              _buildDetailRow('Status', booking['status'] ?? 'N/A'),
              _buildDetailRow('Amount', 'PKR ${booking['amount'] ?? 0}'),
              _buildDetailRow('Customer ID', booking['customerId'] ?? 'N/A'),
              _buildDetailRow('Worker ID', booking['workerId'] ?? 'N/A'),
              _buildDetailRow('Address', booking['address'] ?? 'N/A'),
              _buildDetailRow('Time', booking['time'] ?? 'N/A'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _deleteBooking(String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Booking'),
        content: const Text('Are you sure you want to delete this booking? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                if (!await AdminService.isAdmin()) {
                  throw Exception('Only admins can delete bookings');
                }
                await FirestoreService.deleteBookingAdmin(bookingId);
                Get.snackbar(
                  'Success',
                  'Booking deleted',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF4CAF50),
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to delete booking: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

