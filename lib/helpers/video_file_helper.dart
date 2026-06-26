import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Helper para gerenciar arquivos de vídeo no sistema de arquivos
/// Evita o problema de "Row too big to fit into CursorWindow" do SQLite
class VideoFileHelper {
  static const String _videosFolder = 'videos';

  /// Obtém o diretório onde os vídeos serão salvos
  static Future<Directory> getVideosDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final videosDir = Directory(path.join(appDir.path, _videosFolder));

    if (!await videosDir.exists()) {
      await videosDir.create(recursive: true);
    }

    return videosDir;
  }

  /// Salva um vídeo no sistema de arquivos e retorna o caminho
  static Future<String> saveVideo(Uint8List videoData, int historiaId) async {
    final videosDir = await getVideosDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'video_${historiaId}_$timestamp.mp4';
    final filePath = path.join(videosDir.path, fileName);

    final file = File(filePath);
    await file.writeAsBytes(videoData);

    return filePath;
  }

  /// Lê um vídeo do sistema de arquivos
  static Future<Uint8List?> readVideo(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      debugPrint('VideoFileHelper.readVideo: erro ao ler arquivo em $filePath: $e');
      return null;
    }
  }

  /// Deleta um vídeo do sistema de arquivos
  static Future<bool> deleteVideo(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('VideoFileHelper.deleteVideo: erro ao deletar arquivo em $filePath: $e');
      return false;
    }
  }

  /// Lista todos os vídeos de uma história
  static Future<List<String>> listVideosForHistoria(int historiaId) async {
    final videosDir = await getVideosDirectory();
    final files = videosDir.listSync();

    return files
        .whereType<File>()
        .where(
          (file) => path.basename(file.path).startsWith('video_${historiaId}_'),
        )
        .map((file) => file.path)
        .toList();
  }

  /// Limpa vídeos órfãos (sem referência no banco)
  static Future<void> cleanOrphanVideos(List<String> validPaths) async {
    final videosDir = await getVideosDirectory();
    final files = videosDir.listSync();

    for (final file in files) {
      if (file is File && !validPaths.contains(file.path)) {
        try {
          await file.delete();
        } catch (e) {
          // Erro ao deletar vídeo órfão - ignora e continua
          debugPrint('Erro ao deletar vídeo órfão: $e');
        }
      }
    }
  }
}
