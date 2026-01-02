import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'image_service.dart';
import 'firestore_service.dart';

/// Service class for profile image storage
/// Uses Firestore to store images as base64 (free alternative to Firebase Storage)
class StorageService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Save profile image as base64 in Firestore
  /// Returns a reference string (not a URL, but an identifier)
  static Future<String> uploadProfileImage({
    File? imageFile,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Compress and encode image to base64
      final base64String = await ImageService.compressAndEncodeImage(
        imageFile: imageFile,
        imageBytes: imageBytes,
      );
      
      // Store base64 image in Firestore user document
      await FirestoreService.updateUserProfile(
        profileImageUrl: base64String, // Store as base64 string
      );
      
      // Return a reference identifier (we'll use 'base64' prefix to identify it)
      return 'base64:${user.uid}';
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }

  /// Delete profile image (remove from Firestore)
  static Future<void> deleteProfileImage(String imageRef) async {
    try {
      // For base64 images stored in Firestore, just clear the field
      if (imageRef.startsWith('base64:')) {
        await FirestoreService.updateUserProfile(
          profileImageUrl: '', // Clear the image
        );
      }
    } catch (e) {
      debugPrint('Failed to delete image: $e');
    }
  }
}

