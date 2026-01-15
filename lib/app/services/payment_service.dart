import 'package:flutter/foundation.dart' show debugPrint;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'analytics_service.dart';

/// Payment methods supported
enum PaymentMethod {
  cod, // Cash on Delivery
  jazzcash,
  easypaisa,
  card, // Credit/Debit Card
}

/// Payment status
enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
}

/// Payment Service for handling payment processing
class PaymentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _paymentsCollection = 'payments';

  /// Process payment for a booking
  /// Returns payment ID and status
  static Future<Map<String, dynamic>> processPayment({
    required String bookingId,
    required String customerId,
    required double amount,
    required PaymentMethod method,
    Map<String, dynamic>? paymentDetails, // Additional details like card number, wallet number, etc.
  }) async {
    try {
      debugPrint('PaymentService: Processing payment for booking $bookingId');
      debugPrint('PaymentService: Method: $method, Amount: $amount');

      // Create payment record
      final paymentData = <String, Object>{
        'bookingId': bookingId,
        'customerId': customerId,
        'amount': amount,
        'method': method.name,
        'status': PaymentStatus.pending.name,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add payment method specific details
      if (paymentDetails != null) {
        paymentData.addAll(paymentDetails.map((key, value) => MapEntry(key, value as Object)));
      }

      final paymentRef = await _firestore
          .collection(_paymentsCollection)
          .add(paymentData);

      final paymentId = paymentRef.id;
      debugPrint('PaymentService: Payment record created: $paymentId');

      // Process payment based on method
      PaymentStatus finalStatus;
      String? transactionId;

      switch (method) {
        case PaymentMethod.cod:
          // Cash on Delivery - mark as completed (payment will be collected on delivery)
          finalStatus = PaymentStatus.completed;
          transactionId = 'COD-${DateTime.now().millisecondsSinceEpoch}';
          break;

        case PaymentMethod.jazzcash:
        case PaymentMethod.easypaisa:
        case PaymentMethod.card:
          // For MVP: Simulate payment processing
          // TODO: Integrate with actual payment gateway APIs
          finalStatus = await _processOnlinePayment(
            paymentId: paymentId,
            method: method,
            amount: amount,
            paymentDetails: paymentDetails,
          );
          transactionId = '${method.name.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}';
          break;
      }

      // Update payment record with final status
      await paymentRef.update({
        'status': finalStatus.name,
        'transactionId': transactionId,
        'updatedAt': FieldValue.serverTimestamp(),
        if (finalStatus == PaymentStatus.completed)
          'completedAt': FieldValue.serverTimestamp(),
        if (finalStatus == PaymentStatus.failed)
          'failedAt': FieldValue.serverTimestamp(),
      });

      // Update booking with payment info
      await _firestore.collection('bookings').doc(bookingId).update({
        'paymentMethod': method.name,
        'paymentStatus': finalStatus.name,
        'paymentId': paymentId,
        'transactionId': transactionId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Track payment event
      await AnalyticsService.logEvent(
        name: 'payment_processed',
        parameters: {
          'payment_method': method.name,
          'amount': amount,
          'status': finalStatus.name,
          'booking_id': bookingId,
        },
      );

      debugPrint('PaymentService: Payment processed successfully');
      return {
        'paymentId': paymentId,
        'status': finalStatus.name,
        'transactionId': transactionId,
      };
    } catch (e) {
      debugPrint('PaymentService: Error processing payment: $e');
      rethrow;
    }
  }

  /// Process online payment (JazzCash, EasyPaisa, Card)
  /// For MVP: Simulates payment processing
  /// TODO: Replace with actual payment gateway integration
  static Future<PaymentStatus> _processOnlinePayment({
    required String paymentId,
    required PaymentMethod method,
    required double amount,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      // Update status to processing
      await _firestore.collection(_paymentsCollection).doc(paymentId).update({
        'status': PaymentStatus.processing.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Simulate payment gateway API call
      // In production, this would call:
      // - JazzCash API
      // - EasyPaisa API
      // - Stripe/PayPal for cards
      await Future.delayed(const Duration(seconds: 2));

      // For MVP: Simulate successful payment
      // In production, check actual API response
      // TODO: Replace with actual API response check
      return PaymentStatus.completed;
    } catch (e) {
      debugPrint('PaymentService: Error in online payment processing: $e');
      return PaymentStatus.failed;
    }
  }

  /// Get payment by ID
  static Future<Map<String, dynamic>?> getPayment(String paymentId) async {
    try {
      final doc = await _firestore
          .collection(_paymentsCollection)
          .doc(paymentId)
          .get();
      if (!doc.exists) return null;
      return {
        'id': doc.id,
        ...doc.data()!,
      };
    } catch (e) {
      debugPrint('PaymentService: Error getting payment: $e');
      return null;
    }
  }

  /// Get payments for a booking
  static Stream<QuerySnapshot> getBookingPayments(String bookingId) {
    return _firestore
        .collection(_paymentsCollection)
        .where('bookingId', isEqualTo: bookingId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get customer payment history
  static Stream<QuerySnapshot> getCustomerPayments(String customerId) {
    return _firestore
        .collection(_paymentsCollection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  /// Refund payment (admin only)
  static Future<void> refundPayment({
    required String paymentId,
    required double amount,
    String? reason,
  }) async {
    try {
      await _firestore.collection(_paymentsCollection).doc(paymentId).update({
        'status': PaymentStatus.refunded.name,
        'refundAmount': amount,
        'refundReason': reason ?? '',
        'refundedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Track refund event
      await AnalyticsService.logEvent(
        name: 'payment_refunded',
        parameters: {
          'payment_id': paymentId,
          'refund_amount': amount,
        },
      );
    } catch (e) {
      debugPrint('PaymentService: Error refunding payment: $e');
      rethrow;
    }
  }

  /// Get payment method display name
  static String getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cod:
        return 'Cash on Delivery';
      case PaymentMethod.jazzcash:
        return 'JazzCash';
      case PaymentMethod.easypaisa:
        return 'EasyPaisa';
      case PaymentMethod.card:
        return 'Credit/Debit Card';
    }
  }

  /// Get payment status display name
  static String getPaymentStatusName(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }

  /// Get payment status color
  static int getPaymentStatusColor(String status) {
    switch (status) {
      case 'pending':
        return 0xFFFF9800; // Orange
      case 'processing':
        return 0xFF2196F3; // Blue
      case 'completed':
        return 0xFF4CAF50; // Green
      case 'failed':
        return 0xFFF44336; // Red
      case 'refunded':
        return 0xFF9E9E9E; // Grey
      default:
        return 0xFF9E9E9E;
    }
  }
}

