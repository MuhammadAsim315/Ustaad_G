import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/notification_service.dart';

class ChatController extends GetxController {
  final String otherUserId;
  final String otherUserName;
  
  final TextEditingController messageController = TextEditingController();
  var messages = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var isSending = false.obs;
  
  late String chatId;
  late String currentUserId;
  
  ChatController({
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  void onInit() {
    super.onInit();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
      // Create a consistent chat ID (sorted to ensure same chat for both users)
      final userIds = [currentUserId, otherUserId]..sort();
      chatId = '${userIds[0]}_${userIds[1]}';
      loadMessages();
    } else {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  /// Load chat messages
  void loadMessages() {
    try {
      isLoading.value = true;
      
      // Listen to messages in real-time
      FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        messages.value = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
        isLoading.value = false;
      });
    } catch (e) {
      debugPrint('Error loading messages: $e');
      isLoading.value = false;
    }
  }

  /// Send a message
  Future<void> sendMessage() async {
    final messageText = messageController.text.trim();
    if (messageText.isEmpty || isSending.value) return;

    try {
      isSending.value = true;
      
      // Create chat document if it doesn't exist
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .set({
        'participants': [currentUserId, otherUserId],
        'lastMessage': messageText,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Add message to subcollection
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': currentUserId,
        'receiverId': otherUserId,
        'message': messageText,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      // Send notification to recipient
      await _sendChatNotification(otherUserId, messageText);
      
      // Track chat message sent
      await AnalyticsService.logChatMessageSent(
        chatId: chatId,
        recipientId: otherUserId,
      );

      // Clear input
      messageController.clear();
    } catch (e) {
      debugPrint('Error sending message: $e');
      Get.snackbar(
        'Error',
        'Failed to send message. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSending.value = false;
    }
  }

  /// Mark messages as read
  Future<void> markAsRead() async {
    try {
      final unreadMessages = messages.where((msg) => 
        msg['senderId'] == otherUserId && 
        msg['read'] != true
      ).toList();

      for (var msg in unreadMessages) {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(msg['id'])
            .update({'read': true});
      }
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  /// Send notification when a new message is sent
  Future<void> _sendChatNotification(String recipientId, String message) async {
    try {
      await NotificationService.sendNotificationToUser(
        userId: recipientId,
        title: otherUserName,
        body: message,
        type: 'chat_message',
        data: {
          'workerId': otherUserId,
          'workerName': otherUserName,
        },
      );
    } catch (e) {
      debugPrint('Error sending chat notification: $e');
    }
  }
}

