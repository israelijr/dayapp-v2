import 'dart:typed_data';

import '../helpers/photo_file_helper.dart';
import '../models/historia_foto_v2.dart';
import 'database_helper.dart';

/// Helper para gerenciar fotos de histórias
/// Usa sistema de arquivos em vez de BLOB para melhor performance
class HistoriaFotoHelper {
  /// Insere uma nova foto a partir de bytes
  /// Salva o arquivo no sistema de arquivos e armazena apenas o caminho no banco
  Future<int> insertFotoFromBytes({
    required int historiaId,
    required Uint8List fotoBytes,
    String? legenda,
  }) async {
    // 1. Salvar arquivo no sistema de arquivos
    final fotoPath = await PhotoFileHelper.savePhoto(fotoBytes, historiaId);

    // 2. Inserir caminho no banco
    final db = await DatabaseHelper().database;
    final id = await db.insert('historia_fotos', {
      'historia_id': historiaId,
      'foto_path': fotoPath,
      'legenda': legenda,
    });

    return id;
  }

  /// Insere uma foto usando o modelo v2 (com caminho)
  Future<int> insertFoto(HistoriaFoto foto) async {
    final db = await DatabaseHelper().database;
    return await db.insert('historia_fotos', {
      'historia_id': foto.historiaId,
      'foto_path': foto.fotoPath,
      'legenda': foto.legenda,
    });
  }

  /// Busca todas as fotos de uma história
  Future<List<HistoriaFoto>> getFotosByHistoria(int historiaId) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'historia_fotos',
      where: 'historia_id = ?',
      whereArgs: [historiaId],
    );
    return result.map((map) => HistoriaFoto.fromMap(map)).toList();
  }

  /// Lê os bytes de uma foto do sistema de arquivos
  Future<Uint8List?> readFotoBytes(String fotoPath) async {
    return await PhotoFileHelper.readPhoto(fotoPath);
  }

  /// Deleta uma foto (do banco e do sistema de arquivos)
  Future<int> deleteFoto(int id) async {
    final db = await DatabaseHelper().database;

    // 1. Buscar o caminho do arquivo
    final result = await db.query(
      'historia_fotos',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      final fotoPath = result.first['foto_path'] as String?;
      if (fotoPath != null) {
        // 2. Deletar arquivo do sistema de arquivos
        await PhotoFileHelper.deletePhoto(fotoPath);
      }
    }

    // 3. Deletar registro do banco
    return await db.delete('historia_fotos', where: 'id = ?', whereArgs: [id]);
  }

  /// Deleta todas as fotos de uma história
  Future<void> deleteFotosByHistoria(int historiaId) async {
    final db = await DatabaseHelper().database;

    // 1. Buscar todos os caminhos
    final result = await db.query(
      'historia_fotos',
      where: 'historia_id = ?',
      whereArgs: [historiaId],
    );

    // 2. Deletar arquivos do sistema de arquivos
    for (final foto in result) {
      final fotoPath = foto['foto_path'] as String?;
      if (fotoPath != null) {
        await PhotoFileHelper.deletePhoto(fotoPath);
      }
    }

    // 3. Deletar registros do banco
    await db.delete(
      'historia_fotos',
      where: 'historia_id = ?',
      whereArgs: [historiaId],
    );
  }

  /// Obtém todos os caminhos de fotos válidos (para limpeza de órfãos)
  Future<List<String>> getAllFotoPaths() async {
    final db = await DatabaseHelper().database;
    final result = await db.query('historia_fotos', columns: ['foto_path']);
    return result
        .map((row) => row['foto_path'] as String)
        .where((path) => path.isNotEmpty)
        .toList();
  }

  /// Busca fotos de uma história já com os bytes carregados
  /// Retorna lista de FotoComBytes (id, bytes, legenda)
  Future<List<FotoComBytes>> getFotosComBytesByHistoria(int historiaId) async {
    final fotos = await getFotosByHistoria(historiaId);
    final List<FotoComBytes> result = [];

    for (final foto in fotos) {
      final bytes = await readFotoBytes(foto.fotoPath);
      if (bytes != null) {
        result.add(
          FotoComBytes(
            id: foto.id ?? 0,
            bytes: bytes,
            legenda: foto.legenda,
            fotoPath: foto.fotoPath,
          ),
        );
      }
    }

    return result;
  }
}

/// Classe auxiliar para representar uma foto com seus bytes carregados
class FotoComBytes {
  final int id;
  final Uint8List bytes;
  final String? legenda;
  final String fotoPath;

  FotoComBytes({
    required this.id,
    required this.bytes,
    required this.fotoPath,
    this.legenda,
  });
}
