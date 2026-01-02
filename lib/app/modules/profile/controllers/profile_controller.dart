import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firestore_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/local_storage_service.dart';

class ProfileController extends GetxController {
  var name = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var profileImage = Rx<File?>(null);
  var profileImageBytes = Rx<Uint8List?>(null);
  var profileImagePath = Rx<String?>(null);
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  /// Load user data from Firestore
  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        // FIRST: Try to load image from local storage (fastest, works offline)
        final localImage = await LocalStorageService.loadProfileImageLocally();
        if (localImage != null && localImage.isNotEmpty) {
          profileImagePath.value = localImage;
          // Also set the local file if available (mobile)
          if (!kIsWeb) {
            final localPath = await LocalStorageService.getLocalImagePath();
            if (localPath != null) {
              final file = File(localPath);
              if (await file.exists()) {
                profileImage.value = file;
              }
            }
          }
        }
        
        // Then, try to get data from Firestore
        final userData = await FirestoreService.getUserData(user.uid);
        
        if (userData != null) {
          name.value = userData['name']?.toString() ?? '';
          email.value = userData['email']?.toString() ?? user.email ?? '';
          phone.value = userData['phone']?.toString() ?? '';
          
          // Load profile image from Firestore if local storage doesn't have it
          final imageUrl = userData['profileImageUrl']?.toString();
          if (imageUrl != null && imageUrl.isNotEmpty) {
            // Only update if we don't have a local image, or if Firestore has a newer one
            if (profileImagePath.value == null || profileImagePath.value!.isEmpty) {
              profileImagePath.value = imageUrl;
              // Also save to local storage for future use
              try {
                await LocalStorageService.saveProfileImageLocally(base64String: imageUrl);
              } catch (e) {
                debugPrint('Failed to save Firestore image to local storage: $e');
              }
            }
          }
        } else {
          // If no Firestore data, use Firebase Auth data
          name.value = user.displayName ?? '';
          email.value = user.email ?? '';
          phone.value = user.phoneNumber ?? '';
          
          // Save to Firestore for future use
          if (user.email != null) {
            await FirestoreService.saveUserData(
              userId: user.uid,
              name: name.value.isNotEmpty ? name.value : 'User',
              email: email.value,
              phone: phone.value,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      // Fallback to Firebase Auth if Firestore fails
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        name.value = user.displayName ?? 'User';
        email.value = user.email ?? '';
        phone.value = user.phoneNumber ?? '';
        
        // Try to load from local storage as last resort
        try {
          final localImage = await LocalStorageService.loadProfileImageLocally();
          if (localImage != null && localImage.isNotEmpty) {
            profileImagePath.value = localImage;
          }
        } catch (e) {
          debugPrint('Failed to load local image: $e');
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Update profile and save to Firestore
  Future<void> updateProfile({
    String? newName,
    String? newEmail,
    String? newPhone,
    File? newImage,
    Uint8List? newImageBytes,
    String? newImagePath,
  }) async {
    try {
      String? imageUrl = newImagePath;
      
      // If a new image is provided, save it locally AND to Firestore
      if (newImage != null || newImageBytes != null) {
        // FIRST: Save to local storage (fast, works offline)
        try {
          final localBase64 = await LocalStorageService.saveProfileImageLocally(
            imageFile: newImage,
            imageBytes: newImageBytes,
          );
          // Use local base64 as the image URL
          imageUrl = localBase64;
        } catch (e) {
          debugPrint('Failed to save image locally: $e');
        }
        
        // THEN: Save to Firestore (for sync across devices)
        try {
          final firestoreRef = await StorageService.uploadProfileImage(
            imageFile: newImage,
            imageBytes: newImageBytes,
          );
          // Update imageUrl with Firestore reference if local save failed
          imageUrl ??= firestoreRef;
        } catch (e) {
          debugPrint('Failed to save image to Firestore: $e');
          // Continue even if Firestore fails - local storage will work
        }
      }

      // Update local values
      if (newName != null) name.value = newName;
      if (newEmail != null) email.value = newEmail;
      if (newPhone != null) phone.value = newPhone;
      if (newImage != null) profileImage.value = newImage;
      if (newImageBytes != null) profileImageBytes.value = newImageBytes;
      if (imageUrl != null) profileImagePath.value = imageUrl;

      // Update Firebase Auth display name if name changed
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && newName != null && newName != user.displayName) {
        await user.updateDisplayName(newName);
        await user.reload();
      }

      // Update Firestore with the profile data
      await FirestoreService.updateUserProfile(
        name: newName,
        phone: newPhone,
        profileImageUrl: imageUrl,
      );
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  /// Refresh user data from Firestore
  @override
  Future<void> refresh() async {
    await loadUserData();
  }
}

