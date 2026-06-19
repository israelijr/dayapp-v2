import 'dart:typed_data';

import '../helpers/audio_file_helper.dart';
import '../models/historia_audio_v2.dart';
import 'database_helper.dart';

/// Helper para gerenciar áudios de histórias
/// Usa sistema de arquivos em vez de BLOB para melhor performance
class HistoriaAudioHelper {
  /// Insere um novo áudio a partir de bytes
  /// Salva o arquivo no sistema de arquivos e armazena apenas o caminho no banco
  Future<int> insertAudioFromBytes({
    required int historiaId,
    required Uint8List audioBytes,
    String? legenda,
    int? duracao,
  }) async {
    // 1. Salvar arquivo no sistema de arquivos
    final audioPath = await AudioFileHelper.saveAudio(audioBytes, historiaId);

    // 2. Inserir caminho no banco
    final db = await DatabaseHelper().database;
    final id = await db.insert('historia_audios', {
      'historia_id': historiaId,
      'audio_path': audioPath,
      'legenda': legenda,
      'duracao': duracao,
    });

    return id;
  }

  /// Insere um áudio usando o modelo v2 (com caminho)
  Future<int> insertAudio(HistoriaAudio audio) async {
    final db = await DatabaseHelper().database;
    return await db.insert('historia_audios', {
      'historia_id': audio.historiaId,
      'audio_path': audio.audioPath,
      'legenda': audio.legenda,
      'duracao': audio.duracao,
    });
  }

  /// Busca todos os áudios de uma história
  Future<List<HistoriaAudio>> getAudiosByHistoria(int historiaId) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'historia_audios',
      where: 'historia_id = ?',
      whereArgs: [historiaId],
    );
    return result.map((map) => HistoriaAudio.fromMap(map)).toList();
  }

  /// Lê os bytes de um áudio do sistema de arquivos
  Future<Uint8List?> readAudioBytes(String audioPath) async {
    return await AudioFileHelper.readAudio(audioPath);
  }

  /// Deleta um áudio (do banco e do sistema de arquivos)
  Future<int> deleteAudio(int id) async {
    final db = await DatabaseHelper().database;

    // 1. Buscar o caminho do arquivo
    final result = await db.query(
      'historia_audios',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      final audioPath = result.first['audio_path'] as String?;
      if (audioPath != null) {
        // 2. Deletar arquivo do sistema de arquivos
        await AudioFileHelper.deleteAudio(audioPath);
      }
    }

    // 3. Deletar registro do banco
    return await db.delete('historia_audios', where: 'id = ?', whereArgs: [id]);
  }

  /// Deleta todos os áudios de uma história
  Future<void> deleteAudiosByHistoria(int historiaId) async {
    final db = await DatabaseHelper().database;

    // 1. Buscar todos os caminhos
    final result = await db.query(
      'historia_audios',
      where: 'historia_id = ?',
      whereArgs: [historiaId],
    );

    // 2. Deletar arquivos do sistema de arquivos
    for (final audio in result) {
      final audioPath = audio['audio_path'] as String?;
      if (audioPath != null) {
        await AudioFileHelper.deleteAudio(audioPath);
      }
    }

    // 3. Deletar registros do banco
    await db.delete(
      'historia_audios',
      where: 'historia_id = ?',
      whereArgs: [historiaId],
    );
  }

  /// Obtém todos os caminhos de áudios válidos (para limpeza de órfãos)
  Future<List<String>> getAllAudioPaths() async {
    final db = await DatabaseHelper().database;
    final result = await db.query('historia_audios', columns: ['audio_path']);
    return result
        .map((row) => row['audio_path'] as String)
        .where((path) => path.isNotEmpty)
        .toList();
  }

  /// Busca áudios de uma história já com os bytes carregados
  /// Retorna lista de AudioComBytes (id, bytes, duracao, legenda)
  Future<List<AudioComBytes>> getAudiosComBytesByHistoria(
    int historiaId,
  ) async {
    final audios = await getAudiosByHistoria(historiaId);
    final List<AudioComBytes> result = [];

    for (final audio in audios) {
      final bytes = await readAudioBytes(audio.audioPath);
      if (bytes != null) {
        result.add(
          AudioComBytes(
            id: audio.id ?? 0,
            bytes: bytes,
            duracao: audio.duracao,
            legenda: audio.legenda,
            audioPath: audio.audioPath,
          ),
        );
      }
    }

    return result;
  }
}

/// Classe auxiliar para representar um áudio com seus bytes carregados
class AudioComBytes {
  final int id;
  final Uint8List bytes;
  final int? duracao;
  final String? legenda;
  final String audioPath;

  AudioComBytes({
    required this.id,
    required this.bytes,
    required this.audioPath,
    this.duracao,
    this.legenda,
  });
}
