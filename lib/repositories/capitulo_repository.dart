import 'package:sqflite/sqflite.dart';

import '../db/database_helper.dart';
import '../domain/chapter_export_document.dart';
import '../models/capitulo.dart';
import '../models/historia.dart';
import '../models/historia_foto_v2.dart';
import '../services/chapter_document_builder.dart';

class CapituloRepository {
  final ChapterDocumentBuilder _chapterDocumentBuilder;

  CapituloRepository({
    ChapterDocumentBuilder chapterDocumentBuilder =
        const ChapterDocumentBuilder(),
  }) : _chapterDocumentBuilder = chapterDocumentBuilder;

  Future<void> _markEntradasAsPendingBackup(
    DatabaseExecutor db,
    Iterable<int> entradaIds,
  ) async {
    final ids = entradaIds.toSet().toList(growable: false);
    if (ids.isEmpty) return;

    final placeholders = List.filled(ids.length, '?').join(', ');
    await db.rawUpdate(
      'UPDATE historia SET backed_up = 0, data_update = ? WHERE id IN ($placeholders)',
      [DateTime.now().toIso8601String(), ...ids],
    );
  }

  Future<int> insertCapituloWithEntradas(
    Capitulo capitulo,
    List<int> entradaIds,
  ) async {
    final db = await DatabaseHelper().database;
    return db.transaction((txn) async {
      final uniqueEntradaIds = entradaIds.toSet().toList(growable: false);

      final capituloId = await txn.insert('capitulos', {
        ...capitulo.toMap(),
        'data_update': DateTime.now().toIso8601String(),
      });

      var order = 1;
      for (final entradaId in uniqueEntradaIds) {
        await txn.insert('capitulo_entradas', {
          'capitulo_id': capituloId,
          'entrada_id': entradaId,
          'display_order': order,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        order += 1;
      }

      await _markEntradasAsPendingBackup(txn, uniqueEntradaIds);
      return capituloId;
    });
  }

  Future<void> updateCapituloWithEntradas(
    Capitulo capitulo,
    List<int> entradaIds,
  ) async {
    final db = await DatabaseHelper().database;
    await db.transaction((txn) async {
      final uniqueEntradaIds = entradaIds.toSet().toList(growable: false);

      final previousEntradasRows = await txn.query(
        'capitulo_entradas',
        columns: ['entrada_id'],
        where: 'capitulo_id = ?',
        whereArgs: [capitulo.id],
      );
      final previousEntradaIds = previousEntradasRows
          .map((row) => row['entrada_id'] as int)
          .toSet();

      await txn.update(
        'capitulos',
        {...capitulo.toMap(), 'data_update': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [capitulo.id],
      );

      await txn.delete(
        'capitulo_entradas',
        where: 'capitulo_id = ?',
        whereArgs: [capitulo.id],
      );

      var order = 1;
      for (final entradaId in uniqueEntradaIds) {
        await txn.insert('capitulo_entradas', {
          'capitulo_id': capitulo.id,
          'entrada_id': entradaId,
          'display_order': order,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        order += 1;
      }

      await _markEntradasAsPendingBackup(txn, {
        ...previousEntradaIds,
        ...uniqueEntradaIds,
      });
    });
  }

  Future<void> deleteCapitulo(int capituloId) async {
    final db = await DatabaseHelper().database;
    await db.transaction((txn) async {
      final entradasRows = await txn.query(
        'capitulo_entradas',
        columns: ['entrada_id'],
        where: 'capitulo_id = ?',
        whereArgs: [capituloId],
      );
      final entradaIds = entradasRows
          .map((row) => row['entrada_id'] as int)
          .toList(growable: false);

      await txn.delete('capitulos', where: 'id = ?', whereArgs: [capituloId]);
      await _markEntradasAsPendingBackup(txn, entradaIds);
    });
  }

  Future<List<CapituloResumo>> fetchCapitulosResumoByUser(String userId) async {
    final db = await DatabaseHelper().database;
    final rows = await db.rawQuery(
      '''
      SELECT
        c.*,
        COUNT(ce.entrada_id) AS total_entradas,
        COALESCE(AVG(h.humor), 3.0) AS humor_medio
      FROM capitulos c
      LEFT JOIN capitulo_entradas ce ON ce.capitulo_id = c.id
      LEFT JOIN historia h ON h.id = ce.entrada_id
      WHERE c.user_id = ?
      GROUP BY c.id
      ORDER BY c.data_inicio DESC
      ''',
      [userId],
    );

    final result = <CapituloResumo>[];
    for (final row in rows) {
      final capitulo = Capitulo.fromMap(row);
      final topTagsRows = await db.rawQuery(
        '''
        SELECT t.nome, COUNT(*) as total
        FROM capitulo_entradas ce
        JOIN historia_tags ht ON ht.historia_id = ce.entrada_id
        JOIN tags t ON t.id = ht.tag_id
        WHERE ce.capitulo_id = ?
        GROUP BY t.id, t.nome
        ORDER BY total DESC, t.nome ASC
        LIMIT 3
        ''',
        [capitulo.id],
      );

      result.add(
        CapituloResumo(
          capitulo: capitulo,
          totalEntradas: (row['total_entradas'] as int?) ?? 0,
          humorMedio: (row['humor_medio'] as num?)?.toDouble() ?? 3.0,
          topTags: topTagsRows
              .map((tagRow) => tagRow['nome'] as String)
              .toList(growable: false),
        ),
      );
    }

    return result;
  }

  Future<List<Historia>> getEntradasByCapitulo(int capituloId) async {
    final db = await DatabaseHelper().database;
    final rows = await db.rawQuery(
      '''
      SELECT h.*
      FROM capitulo_entradas ce
      JOIN historia h ON h.id = ce.entrada_id
      WHERE ce.capitulo_id = ?
        AND h.excluido IS NULL
      ORDER BY
        CASE WHEN ce.display_order IS NULL THEN 1 ELSE 0 END ASC,
        ce.display_order ASC,
        h.data ASC,
        h.id ASC
      ''',
      [capituloId],
    );
    return rows.map((row) => Historia.fromMap(row)).toList(growable: false);
  }

  Future<List<({Historia historia, String tagNomes})>>
  listEntradasElegiveisComTags(String userId) async {
    final db = await DatabaseHelper().database;
    final rows = await db.rawQuery(
      '''
      SELECT
        h.id, h.user_id, h.assunto, h.titulo, h.data, h.tag, h.grupo,
        h.arquivado, h.excluido, h.data_exclusao, h.descricao, h.sentimento,
        h.emoticon, h.data_criacao, h.data_update, h.foto_historia,
        h.backed_up, h.humor, h.energia,
        COALESCE(GROUP_CONCAT(DISTINCT LOWER(t.nome)), '') AS tag_nomes,
        COALESCE(GROUP_CONCAT(DISTINCT t.slug), '') AS tag_slugs
      FROM historia h
      LEFT JOIN historia_tags ht ON ht.historia_id = h.id
      LEFT JOIN tags t ON t.id = ht.tag_id
      WHERE h.user_id = ? AND h.excluido IS NULL
      GROUP BY h.id
      ORDER BY h.data DESC
      ''',
      [userId],
    );

    return rows
        .map((row) {
          final tagNomes = row['tag_nomes'] as String? ?? '';
          final tagSlugs = row['tag_slugs'] as String? ?? '';
          final tagNomesCompleto = '$tagNomes,$tagSlugs';
          return (historia: Historia.fromMap(row), tagNomes: tagNomesCompleto);
        })
        .toList(growable: false);
  }

  Future<void> ignoreSuggestion({
    required String userId,
    required String fingerprint,
  }) async {
    final db = await DatabaseHelper().database;
    await db.insert('capitulo_sugestoes_ignoradas', {
      'user_id': userId,
      'fingerprint': fingerprint,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<Set<String>> getIgnoredSuggestionFingerprints(String userId) async {
    final db = await DatabaseHelper().database;
    final rows = await db.query(
      'capitulo_sugestoes_ignoradas',
      columns: ['fingerprint'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return rows.map((row) => row['fingerprint'] as String).toSet();
  }

  Future<Set<int>> getEntradasJaVinculadas(String userId) async {
    final db = await DatabaseHelper().database;
    final rows = await db.rawQuery(
      '''
      SELECT DISTINCT ce.entrada_id
      FROM capitulo_entradas ce
      JOIN capitulos c ON c.id = ce.capitulo_id
      WHERE c.user_id = ?
      ''',
      [userId],
    );

    return rows.map((row) => row['entrada_id'] as int).toSet();
  }

  Future<void> updateChapterEntriesOrder({
    required int capituloId,
    required List<int> orderedEntryIds,
  }) async {
    final db = await DatabaseHelper().database;

    await db.transaction((txn) async {
      final existingRows = await txn.query(
        'capitulo_entradas',
        columns: ['entrada_id'],
        where: 'capitulo_id = ?',
        whereArgs: [capituloId],
      );

      final existingIds = existingRows
          .map((row) => row['entrada_id'] as int)
          .toSet();
      if (existingIds.isEmpty) {
        return;
      }

      final uniqueOrderedIds = <int>[];
      for (final entryId in orderedEntryIds) {
        if (!existingIds.contains(entryId) ||
            uniqueOrderedIds.contains(entryId)) {
          continue;
        }
        uniqueOrderedIds.add(entryId);
      }

      final missingIds = existingIds.where(
        (entryId) => !uniqueOrderedIds.contains(entryId),
      );
      uniqueOrderedIds.addAll(missingIds);

      var order = 1;
      for (final entryId in uniqueOrderedIds) {
        await txn.update(
          'capitulo_entradas',
          {'display_order': order},
          where: 'capitulo_id = ? AND entrada_id = ?',
          whereArgs: [capituloId, entryId],
        );
        order += 1;
      }

      await _markEntradasAsPendingBackup(txn, uniqueOrderedIds);
    });
  }

  Future<ChapterExportDocument?> fetchChapterExportDocument(
    int capituloId,
  ) async {
    final db = await DatabaseHelper().database;

    final chapterRows = await db.query(
      'capitulos',
      where: 'id = ?',
      whereArgs: [capituloId],
      limit: 1,
    );

    if (chapterRows.isEmpty) {
      return null;
    }

    final chapter = Capitulo.fromMap(chapterRows.first);
    final stories = await getEntradasByCapitulo(capituloId);

    final storyIds = stories
        .map((story) => story.id)
        .whereType<int>()
        .toList(growable: false);

    final photosByStoryId = await _fetchPhotosByStoryId(db, storyIds);
    final displayOrderByStoryId = await _fetchDisplayOrderByStoryId(
      db,
      capituloId,
    );

    return _chapterDocumentBuilder.build(
      chapter: chapter,
      stories: stories,
      photosByStoryId: photosByStoryId,
      displayOrderByStoryId: displayOrderByStoryId,
    );
  }

  Future<Map<int, int>> _fetchDisplayOrderByStoryId(
    Database db,
    int capituloId,
  ) async {
    final rows = await db.query(
      'capitulo_entradas',
      columns: ['entrada_id', 'display_order'],
      where: 'capitulo_id = ? AND display_order IS NOT NULL',
      whereArgs: [capituloId],
    );

    final map = <int, int>{};
    for (final row in rows) {
      final storyId = row['entrada_id'] as int?;
      final displayOrder = row['display_order'] as int?;
      if (storyId != null && displayOrder != null) {
        map[storyId] = displayOrder;
      }
    }

    return map;
  }

  Future<Map<int, List<HistoriaFoto>>> _fetchPhotosByStoryId(
    Database db,
    List<int> storyIds,
  ) async {
    if (storyIds.isEmpty) {
      return const {};
    }

    final placeholders = List.filled(storyIds.length, '?').join(', ');
    final rows = await db.query(
      'historia_fotos',
      where: 'historia_id IN ($placeholders)',
      whereArgs: storyIds,
      orderBy: 'id ASC',
    );

    final photosByStoryId = <int, List<HistoriaFoto>>{};
    for (final row in rows) {
      final photo = HistoriaFoto.fromMap(row);
      photosByStoryId.putIfAbsent(photo.historiaId, () => <HistoriaFoto>[]);
      photosByStoryId[photo.historiaId]!.add(photo);
    }

    return photosByStoryId;
  }
}
