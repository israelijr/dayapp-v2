import 'package:sqflite/sqflite.dart' as sqflite_lib;

import '../models/grupo.dart';
import 'database_helper.dart';

class GrupoHelper {
  Future<int> insertGrupo(Grupo grupo) async {
    final db = await DatabaseHelper().database;
    return await db.insert('grupos', grupo.toMap());
  }

  Future<int> updateGrupoAndRenameHistorias(Grupo grupo, String oldNome) async {
    final db = await DatabaseHelper().database;
    return await db.transaction((txn) async {
      final rowsUpdated = await txn.update(
        'grupos',
        grupo.toMap(),
        where: 'id = ?',
        whereArgs: [grupo.id],
      );

      if (oldNome != grupo.nome) {
        // Mantém as histórias visíveis no grupo após renomear.
        await txn.update(
          'historia',
          {
            'grupo': grupo.nome,
            'data_update': DateTime.now().toIso8601String(),
            'backed_up': 0,
          },
          where: 'user_id = ? AND grupo = ?',
          whereArgs: [grupo.userId, oldNome],
        );
      }

      return rowsUpdated;
    });
  }

  Future<int> updateGrupo(Grupo grupo) async {
    final db = await DatabaseHelper().database;
    return await db.update(
      'grupos',
      grupo.toMap(),
      where: 'id = ?',
      whereArgs: [grupo.id],
    );
  }

  Future<List<Grupo>> getGruposByUser(String userId) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'grupos',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'nome ASC',
    );
    return result.map((map) => Grupo.fromMap(map)).toList();
  }

  Future<Grupo?> getGrupoByNome(String userId, String nome) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'grupos',
      where: 'user_id = ? AND nome = ?',
      whereArgs: [userId, nome],
    );
    if (result.isNotEmpty) {
      return Grupo.fromMap(result.first);
    }
    return null;
  }

  Future<int> deleteGrupo(int id) async {
    final db = await DatabaseHelper().database;
    return await db.delete('grupos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteGrupoAndUpdateHistorias(
    int grupoId,
    String grupoNome,
    String userId,
  ) async {
    final db = await DatabaseHelper().database;
    // Primeiro, atualizar histórias do grupo para voltar para a Home
    // Remove os flags de grupo e arquivado para que apareçam na Home
    await db.update(
      'historia',
      {
        'grupo': null,
        'arquivado': null,
        'data_update': DateTime.now().toIso8601String(),
        'backed_up': 0,
      },
      where: 'user_id = ? AND grupo = ?',
      whereArgs: [userId, grupoNome],
    );
    // Depois, excluir o grupo
    await db.delete('grupos', where: 'id = ?', whereArgs: [grupoId]);
  }

  /// Conta o número de histórias em um grupo específico (não arquivadas e não excluídas)
  Future<int> countHistoriasInGrupo(String userId, String grupoNome) async {
    final db = await DatabaseHelper().database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM historia WHERE user_id = ? AND grupo = ? AND arquivado IS NULL AND excluido IS NULL',
      [userId, grupoNome],
    );
    return sqflite_lib.Sqflite.firstIntValue(result) ?? 0;
  }

  /// Conta o número de histórias arquivadas (não excluídas)
  Future<int> countArquivadas(String userId) async {
    final db = await DatabaseHelper().database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM historia WHERE user_id = ? AND arquivado IS NOT NULL AND excluido IS NULL',
      [userId],
    );
    return sqflite_lib.Sqflite.firstIntValue(result) ?? 0;
  }
}
