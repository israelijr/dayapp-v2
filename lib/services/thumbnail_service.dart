import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Serviço para geração e cache de thumbnails de imagens
/// Otimiza o carregamento de previews reduzindo o tamanho das imagens
class ThumbnailService {
  // Singleton
  static final ThumbnailService _instance = ThumbnailService._internal();
  factory ThumbnailService() => _instance;
  ThumbnailService._internal();

  // Cache em memória para thumbnails já carregados
  final Map<String, Uint8List> _memoryCache = {};

  // Tamanho padrão do thumbnail (largura máxima)
  static const int defaultThumbnailWidth = 200;
  static const int defaultThumbnailHeight = 200;

  // Qualidade de compressão (0-100)
  static const int thumbnailQuality = 70;

  /// Obtém o diretório de cache para thumbnails
  Future<Directory> _getThumbnailCacheDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final thumbDir = Directory(path.join(appDir.path, 'thumbnails'));
    if (!await thumbDir.exists()) {
      await thumbDir.create(recursive: true);
    }
    return thumbDir;
  }

  /// Gera um nome único para o arquivo de thumbnail baseado no caminho original
  String _getThumbnailFileName(String originalPath) {
    // Usa hash do caminho para evitar colisões
    final hash = originalPath.hashCode.toRadixString(16);
    final ext = path.extension(originalPath).toLowerCase();
    return 'thumb_$hash${ext.isEmpty ? ".jpg" : ext}';
  }

  /// Obtém ou gera thumbnail para uma imagem a partir de bytes
  /// [imageBytes] - Bytes da imagem original
  /// [identifier] - Identificador único (ex: "historia_foto_123")
  Future<Uint8List?> getThumbnailFromBytes(
    Uint8List imageBytes,
    String identifier, {
    int width = defaultThumbnailWidth,
    int height = defaultThumbnailHeight,
  }) async {
    // Verifica cache em memória primeiro
    final cacheKey = '${identifier}_${width}x$height';
    if (_memoryCache.containsKey(cacheKey)) {
      return _memoryCache[cacheKey];
    }

    try {
      // Verifica cache em disco
      final thumbDir = await _getThumbnailCacheDir();
      final thumbFileName = _getThumbnailFileName(cacheKey);
      final thumbFile = File(path.join(thumbDir.path, thumbFileName));

      if (await thumbFile.exists()) {
        final cachedBytes = await thumbFile.readAsBytes();
        _memoryCache[cacheKey] = cachedBytes;
        return cachedBytes;
      }

      // Gera thumbnail
      final compressedBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        minWidth: width,
        minHeight: height,
        quality: thumbnailQuality,
        format: CompressFormat.jpeg,
      );

      // Salva em disco
      await thumbFile.writeAsBytes(compressedBytes);

      // Adiciona ao cache em memória
      _memoryCache[cacheKey] = compressedBytes;

      return compressedBytes;
    } catch (e) {
      // Em caso de erro, retorna imagem original
      return imageBytes;
    }
  }

  /// Obtém ou gera thumbnail para uma imagem a partir de arquivo
  /// [imagePath] - Caminho do arquivo de imagem
  Future<Uint8List?> getThumbnailFromFile(
    String imagePath, {
    int width = defaultThumbnailWidth,
    int height = defaultThumbnailHeight,
  }) async {
    // Verifica cache em memória primeiro
    final cacheKey = '${imagePath}_${width}x$height';
    if (_memoryCache.containsKey(cacheKey)) {
      return _memoryCache[cacheKey];
    }

    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return null;
      }

      // Verifica cache em disco
      final thumbDir = await _getThumbnailCacheDir();
      final thumbFileName = _getThumbnailFileName(cacheKey);
      final thumbFile = File(path.join(thumbDir.path, thumbFileName));

      if (await thumbFile.exists()) {
        // Verifica se o cache não está obsoleto (arquivo original modificado)
        final originalStat = await file.stat();
        final thumbStat = await thumbFile.stat();
        if (thumbStat.modified.isAfter(originalStat.modified)) {
          final cachedBytes = await thumbFile.readAsBytes();
          _memoryCache[cacheKey] = cachedBytes;
          return cachedBytes;
        }
      }

      // Gera thumbnail usando compressão direta do arquivo
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imagePath,
        thumbFile.path,
        minWidth: width,
        minHeight: height,
        quality: thumbnailQuality,
        format: CompressFormat.jpeg,
      );

      if (compressedFile != null) {
        final compressedBytes = await compressedFile.readAsBytes();
        _memoryCache[cacheKey] = compressedBytes;
        return compressedBytes;
      }

      return null;
    } catch (e) {
      // Em caso de erro, tenta ler o arquivo original
      try {
        final file = File(imagePath);
        return await file.readAsBytes();
      } catch (fallbackError) {
        debugPrint(
          'ThumbnailService: erro no fallback de leitura da imagem "$imagePath": $fallbackError',
        );
        return null;
      }
    }
  }

  /// Pré-gera thumbnails para uma lista de identificadores
  /// Útil para preparar cache antes de exibir lista
  Future<void> preloadThumbnails(
    List<MapEntry<String, Uint8List>> images, {
    int width = defaultThumbnailWidth,
    int height = defaultThumbnailHeight,
  }) async {
    for (final entry in images) {
      await getThumbnailFromBytes(
        entry.value,
        entry.key,
        width: width,
        height: height,
      );
    }
  }

  /// Limpa cache em memória
  void clearMemoryCache() {
    _memoryCache.clear();
  }

  /// Limpa todo o cache (memória e disco)
  Future<void> clearAllCache() async {
    _memoryCache.clear();
    try {
      final thumbDir = await _getThumbnailCacheDir();
      if (await thumbDir.exists()) {
        await thumbDir.delete(recursive: true);
      }
    } catch (e) {
      // Falha de limpeza não é crítica para o fluxo principal.
      debugPrint('ThumbnailService: erro ao limpar cache de thumbnails: $e');
    }
  }

  /// Obtém tamanho do cache em disco
  Future<int> getCacheSize() async {
    try {
      final thumbDir = await _getThumbnailCacheDir();
      if (!await thumbDir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in thumbDir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      return totalSize;
    } catch (e) {
      debugPrint('ThumbnailService: erro ao calcular tamanho do cache: $e');
      return 0;
    }
  }

  /// Formata tamanho em bytes para string legível
  String formatCacheSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
