import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:firebase_auth/firebase_auth.dart';

/// Service for storing profile images locally on the device
class LocalStorageService {
  static const String _profileImageKey = 'profile_image_base64';
  static const String _profileImagePathKey = 'profile_image_local_path';

  /// Get the local directory for storing profile images
  static Future<Directory> _getProfileImageDirectory() async {
    if (kIsWeb) {
      throw Exception('Local file storage not available on web');
    }
    
    final appDir = await getApplicationDocumentsDirectory();
    final profileDir = Directory('${appDir.path}/profile_images');
    
    if (!await profileDir.exists()) {
      await profileDir.create(recursive: true);
    }
    
    return profileDir;
  }

  /// Save profile image locally
  static Future<String> saveProfileImageLocally({
    File? imageFile,
    Uint8List? imageBytes,
    String? base64String,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      String base64;
      
      // Get base64 string
      if (base64String != null) {
        base64 = base64String;
      } else if (imageBytes != null) {
        base64 = base64Encode(imageBytes);
      } else if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        base64 = base64Encode(bytes);
      } else {
        throw Exception('No image data provided');
      }

      // Save base64 to SharedPreferences (works on all platforms)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${_profileImageKey}_${user.uid}', base64);

      // Also save as file on mobile (for faster access)
      if (!kIsWeb && imageFile != null) {
        try {
          final profileDir = await _getProfileImageDirectory();
          final localFile = File('${profileDir.path}/profile_${user.uid}.jpg');
          await imageFile.copy(localFile.path);
          
          // Save the local path
          await prefs.setString('${_profileImagePathKey}_${user.uid}', localFile.path);
        } catch (e) {
          debugPrint('Failed to save image file locally: $e');
          // Continue even if file save fails, base64 in SharedPreferences will work
        }
      }

      return base64;
    } catch (e) {
      throw Exception('Failed to save image locally: $e');
    }
  }

  /// Load profile image from local storage
  static Future<String?> loadProfileImageLocally() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final prefs = await SharedPreferences.getInstance();
      
      // First try to load from SharedPreferences (base64)
      final base64 = prefs.getString('${_profileImageKey}_${user.uid}');
      if (base64 != null && base64.isNotEmpty) {
        return base64;
      }

      // On mobile, try to load from local file
      if (!kIsWeb) {
        try {
          final localPath = prefs.getString('${_profileImagePathKey}_${user.uid}');
          if (localPath != null) {
            final file = File(localPath);
            if (await file.exists()) {
              final bytes = await file.readAsBytes();
              final base64FromFile = base64Encode(bytes);
              
              // Update SharedPreferences with the loaded image
              await prefs.setString('${_profileImageKey}_${user.uid}', base64FromFile);
              return base64FromFile;
            }
          }
        } catch (e) {
          debugPrint('Failed to load image file locally: $e');
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error loading local profile image: $e');
      return null;
    }
  }

  /// Delete local profile image
  static Future<void> deleteProfileImageLocally() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final prefs = await SharedPreferences.getInstance();
      
      // Remove from SharedPreferences
      await prefs.remove('${_profileImageKey}_${user.uid}');
      await prefs.remove('${_profileImagePathKey}_${user.uid}');

      // Delete local file on mobile
      if (!kIsWeb) {
        try {
          final localPath = prefs.getString('${_profileImagePathKey}_${user.uid}');
          if (localPath != null) {
            final file = File(localPath);
            if (await file.exists()) {
              await file.delete();
            }
          }
        } catch (e) {
          debugPrint('Failed to delete local image file: $e');
        }
      }
    } catch (e) {
      debugPrint('Error deleting local profile image: $e');
    }
  }

  /// Get local file path for profile image (mobile only)
  static Future<String?> getLocalImagePath() async {
    if (kIsWeb) return null;
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final prefs = await SharedPreferences.getInstance();
      final localPath = prefs.getString('${_profileImagePathKey}_${user.uid}');
      
      if (localPath != null) {
        final file = File(localPath);
        if (await file.exists()) {
          return localPath;
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
}

