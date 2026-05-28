import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Helper class for compressing images before storing in database
/// to avoid SQLite CursorWindow size limit (2MB)
class ImageCompressionHelper {
  /// Compresses an image to ensure it's under 1.5MB for safe database storage
  ///
  /// The SQLite CursorWindow has a 2MB limit on Android. This function
  /// compresses images to ~1.5MB or less to be safe.
  static Future<Uint8List> compressImage(Uint8List imageBytes) async {
    // If image is already small enough (< 1MB), return as-is
    if (imageBytes.length < 1024 * 1024) {
      return imageBytes;
    }

    // Start with quality 85 and reduce until size is acceptable
    int quality = 85;
    Uint8List? compressed;

    while (quality > 20) {
      compressed = await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: quality,
        format: CompressFormat.jpeg,
      );

      // If compressed size is under 1.5MB, we're good
      if (compressed.length < 1024 * 1024 * 1.5) {
        
        return compressed;
      }

      // Reduce quality and try again
      quality -= 10;
    }

    // If we got here, return the last compressed version
    // even if it's still large (better than nothing)

    return compressed ?? imageBytes;
  }
}
