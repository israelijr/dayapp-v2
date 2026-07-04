import '../db/database_helper.dart';
import '../db/grupo_helper.dart';
import '../models/grupo.dart';
import '../models/historia.dart';
import 'historia_repository.dart';

class GroupRepository {
  final GrupoHelper _grupoHelper;
  final HistoriaRepository _historiaRepository;

  GroupRepository({
    GrupoHelper? grupoHelper,
    HistoriaRepository? historiaRepository,
  }) : _grupoHelper = grupoHelper ?? GrupoHelper(),
       _historiaRepository = historiaRepository ?? HistoriaRepository();

  Future<List<Historia>> fetchStoriesByGroup({
    required String userId,
    required String groupName,
  }) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'historia',
      where:
          'user_id = ? AND grupo = ? AND arquivado IS NULL AND excluido IS NULL',
      whereArgs: [userId, groupName],
      orderBy: 'data DESC',
    );
    return result.map((map) => Historia.fromMap(map)).toList(growable: false);
  }

  Future<List<Historia>> fetchUngroupedStories({required String userId}) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'historia',
      where:
          'user_id = ? AND grupo IS NULL AND arquivado IS NULL AND excluido IS NULL',
      whereArgs: [userId],
      orderBy: 'data DESC',
    );
    return result.map((map) => Historia.fromMap(map)).toList(growable: false);
  }

  Future<List<Grupo>> fetchGroupsByUser(String userId) async {
    return _grupoHelper.getGruposByUser(userId);
  }

  Future<int> countHistoriasInGroup(String userId, String groupName) async {
    return _grupoHelper.countHistoriasInGrupo(userId, groupName);
  }

  Future<int> countUngroupedHistorias(String userId) async {
    return _grupoHelper.countUngroupedHistorias(userId);
  }

  Future<int> insertGrupo(Grupo grupo) async {
    return _grupoHelper.insertGrupo(grupo);
  }

  Future<bool> groupNameExists({
    required String userId,
    required String name,
  }) async {
    final existing = await _grupoHelper.getGrupoByNome(userId, name);
    return existing != null;
  }

  Future<void> assignStoriesToGroup({
    required String userId,
    required String groupName,
    required List<int> storyIds,
  }) async {
    if (storyIds.isEmpty) return;

    final db = await DatabaseHelper().database;
    final placeholders = List.filled(storyIds.length, '?').join(',');
    final nowIso = DateTime.now().toIso8601String();

    await db.update(
      'historia',
      {
        'grupo': groupName,
        'tag': null,
        'arquivado': null,
        'data_update': nowIso,
        'backed_up': 0,
      },
      where: 'user_id = ? AND id IN ($placeholders)',
      whereArgs: [userId, ...storyIds],
    );
  }

  Future<int> updateGrupoAndRenameHistorias(Grupo grupo, String oldName) async {
    return _grupoHelper.updateGrupoAndRenameHistorias(grupo, oldName);
  }

  Future<void> deleteGroupAndUpdateHistorias(
    int groupId,
    String groupName,
    String userId,
  ) async {
    await _grupoHelper.deleteGrupoAndUpdateHistorias(
      groupId,
      groupName,
      userId,
    );
  }

  Future<void> deleteGroup({
    required int groupId,
    required String groupName,
    required String userId,
  }) async {
    await _grupoHelper.deleteGrupoAndUpdateHistorias(
      groupId,
      groupName,
      userId,
    );
  }

  Future<void> deleteHistoria(Historia historia) async {
    await _historiaRepository.deleteHistoria(historia);
  }

  Future<void> updateHistoria(
    Historia historia, {
    Map<String, dynamic>? updates,
  }) async {
    await _historiaRepository.updateHistoria(historia, updates: updates);
  }

  Future<void> archiveHistoria(Historia historia) async {
    await _historiaRepository.archiveHistoria(historia);
  }
}
