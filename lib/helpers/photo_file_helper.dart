import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Helper para gerenciar arquivos de foto no sistema de arquivos
/// Substitui o armazenamento BLOB no SQLite para melhor performance
class PhotoFileHelper {
  static const String _photosFolder = 'photos';

  /// Obtém o diretório onde as fotos serão salvas
  static Future<Directory> getPhotosDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(path.join(appDir.path, _photosFolder));

    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    return photosDir;
  }

  /// Salva uma foto no sistema de arquivos e retorna o caminho
  static Future<String> savePhoto(Uint8List photoData, int historiaId) async {
    final photosDir = await getPhotosDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'photo_${historiaId}_$timestamp.jpg';
    final filePath = path.join(photosDir.path, fileName);

    final file = File(filePath);
    await file.writeAsBytes(photoData);

    return filePath;
  }

  /// Lê uma foto do sistema de arquivos
  static Future<Uint8List?> readPhoto(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao ler foto: $e');
      return null;
    }
  }

  /// Deleta uma foto do sistema de arquivos
  static Future<bool> deletePhoto(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erro ao deletar foto: $e');
      return false;
    }
  }

  /// Lista todas as fotos de uma história
  static Future<List<String>> listPhotosForHistoria(int historiaId) async {
    final photosDir = await getPhotosDirectory();
    final files = photosDir.listSync();

    return files
        .whereType<File>()
        .where(
          (file) => path.basename(file.path).startsWith('photo_${historiaId}_'),
        )
        .map((file) => file.path)
        .toList();
  }

  /// Limpa fotos órfãs (sem referência no banco)
  static Future<void> cleanOrphanPhotos(List<String> validPaths) async {
    final photosDir = await getPhotosDirectory();
    final files = photosDir.listSync();

    for (final file in files) {
      if (file is File && !validPaths.contains(file.path)) {
        try {
          await file.delete();
        } catch (e) {
          // Erro ao deletar foto órfã - ignora e continua
          debugPrint('Erro ao deletar foto órfã: $e');
        }
      }
    }
  }

  /// Obtém o tamanho total das fotos em bytes
  static Future<int> getTotalSize() async {
    final photosDir = await getPhotosDirectory();
    if (!await photosDir.exists()) return 0;

    int totalSize = 0;
    final files = photosDir.listSync();
    for (final file in files) {
      if (file is File) {
        totalSize += await file.length();
      }
    }
    return totalSize;
  }
}
