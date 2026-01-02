// This file is only imported on web platforms
// It provides a stub for image compression (no compression on web)
import 'dart:io';
import 'dart:typed_data';

class ImageCompressor {
  static Future<Uint8List> compressFile(File imageFile, {int? minWidth, int? minHeight, int quality = 85}) async {
    // On web, just read the file without compression
    return await imageFile.readAsBytes();
  }
}

