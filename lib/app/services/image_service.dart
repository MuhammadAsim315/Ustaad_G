import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:image_picker/image_picker.dart';

// Conditional import - different implementation for web vs mobile
import 'image_service_mobile.dart' if (dart.library.html) 'image_service_web.dart' as compressor;

/// Service class for image processing and storage
/// Stores images as base64 in Firestore (free alternative to Firebase Storage)
class ImageService {
  /// Maximum image size in bytes (800KB to stay under Firestore's 1MB limit)
  static const int maxImageSize = 800 * 1024;
  
  /// Target image dimensions for profile pictures
  static const int targetWidth = 400;
  static const int targetHeight = 400;
  
  /// Compress and convert image to base64 string
  /// Returns base64 string that can be stored in Firestore
  static Future<String> compressAndEncodeImage({
    File? imageFile,
    Uint8List? imageBytes,
    XFile? xFile,
  }) async {
    try {
      Uint8List bytes;
      
      // Get image bytes
      if (kIsWeb) {
        // For web, just use the bytes directly (no compression available)
        if (imageBytes != null) {
          bytes = imageBytes;
        } else if (xFile != null) {
          bytes = await xFile.readAsBytes();
        } else {
          throw Exception('Image bytes or XFile required for web');
        }
      } else {
        // For mobile, try to compress
        if (imageFile != null) {
          bytes = await _compressImageFile(imageFile);
        } else if (imageBytes != null) {
          bytes = imageBytes;
        } else if (xFile != null) {
          final file = File(xFile.path);
          bytes = await _compressImageFile(file);
        } else {
          throw Exception('Image file, bytes, or XFile required');
        }
      }
      
      if (bytes.isEmpty) {
        throw Exception('Image bytes are empty');
      }
      
      // Check size
      if (bytes.length > maxImageSize) {
        // If still too large, compress more aggressively (mobile only)
        if (!kIsWeb && imageFile != null) {
          bytes = await _compressMoreAggressively(imageFile);
        } else {
          throw Exception('Image is too large (max 800KB). Please choose a smaller image.');
        }
      }
      
      // Convert to base64
      final base64String = base64Encode(bytes);
      return base64String;
    } catch (e) {
      throw Exception('Failed to process image: $e');
    }
  }
  
  /// Compress image file (uses platform-specific implementation)
  static Future<Uint8List> _compressImageFile(File imageFile) async {
    try {
      return await compressor.ImageCompressor.compressFile(
        imageFile,
        minWidth: targetWidth,
        minHeight: targetHeight,
        quality: 85,
      );
    } catch (e) {
      // Compression failed, fallback to reading file directly
      debugPrint('Image compression failed, using original: $e');
      return await imageFile.readAsBytes();
    }
  }
  
  /// More aggressive compression if initial compression wasn't enough
  static Future<Uint8List> _compressMoreAggressively(File imageFile) async {
    try {
      return await compressor.ImageCompressor.compressFile(
        imageFile,
        minWidth: 300,
        minHeight: 300,
        quality: 70,
      );
    } catch (e) {
      debugPrint('Aggressive compression failed: $e');
      return await imageFile.readAsBytes();
    }
  }
  
  /// Decode base64 string to image bytes
  static Uint8List decodeBase64Image(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      throw Exception('Failed to decode base64 image: $e');
    }
  }
  
  /// Get data URL for displaying base64 image in web
  static String getDataUrl(String base64String) {
    return 'data:image/jpeg;base64,$base64String';
  }
  
  /// Check if string is a base64 image
  static bool isBase64Image(String? imageString) {
    if (imageString == null || imageString.isEmpty) return false;
    // Base64 images stored in Firestore won't have data URL prefix
    // They're just the base64 string
    try {
      base64Decode(imageString);
      return true;
    } catch (e) {
      return false;
    }
  }
}
