import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileUtils {
  /// Copies [sourceFile] into the app documents `profile_images` folder
  /// and returns the saved file path.
  static Future<String> copyProfileImageToApp(File sourceFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(appDir.path, 'profile_images'));
    if (!imagesDir.existsSync()) {
      imagesDir.createSync(recursive: true);
    }
    final ext = p.extension(sourceFile.path);
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}$ext';
    final savedPath = p.join(imagesDir.path, fileName);
    final savedFile = await sourceFile.copy(savedPath);
    return savedFile.path;
  }

  /// Deletes file at [path] if it exists.
  static Future<void> deleteFileIfExists(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final f = File(path);
      if (await f.exists()) {
        await f.delete();
      }
    } catch (e) {
      // Falha de limpeza não é crítica, mas ajuda no diagnóstico.
      debugPrint('FileUtils: erro ao excluir arquivo "$path": $e');
    }
  }
}
