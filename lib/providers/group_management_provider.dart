import 'package:flutter/material.dart';

import '../models/grupo.dart';
import '../providers/auth_provider.dart';
import '../repositories/group_repository.dart';

class GroupManagementProvider with ChangeNotifier {
  final GroupRepository _repository;
  final AuthProvider _authProvider;

  bool _isLoading = false;
  String? _errorMessage;
  List<Grupo> _grupos = [];

  GroupManagementProvider({
    required GroupRepository repository,
    required AuthProvider authProvider,
  }) : _repository = repository,
       _authProvider = authProvider;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userId => _authProvider.user?.id;
  List<Grupo> get grupos => List.unmodifiable(_grupos);

  Future<void> loadGrupos() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final userId = _authProvider.user?.id;
      if (userId == null) {
        _grupos = [];
        return;
      }

      _grupos = await _repository.fetchGroupsByUser(userId);
    } catch (e) {
      _errorMessage = e.toString();
      _grupos = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveGrupo(Grupo grupo, {String? oldName}) async {
    final userId = _authProvider.user?.id;
    if (userId == null) {
      throw StateError('Usuário não autenticado');
    }

    final grupoToSave = grupo.id == null
        ? Grupo(
            userId: userId,
            nome: grupo.nome,
            emoticon: grupo.emoticon,
            dataCriacao: grupo.dataCriacao,
          )
        : grupo;

    if (grupo.id == null) {
      await _repository.insertGrupo(grupoToSave);
    } else {
      await _repository.updateGrupoAndRenameHistorias(
        grupoToSave,
        oldName ?? grupoToSave.nome,
      );
    }

    await loadGrupos();
  }

  Future<void> createGrupoWithStories({
    required String groupName,
    String? emoticon,
    required List<int> storyIds,
  }) async {
    final userId = _authProvider.user?.id;
    if (userId == null) {
      throw StateError('Usuário não autenticado');
    }
    if (groupName.trim().isEmpty) {
      throw StateError('Nome do grupo inválido');
    }
    if (storyIds.isEmpty) {
      throw StateError('Selecione ao menos uma história');
    }

    final normalizedName = groupName.trim();
    final exists = await _repository.groupNameExists(
      userId: userId,
      name: normalizedName,
    );
    if (exists) {
      throw StateError('GROUP_ALREADY_EXISTS');
    }

    final groupId = await _repository.insertGrupo(
      Grupo(
        userId: userId,
        nome: normalizedName,
        emoticon: emoticon,
        dataCriacao: DateTime.now(),
      ),
    );

    if (groupId <= 0) {
      throw StateError('Falha ao criar grupo');
    }

    await _repository.assignStoriesToGroup(
      userId: userId,
      groupName: normalizedName,
      storyIds: storyIds,
    );

    await loadGrupos();
  }

  Future<int> countHistoriasInGroup(String groupName) async {
    final userId = _authProvider.user?.id;
    if (userId == null) {
      throw StateError('Usuário não autenticado');
    }
    return _repository.countHistoriasInGroup(userId, groupName);
  }

  Future<void> deleteGrupo(Grupo grupo) async {
    final userId = _authProvider.user?.id;
    if (userId == null) {
      throw StateError('Usuário não autenticado');
    }
    if (grupo.id == null) {
      throw StateError('Grupo sem id');
    }

    await _repository.deleteGroupAndUpdateHistorias(
      grupo.id!,
      grupo.nome,
      userId,
    );
    await loadGrupos();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
