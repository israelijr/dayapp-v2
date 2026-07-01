import 'database_helper.dart';

/// Helper para consultas de locais já cadastrados em histórias do usuário.
class LocalHelper {
  static final LocalHelper _instance = LocalHelper._internal();
  factory LocalHelper() => _instance;
  LocalHelper._internal();

  /// Pesquisa locais distintos do usuário por trecho do texto.
  ///
  /// O filtro é case-insensitive e retorna no máximo [limit] resultados.
  Future<List<String>> searchLocaisByUser(
    String userId,
    String query, {
    int limit = 10,
  }) async {
    final db = await DatabaseHelper().database;
    final normalizedQuery = query.trim().toLowerCase();

    final rows = await db.rawQuery(
      '''
      SELECT DISTINCT TRIM(local) AS local
      FROM historia
      WHERE user_id = ?
        AND local IS NOT NULL
        AND TRIM(local) <> ''
        AND (? = '' OR LOWER(local) LIKE ?)
      ORDER BY local COLLATE NOCASE ASC
      LIMIT ?
      ''',
      [userId, normalizedQuery, '%$normalizedQuery%', limit],
    );

    return rows
        .map((row) => (row['local'] as String?)?.trim() ?? '')
        .where((local) => local.isNotEmpty)
        .toList(growable: false);
  }
}
