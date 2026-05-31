import '../db/database_helper.dart';
import '../models/historia.dart';
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
