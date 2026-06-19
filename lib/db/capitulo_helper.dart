import 'package:sqflite/sqflite.dart';

import '../models/capitulo.dart';
import '../models/historia.dart';
import 'database_helper.dart';

class CapituloHelper {
  Future<int> insertCapituloWithEntradas(
    Capitulo capitulo,
    List<int> entradaIds,
  ) async {
    final db = await DatabaseHelper().database;
    return db.transaction((txn) async {
      final capituloId = await txn.insert('capitulos', {
        ...capitulo.toMap(),
        'data_update': DateTime.now().toIso8601String(),
      });

      var order = 1;
      for (final entradaId in entradaIds.toSet()) {
        await txn.insert('capitulo_entradas', {
          'capitulo_id': capituloId,
          'entrada_id': entradaId,
          'display_order': order,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        order += 1;
      }
      return capituloId;
    });
  }

  Future<void> updateCapituloWithEntradas(
    Capitulo capitulo,
    List<int> entradaIds,
  ) async {
    final db = await DatabaseHelper().database;
    await db.transaction((txn) async {
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
      for (final entradaId in entradaIds.toSet()) {
        await txn.insert('capitulo_entradas', {
          'capitulo_id': capitulo.id,
          'entrada_id': entradaId,
          'display_order': order,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        order += 1;
      }
    });
  }

  Future<List<CapituloResumo>> getCapitulosResumoByUser(String userId) async {
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

  Future<void> deleteCapitulo(int capituloId) async {
    final db = await DatabaseHelper().database;
    await db.delete('capitulos', where: 'id = ?', whereArgs: [capituloId]);
  }

  Future<List<Historia>> listEntradasElegiveis(String userId) async {
    final db = await DatabaseHelper().database;
    final rows = await db.query(
      'historia',
      where: 'user_id = ? AND excluido IS NULL',
      whereArgs: [userId],
      orderBy: 'data DESC',
      columns: [
        'id',
        'user_id',
        'assunto',
        'titulo',
        'data',
        'tag',
        'grupo',
        'arquivado',
        'excluido',
        'data_exclusao',
        'descricao',
        'sentimento',
        'emoticon',
        'data_criacao',
        'data_update',
        'foto_historia',
        'backed_up',
        'humor',
        'energia',
      ],
    );

    return rows.map((row) => Historia.fromMap(row)).toList(growable: false);
  }

  /// Mesmo que [listEntradasElegiveis], mas inclui os nomes e slugs das tags
  /// de cada entrada (via LEFT JOIN) para permitir filtragem por tag em memória.
  ///
  /// Retorna uma lista de registros com [historia] e [tagNomes] — uma string
  /// com todos os nomes de tags separados por vírgula (pode ser vazia).
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
          // Combina nome e slug para cobrir buscas com ou sem acento
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

  Future<void> updateEntradasOrder({
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
    });
  }

  Future<void> addEntradaToCapitulo({
    required int capituloId,
    required int entradaId,
  }) async {
    final db = await DatabaseHelper().database;
    await db.transaction((txn) async {
      final nextOrderRows = await txn.rawQuery(
        '''
        SELECT COALESCE(MAX(display_order), 0) + 1 AS next_order
        FROM capitulo_entradas
        WHERE capitulo_id = ?
        ''',
        [capituloId],
      );
      final nextOrder = (nextOrderRows.first['next_order'] as int? ?? 1).clamp(
        1,
        1 << 30,
      );

      await txn.insert('capitulo_entradas', {
        'capitulo_id': capituloId,
        'entrada_id': entradaId,
        'display_order': nextOrder,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      final rows = await txn.rawQuery(
        '''
        SELECT
          MIN(h.data) AS data_inicio,
          MAX(h.data) AS data_fim
        FROM capitulo_entradas ce
        JOIN historia h ON h.id = ce.entrada_id
        WHERE ce.capitulo_id = ?
        ''',
        [capituloId],
      );

      if (rows.isNotEmpty) {
        final row = rows.first;
        final dataInicio = row['data_inicio'] as String?;
        final dataFim = row['data_fim'] as String?;
        if (dataInicio != null && dataFim != null) {
          await txn.update(
            'capitulos',
            {
              'data_inicio': dataInicio,
              'data_fim': dataFim,
              'data_update': DateTime.now().toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [capituloId],
          );
        }
      }
    });
  }

  Future<List<Historia>> getHistoriasByIds(List<int> ids) async {
    if (ids.isEmpty) return const [];

    final db = await DatabaseHelper().database;
    final placeholders = List.filled(ids.length, '?').join(', ');
    final rows = await db.query(
      'historia',
      where: 'id IN ($placeholders) AND excluido IS NULL',
      whereArgs: ids,
      orderBy: 'data ASC',
      columns: [
        'id',
        'user_id',
        'assunto',
        'titulo',
        'data',
        'tag',
        'grupo',
        'arquivado',
        'excluido',
        'data_exclusao',
        'descricao',
        'sentimento',
        'emoticon',
        'data_criacao',
        'data_update',
        'foto_historia',
        'backed_up',
        'humor',
        'energia',
      ],
    );

    return rows.map((row) => Historia.fromMap(row)).toList(growable: false);
  }

  /// Retorna contagens de fotos, áudios e vídeos por historia para um capítulo.
  /// Chave: historia_id, valor: contagens de anexos.
  Future<Map<int, ({int fotos, int audios, int videos})>>
  getAttachmentCountsByCapitulo(int capituloId) async {
    final db = await DatabaseHelper().database;

    final rows = await db.rawQuery(
      '''
      SELECT
        h.id AS historia_id,
        COUNT(DISTINCT hf.id) AS fotos,
        COUNT(DISTINCT ha.id) AS audios,
        COUNT(DISTINCT hv.id) AS videos
      FROM capitulo_entradas ce
      JOIN historia h ON h.id = ce.entrada_id
      LEFT JOIN historia_fotos hf ON hf.historia_id = h.id
      LEFT JOIN historia_audios ha ON ha.historia_id = h.id
      LEFT JOIN historia_videos hv ON hv.historia_id = h.id
      WHERE ce.capitulo_id = ?
      GROUP BY h.id
      ''',
      [capituloId],
    );

    return {
      for (final row in rows)
        (row['historia_id'] as int): (
          fotos: (row['fotos'] as int?) ?? 0,
          audios: (row['audios'] as int?) ?? 0,
          videos: (row['videos'] as int?) ?? 0,
        ),
    };
  }
}
