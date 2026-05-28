import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Helper para gerenciar arquivos de áudio no sistema de arquivos
/// Substitui o armazenamento BLOB no SQLite para melhor performance
class AudioFileHelper {
  static const String _audiosFolder = 'audios';

  /// Obtém o diretório onde os áudios serão salvos
  static Future<Directory> getAudiosDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final audiosDir = Directory(path.join(appDir.path, _audiosFolder));

    if (!await audiosDir.exists()) {
      await audiosDir.create(recursive: true);
    }

    return audiosDir;
  }

  /// Salva um áudio no sistema de arquivos e retorna o caminho
  static Future<String> saveAudio(Uint8List audioData, int historiaId) async {
    final audiosDir = await getAudiosDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'audio_${historiaId}_$timestamp.m4a';
    final filePath = path.join(audiosDir.path, fileName);

    final file = File(filePath);
    await file.writeAsBytes(audioData);

    return filePath;
  }

  /// Lê um áudio do sistema de arquivos
  static Future<Uint8List?> readAudio(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao ler áudio: $e');
      return null;
    }
  }

  /// Deleta um áudio do sistema de arquivos
  static Future<bool> deleteAudio(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erro ao deletar áudio: $e');
      return false;
    }
  }

  /// Lista todos os áudios de uma história
  static Future<List<String>> listAudiosForHistoria(int historiaId) async {
    final audiosDir = await getAudiosDirectory();
    final files = audiosDir.listSync();

    return files
        .whereType<File>()
        .where(
          (file) => path.basename(file.path).startsWith('audio_${historiaId}_'),
        )
        .map((file) => file.path)
        .toList();
  }

  /// Limpa áudios órfãos (sem referência no banco)
  static Future<void> cleanOrphanAudios(List<String> validPaths) async {
    final audiosDir = await getAudiosDirectory();
    final files = audiosDir.listSync();

    for (final file in files) {
      if (file is File && !validPaths.contains(file.path)) {
        try {
          await file.delete();
        } catch (e) {
          // Erro ao deletar áudio órfão - ignora e continua
          debugPrint('Erro ao deletar áudio órfão: $e');
        }
      }
    }
  }

  /// Obtém o tamanho total dos áudios em bytes
  static Future<int> getTotalSize() async {
    final audiosDir = await getAudiosDirectory();
    if (!await audiosDir.exists()) return 0;

    int totalSize = 0;
    final files = audiosDir.listSync();
    for (final file in files) {
      if (file is File) {
        totalSize += await file.length();
      }
    }
    return totalSize;
  }
}
