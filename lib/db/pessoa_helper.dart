import 'package:sqflite/sqflite.dart';

import '../models/pessoa.dart';
import 'database_helper.dart';

/// Helper de acesso ao banco de dados para as tabelas `pessoas` e `historia_pessoas`.
/// Usa o padrão Singleton para evitar instâncias múltiplas.
class PessoaHelper {
  static final PessoaHelper _instance = PessoaHelper._internal();
  factory PessoaHelper() => _instance;
  PessoaHelper._internal();

  // ── Consultas básicas ───────────────────────────────────────────────────────

  /// Retorna todas as pessoas de um usuário, em ordem alfabética.
  Future<List<Pessoa>> getAllPessoasByUser(String userId) async {
    final db = await DatabaseHelper().database;
    final rows = await db.query(
      'pessoas',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'nome ASC',
    );
    return rows.map(Pessoa.fromMap).toList();
  }

  /// Pesquisa pessoas pelo slug normalizado; retorna no máximo [limit] resultados.
  /// Se [query] estiver vazio, retorna todas as pessoas do usuário.
  Future<List<Pessoa>> searchPessoas(
    String userId,
    String query, {
    int limit = 10,
  }) async {
    final db = await DatabaseHelper().database;
    final slug = Pessoa.generateSlug(query);
    if (slug.isEmpty) {
      final rows = await db.query(
        'pessoas',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'nome ASC',
        limit: limit,
      );
      return rows.map(Pessoa.fromMap).toList();
    }
    final rows = await db.query(
      'pessoas',
      where: 'user_id = ? AND slug LIKE ?',
      whereArgs: [userId, '%$slug%'],
      orderBy: 'nome ASC',
      limit: limit,
    );
    return rows.map(Pessoa.fromMap).toList();
  }

  // ── Criação / deduplicação ──────────────────────────────────────────────────

  /// Obtém a pessoa pelo slug (case-insensitive, sem acento) ou a cria se não
  /// existir. Garante que não haverá duplicidade por variação de acentos
  /// ou capitalização.
  Future<Pessoa> getOrCreatePessoa(String userId, String nome) async {
    final db = await DatabaseHelper().database;
    final slug = Pessoa.generateSlug(nome);

    // Tenta encontrar pessoa existente pelo slug
    final existing = await db.query(
      'pessoas',
      where: 'user_id = ? AND slug = ?',
      whereArgs: [userId, slug],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return Pessoa.fromMap(existing.first);
    }

    // Insere nova pessoa
    final id = await db.insert('pessoas', {
      'user_id': userId,
      'nome': nome,
      'slug': slug,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // Conflito de insert (race condition) → busca novamente
    if (id == 0) {
      final conflict = await db.query(
        'pessoas',
        where: 'user_id = ? AND slug = ?',
        whereArgs: [userId, slug],
        limit: 1,
      );
      if (conflict.isNotEmpty) return Pessoa.fromMap(conflict.first);
    }

    return Pessoa(id: id, userId: userId, nome: nome, slug: slug);
  }

  // ── Relação história ↔ pessoas ──────────────────────────────────────────────

  /// Retorna as pessoas associadas a uma história.
  Future<List<Pessoa>> getPessoasByHistoria(int historiaId) async {
    final db = await DatabaseHelper().database;
    final rows = await db.rawQuery(
      '''
      SELECT p.id, p.user_id, p.nome, p.slug
      FROM pessoas p
      INNER JOIN historia_pessoas hp ON hp.pessoa_id = p.id
      WHERE hp.historia_id = ?
      ORDER BY p.nome ASC
      ''',
      [historiaId],
    );
    return rows.map(Pessoa.fromMap).toList();
  }

  /// Define (substitui) as pessoas associadas a uma história de forma atômica.
  Future<void> setPessoasForHistoria(
    int historiaId,
    List<Pessoa> pessoas,
    Database? existingDb,
  ) async {
    final db = existingDb ?? await DatabaseHelper().database;

    await db.delete(
      'historia_pessoas',
      where: 'historia_id = ?',
      whereArgs: [historiaId],
    );

    for (final pessoa in pessoas) {
      if (pessoa.id != null) {
        await db.insert('historia_pessoas', {
          'historia_id': historiaId,
          'pessoa_id': pessoa.id,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }
  }

  // ── Manutenção ──────────────────────────────────────────────────────────────

  /// Renomeia uma pessoa (atualiza o nome exibido e o slug normalizado).
  Future<void> renamePessoa(int pessoaId, String newNome) async {
    final db = await DatabaseHelper().database;
    final newSlug = Pessoa.generateSlug(newNome);
    await db.update(
      'pessoas',
      {'nome': newNome, 'slug': newSlug},
      where: 'id = ?',
      whereArgs: [pessoaId],
    );
  }

  /// Exclui uma pessoa e todas as suas relações com histórias.
  Future<void> deletePessoa(int pessoaId) async {
    final db = await DatabaseHelper().database;
    await db.delete('pessoas', where: 'id = ?', whereArgs: [pessoaId]);
  }

  /// Retorna todas as pessoas do usuário com a contagem de histórias associadas,
  /// ordenadas pela contagem decrescente.
  Future<List<Map<String, dynamic>>> getAllPessoasWithCounts(String userId) async {
    final db = await DatabaseHelper().database;
    final rows = await db.rawQuery(
      '''
      SELECT p.id, p.user_id, p.nome, p.slug, COUNT(hp.historia_id) as cnt
      FROM pessoas p
      LEFT JOIN historia_pessoas hp ON hp.pessoa_id = p.id
      WHERE p.user_id = ?
      GROUP BY p.id
      ORDER BY cnt DESC, p.nome ASC
      ''',
      [userId],
    );
    return rows;
  }
}
