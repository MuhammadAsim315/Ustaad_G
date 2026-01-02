// This file is only imported on mobile platforms
// It provides image compression functionality
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressor {
  static const int targetWidth = 400;
  static const int targetHeight = 400;
  
  static Future<Uint8List> compressFile(File imageFile, {int? minWidth, int? minHeight, int quality = 85}) async {
    final compressedBytes = await FlutterImageCompress.compressWithFile(
      imageFile.absolute.path,
      minWidth: minWidth ?? targetWidth,
      minHeight: minHeight ?? targetHeight,
      quality: quality,
      format: CompressFormat.jpeg,
    );
    
    if (compressedBytes == null || compressedBytes.isEmpty) {
      throw Exception('Failed to compress image');
    }
    
    return Uint8List.fromList(compressedBytes);
  }
}

