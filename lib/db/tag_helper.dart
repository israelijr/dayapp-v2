import 'package:sqflite/sqflite.dart';

import '../models/tag.dart';
import 'database_helper.dart';

/// Helper de acesso ao banco de dados para as tabelas `tags` e `historia_tags`.
/// Usa o padrão Singleton para evitar instâncias múltiplas.
class TagHelper {
  static final TagHelper _instance = TagHelper._internal();
  factory TagHelper() => _instance;
  TagHelper._internal();

  // ── Consultas básicas ───────────────────────────────────────────────────────

  /// Retorna todas as tags de um usuário, em ordem alfabética.
  Future<List<Tag>> getAllTagsByUser(String userId) async {
    final db = await DatabaseHelper().database;
    final rows = await db.query(
      'tags',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'nome ASC',
    );
    return rows.map(Tag.fromMap).toList();
  }

  /// Pesquisa tags pelo slug normalizado; retorna no máximo [limit] resultados.
  /// Se [query] estiver vazio, retorna todas as tags do usuário.
  Future<List<Tag>> searchTags(
    String userId,
    String query, {
    int limit = 10,
  }) async {
    final db = await DatabaseHelper().database;
    final slug = Tag.generateSlug(query);
    if (slug.isEmpty) {
      final rows = await db.query(
        'tags',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'nome ASC',
        limit: limit,
      );
      return rows.map(Tag.fromMap).toList();
    }
    final rows = await db.query(
      'tags',
      where: 'user_id = ? AND slug LIKE ?',
      whereArgs: [userId, '%$slug%'],
      orderBy: 'nome ASC',
      limit: limit,
    );
    return rows.map(Tag.fromMap).toList();
  }

  // ── Criação / deduplicação ──────────────────────────────────────────────────

  /// Obtém a tag pelo slug (case-insensitive, sem acento) ou a cria se não
  /// existir. Garante que não haverá duplicidade por variação de acentos
  /// ou capitalização.
  Future<Tag> getOrCreateTag(String userId, String nome) async {
    final db = await DatabaseHelper().database;
    final slug = Tag.generateSlug(nome);

    // Tenta encontrar tag existente pelo slug
    final existing = await db.query(
      'tags',
      where: 'user_id = ? AND slug = ?',
      whereArgs: [userId, slug],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return Tag.fromMap(existing.first);
    }

    // Insere nova tag
    final id = await db.insert('tags', {
      'user_id': userId,
      'nome': nome,
      'slug': slug,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // Conflito de insert (race condition) → busca novamente
    if (id == 0) {
      final conflict = await db.query(
        'tags',
        where: 'user_id = ? AND slug = ?',
        whereArgs: [userId, slug],
        limit: 1,
      );
      if (conflict.isNotEmpty) return Tag.fromMap(conflict.first);
    }

    return Tag(id: id, userId: userId, nome: nome, slug: slug);
  }

  // ── Relação história ↔ tags ─────────────────────────────────────────────────

  /// Retorna as tags associadas a uma história.
  Future<List<Tag>> getTagsByHistoria(int historiaId) async {
    final db = await DatabaseHelper().database;
    final rows = await db.rawQuery(
      '''
      SELECT t.id, t.user_id, t.nome, t.slug
      FROM tags t
      INNER JOIN historia_tags ht ON ht.tag_id = t.id
      WHERE ht.historia_id = ?
      ORDER BY t.nome ASC
      ''',
      [historiaId],
    );
    return rows.map(Tag.fromMap).toList();
  }

  /// Define (substitui) as tags associadas a uma história de forma atômica.
  Future<void> setTagsForHistoria(
    int historiaId,
    List<Tag> tags,
    Database? existingDb,
  ) async {
    final db = existingDb ?? await DatabaseHelper().database;

    await db.delete(
      'historia_tags',
      where: 'historia_id = ?',
      whereArgs: [historiaId],
    );

    for (final tag in tags) {
      if (tag.id != null) {
        await db.insert('historia_tags', {
          'historia_id': historiaId,
          'tag_id': tag.id,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }
  }

  // ── Manutenção ──────────────────────────────────────────────────────────────

  /// Renomeia uma tag (atualiza o nome exibido e o slug normalizado).
  /// Como a tag é compartilhada entre histórias, a renomeação afeta todas
  /// as histórias que usam esta tag.
  Future<void> renameTag(int tagId, String newNome) async {
    final db = await DatabaseHelper().database;
    final newSlug = Tag.generateSlug(newNome);
    await db.update(
      'tags',
      {'nome': newNome, 'slug': newSlug},
      where: 'id = ?',
      whereArgs: [tagId],
    );
  }

  /// Exclui uma tag e todas as suas relações com histórias.
  /// (CASCADE no banco garante que historia_tags é limpa automaticamente.)
  Future<void> deleteTag(int tagId) async {
    final db = await DatabaseHelper().database;
    await db.delete('tags', where: 'id = ?', whereArgs: [tagId]);
  }

  /// Retorna todas as tags do usuário com a contagem de histórias associadas,
  /// ordenadas pela contagem decrescente.
  Future<List<Map<String, dynamic>>> getAllTagsWithCounts(String userId) async {
    final db = await DatabaseHelper().database;
    final rows = await db.rawQuery(
      '''
      SELECT t.id, t.user_id, t.nome, t.slug, COUNT(ht.historia_id) as cnt
      FROM tags t
      LEFT JOIN historia_tags ht ON ht.tag_id = t.id
      WHERE t.user_id = ?
      GROUP BY t.id
      ORDER BY cnt DESC, t.nome ASC
      ''',
      [userId],
    );
    return rows;
  }
}
