import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';

import '../db/database_helper.dart';
import '../db/historia_audio_helper.dart';
import '../db/historia_foto_helper.dart';
import '../db/historia_video_helper.dart';
import '../db/pessoa_helper.dart';
import '../db/tag_helper.dart';
import '../models/historia.dart';
import '../models/pessoa.dart';
import '../models/tag.dart';

class HistoriaRepository {
  static const String _table = 'historia';
  static const int _fallbackMinStories = 5;

  Future<int> countPendingBackupStories() async {
    final db = await DatabaseHelper().database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM $_table WHERE (backed_up IS NULL OR backed_up = 0) AND excluido IS NULL',
    );
    return (result.first['cnt'] ?? 0) as int;
  }

  Future<List<Historia>> fetchUserStoriesPaginated({
    required String userId,
    required bool showAllStories,
    required int limit,
    required int offset,
  }) async {
    final db = await DatabaseHelper().database;
    final activeWhereClause = showAllStories
        ? 'user_id = ? AND excluido IS NULL'
        : 'user_id = ? AND grupo IS NULL AND arquivado IS NULL AND excluido IS NULL';

    final countResult = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM $_table WHERE $activeWhereClause',
      [userId],
    );
    final availableCount = (countResult.first['cnt'] ?? 0) as int;

    final queryLimit = showAllStories || availableCount > _fallbackMinStories
        ? limit
        : _fallbackMinStories;

    if (!showAllStories &&
        offset > 0 &&
        availableCount <= _fallbackMinStories) {
      return const [];
    }

    final activeResults = await db.query(
      _table,
      where: activeWhereClause,
      whereArgs: [userId],
      orderBy: 'data DESC',
      limit: queryLimit,
      offset: offset,
    );

    final activeHistorias = activeResults
        .map((map) => Historia.fromMap(map))
        .toList(growable: false);

    if (showAllStories || availableCount > _fallbackMinStories) {
      return activeHistorias;
    }

    if (offset > 0) {
      return const [];
    }

    final remaining = _fallbackMinStories - activeHistorias.length;
    if (remaining <= 0) {
      return activeHistorias;
    }

    final otherResults = await db.query(
      _table,
      where:
          'user_id = ? AND excluido IS NULL AND (grupo IS NOT NULL OR arquivado IS NOT NULL)',
      whereArgs: [userId],
      orderBy: 'data DESC',
      limit: remaining,
    );

    final otherHistorias = otherResults
        .map((map) => Historia.fromMap(map))
        .toList(growable: false);

    final combined = [...activeHistorias, ...otherHistorias]
      ..sort((a, b) => b.data.compareTo(a.data));
    return combined;
  }

  Future<List<Historia>> fetchUserStories({
    required String userId,
    bool excludeDeleted = true,
  }) async {
    final db = await DatabaseHelper().database;
    final whereClause = excludeDeleted
        ? 'user_id = ? AND excluido IS NULL'
        : 'user_id = ?';
    final results = await db.query(
      _table,
      where: whereClause,
      whereArgs: [userId],
      orderBy: 'data DESC',
    );
    return results.map((map) => Historia.fromMap(map)).toList(growable: false);
  }

  Future<List<Historia>> searchUserStoriesByText({
    required String userId,
    required String query,
  }) async {
    final db = await DatabaseHelper().database;
    final results = await db.query(
      _table,
      distinct: true,
      where:
          'user_id = ? AND excluido IS NULL AND (titulo LIKE ? OR descricao LIKE ?)',
      whereArgs: [userId, '%$query%', '%$query%'],
      orderBy: 'data DESC',
    );
    return results.map((map) => Historia.fromMap(map)).toList(growable: false);
  }

  Future<List<Historia>> searchUserStoriesByTag({
    required String userId,
    required String tag,
  }) async {
    final db = await DatabaseHelper().database;
    final slug = Tag.generateSlug(tag);
    final results = await db.rawQuery(
      '''
      SELECT DISTINCT h.*
      FROM $_table h
      INNER JOIN historia_tags ht ON ht.historia_id = h.id
      INNER JOIN tags t ON t.id = ht.tag_id
      WHERE h.user_id = ? AND h.excluido IS NULL
        AND (t.slug LIKE ? OR t.nome LIKE ?)
      ORDER BY h.data DESC
      ''',
      [userId, '%$slug%', '%$tag%'],
    );
    return results.map((map) => Historia.fromMap(map)).toList(growable: false);
  }

  Future<List<Historia>> searchUserStoriesByEmoticon({
    required String userId,
    required String emoticon,
  }) async {
    final db = await DatabaseHelper().database;
    final results = await db.query(
      _table,
      where: 'user_id = ? AND excluido IS NULL AND emoticon = ?',
      whereArgs: [userId, emoticon],
      orderBy: 'data DESC',
    );
    return results.map((map) => Historia.fromMap(map)).toList(growable: false);
  }

  Future<List<Historia>> searchUserStoriesByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await DatabaseHelper().database;
    final startStr = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0).toIso8601String();
    final endStr = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999).toIso8601String();

    final results = await db.query(
      _table,
      where: 'user_id = ? AND excluido IS NULL AND data >= ? AND data <= ?',
      whereArgs: [userId, startStr, endStr],
      orderBy: 'data DESC',
    );
    return results.map((map) => Historia.fromMap(map)).toList(growable: false);
  }

  Future<List<String>> fetchTagNamesForStory(int historiaId) async {
    final db = await DatabaseHelper().database;
    final rows = await db.rawQuery(
      '''
      SELECT t.nome
      FROM historia_tags ht
      JOIN tags t ON t.id = ht.tag_id
      WHERE ht.historia_id = ?
      ORDER BY t.nome ASC
      ''',
      [historiaId],
    );
    return rows.map((row) => row['nome'] as String).toList(growable: false);
  }

  Future<List<String>> fetchPessoaNamesForStory(int historiaId) async {
    final db = await DatabaseHelper().database;
    final rows = await db.rawQuery(
      '''
      SELECT p.nome
      FROM historia_pessoas hp
      JOIN pessoas p ON p.id = hp.pessoa_id
      WHERE hp.historia_id = ?
      ORDER BY p.nome ASC
      ''',
      [historiaId],
    );
    return rows.map((row) => row['nome'] as String).toList(growable: false);
  }

  Future<({int fotos, int audios, int videos})> fetchAttachmentCounts(
    int historiaId,
  ) async {
    final db = await DatabaseHelper().database;
    final fotoCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM historia_fotos WHERE historia_id = ?',
            [historiaId],
          ),
        ) ??
        0;
    final audioCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM historia_audios WHERE historia_id = ?',
            [historiaId],
          ),
        ) ??
        0;
    final videoCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM historia_videos WHERE historia_id = ?',
            [historiaId],
          ),
        ) ??
        0;

    return (fotos: fotoCount, audios: audioCount, videos: videoCount);
  }

  Future<void> updateHistoria(
    Historia historia, {
    Map<String, dynamic>? updates,
  }) async {
    if (historia.id == null) return;

    final db = await DatabaseHelper().database;
    final updateData = <String, dynamic>{
      'data_update': DateTime.now().toIso8601String(),
      ...?updates,
    };

    if (!updateData.containsKey('backed_up')) {
      updateData['backed_up'] = 0;
    }

    await db.update(
      _table,
      updateData,
      where: 'id = ?',
      whereArgs: [historia.id],
    );
  }

  Future<void> markAllStoriesBackedUp({bool excludeDeleted = true}) async {
    final db = await DatabaseHelper().database;
    if (excludeDeleted) {
      await db.update(_table, {'backed_up': 1}, where: 'excluido IS NULL');
    } else {
      await db.update(_table, {'backed_up': 1});
    }
  }

  Future<int> countStories({String? where, List<Object?>? whereArgs}) async {
    final db = await DatabaseHelper().database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM $_table${where != null ? ' WHERE $where' : ''}',
      whereArgs,
    );
    return (result.first['cnt'] ?? 0) as int;
  }

  Future<bool> saveEditedHistoria({
    required Historia historia,
    required String titulo,
    required DateTime data,
    required int humor,
    required int energia,
    required int continua,
    String? descricao,
    String? emoticon,
    String? arquivado,
    String? local,
    List<Tag>? tags,
    List<Pessoa>? pessoas,
    List<Uint8List>? newFotos,
    List<Map<String, dynamic>>? newAudios,
    List<Map<String, dynamic>>? newVideos,
  }) async {
    if (historia.id == null) return false;

    final db = await DatabaseHelper().database;
    await db.update(
      _table,
      {
        'titulo': titulo,
        'descricao': descricao,
        'tag': null,
        'emoticon': emoticon,
        'data': data.toIso8601String(),
        'data_update': DateTime.now().toIso8601String(),
        'arquivado': arquivado,
        'backed_up': 0,
        'humor': humor,
        'energia': energia,
        'local': local,
        'continua': continua,
      },
      where: 'id = ?',
      whereArgs: [historia.id],
    );

    if (tags != null) {
      await TagHelper().setTagsForHistoria(historia.id!, tags, db);
    }

    if (pessoas != null) {
      await PessoaHelper().setPessoasForHistoria(historia.id!, pessoas, db);
    }

    if (newFotos != null && newFotos.isNotEmpty) {
      for (final foto in newFotos) {
        await HistoriaFotoHelper().insertFotoFromBytes(
          historiaId: historia.id!,
          fotoBytes: foto,
        );
      }
    }

    if (newAudios != null && newAudios.isNotEmpty) {
      for (final audioData in newAudios) {
        await HistoriaAudioHelper().insertAudioFromBytes(
          historiaId: historia.id!,
          audioBytes: audioData['audio'],
          duracao: audioData['duration'],
        );
      }
    }

    if (newVideos != null && newVideos.isNotEmpty) {
      for (final videoData in newVideos) {
        await HistoriaVideoHelper().insertVideoFromBytes(
          historiaId: historia.id!,
          videoBytes: videoData['video'],
          duracao: videoData['duration'],
        );
      }
    }

    return true;
  }

  Future<int> createHistoria({
    required String userId,
    required String titulo,
    required DateTime data,
    required int humor,
    required int energia,
    int continua = 1,
    String? descricao,
    String? emoticon,
    String? grupo,
    String? arquivado,
    String? local,
    DateTime? dataCriacao,
    List<Tag>? tags,
    List<Pessoa>? pessoas,
    List<Uint8List>? fotos,
    List<Map<String, dynamic>>? audios,
    List<Map<String, dynamic>>? videos,
  }) async {
    final db = await DatabaseHelper().database;
    final historiaId = await db.insert(_table, {
      'user_id': userId,
      'titulo': titulo,
      'descricao': descricao,
      'tag': null,
      'grupo': grupo,
      'arquivado': arquivado,
      'emoticon': emoticon,
      'data': data.toIso8601String(),
      'data_criacao': (dataCriacao ?? DateTime.now()).toIso8601String(),
      'data_update': DateTime.now().toIso8601String(),
      'humor': humor,
      'energia': energia,
      'local': local,
      'continua': continua,
      'backed_up': 0,
    });

    if (tags != null && tags.isNotEmpty) {
      await TagHelper().setTagsForHistoria(historiaId, tags, db);
    }

    if (pessoas != null && pessoas.isNotEmpty) {
      await PessoaHelper().setPessoasForHistoria(historiaId, pessoas, db);
    }

    if (fotos != null && fotos.isNotEmpty) {
      for (final foto in fotos) {
        await HistoriaFotoHelper().insertFotoFromBytes(
          historiaId: historiaId,
          fotoBytes: foto,
        );
      }
    }

    if (audios != null && audios.isNotEmpty) {
      for (final audioData in audios) {
        await HistoriaAudioHelper().insertAudioFromBytes(
          historiaId: historiaId,
          audioBytes: audioData['audio'],
          duracao: audioData['duration'],
        );
      }
    }

    if (videos != null && videos.isNotEmpty) {
      for (final videoData in videos) {
        await HistoriaVideoHelper().insertVideoFromBytes(
          historiaId: historiaId,
          videoBytes: videoData['video'],
          duracao: videoData['duration'],
        );
      }
    }

    return historiaId;
  }

  Future<List<Historia>> fetchArchivedStories({required String userId}) async {
    final db = await DatabaseHelper().database;
    final rows = await db.query(
      _table,
      where: 'user_id = ? AND arquivado = ? AND excluido IS NULL',
      whereArgs: [userId, 'sim'],
      orderBy: 'data DESC',
    );
    return rows.map((map) => Historia.fromMap(map)).toList(growable: false);
  }

  Future<List<Historia>> fetchDeletedStories({required String userId}) async {
    final db = await DatabaseHelper().database;
    final rows = await db.query(
      _table,
      where: 'user_id = ? AND excluido = ?',
      whereArgs: [userId, 'sim'],
      orderBy: 'data_exclusao DESC',
    );
    return rows.map((map) => Historia.fromMap(map)).toList(growable: false);
  }

  Future<void> restoreHistoria(Historia historia) async {
    if (historia.id == null) return;

    await updateHistoria(
      historia,
      updates: {
        'excluido': null,
        'data_exclusao': null,
        'data_update': DateTime.now().toIso8601String(),
        'backed_up': 0,
      },
    );
  }

  Future<void> deleteHistoriaPermanently(Historia historia) async {
    if (historia.id == null) return;

    final db = await DatabaseHelper().database;
    await db.delete(_table, where: 'id = ?', whereArgs: [historia.id]);
  }

  Future<void> deleteStoriesPermanentlyByUser(String userId) async {
    final db = await DatabaseHelper().database;
    await db.delete(
      _table,
      where: 'user_id = ? AND excluido = ?',
      whereArgs: [userId, 'sim'],
    );
  }

  Future<void> archiveHistoria(Historia historia) async {
    if (historia.id == null) return;

    await updateHistoria(
      historia,
      updates: {'arquivado': 'sim', 'grupo': null},
    );
  }

  Future<void> deleteHistoria(Historia historia) async {
    if (historia.id == null) return;

    final updateData = {
      'excluido': 'sim',
      'data_exclusao': DateTime.now().toIso8601String(),
      'backed_up': 0,
    };

    await updateHistoria(historia, updates: updateData);
  }
}
