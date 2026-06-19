import 'package:flutter/material.dart';

import '../models/historia.dart';
import '../providers/auth_provider.dart';
import '../repositories/group_repository.dart';

class GroupStoriesProvider with ChangeNotifier {
  final GroupRepository _repository;
  final AuthProvider _authProvider;
  final int grupoId;
  final String groupName;

  bool _isLoading = false;
  String? _errorMessage;
  List<Historia> _historias = [];

  GroupStoriesProvider({
    required GroupRepository repository,
    required AuthProvider authProvider,
    required this.grupoId,
    required this.groupName,
  }) : _repository = repository,
       _authProvider = authProvider;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Historia> get historias => List.unmodifiable(_historias);

  Future<void> loadStories() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final userId = _authProvider.user?.id;
      if (userId == null) {
        _historias = [];
        return;
      }

      _historias = await _repository.fetchStoriesByGroup(
        userId: userId,
        groupName: groupName,
      );
    } catch (e) {
      _errorMessage = e.toString();
      _historias = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshStories() async {
    await loadStories();
  }

  Future<void> deleteHistoria(Historia historia) async {
    await _repository.deleteHistoria(historia);
    await loadStories();
  }

  Future<void> updateHistoria(
    Historia historia, {
    Map<String, dynamic>? updates,
  }) async {
    await _repository.updateHistoria(historia, updates: updates);
    await loadStories();
  }

  Future<void> archiveHistoria(Historia historia) async {
    await _repository.archiveHistoria(historia);
    await loadStories();
  }

  Future<void> ungroupHistoria(Historia historia) async {
    await _repository.updateHistoria(
      historia,
      updates: {'tag': null, 'arquivado': null, 'grupo': null},
    );
    await loadStories();
  }

  Future<void> deleteGroup() async {
    final userId = _authProvider.user?.id;
    if (userId == null) {
      throw StateError('Usuário não autenticado');
    }
    await _repository.deleteGroup(
      groupId: grupoId,
      groupName: groupName,
      userId: userId,
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
