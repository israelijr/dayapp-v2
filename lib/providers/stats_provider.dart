import 'package:flutter/material.dart';

import '../providers/auth_provider.dart';
import '../repositories/capitulo_repository.dart';
import '../repositories/group_repository.dart';
import '../repositories/historia_repository.dart';

class StatsProvider with ChangeNotifier {
  final HistoriaRepository _historiaRepository;
  final CapituloRepository _capituloRepository;
  final GroupRepository _groupRepository;
  final AuthProvider _authProvider;

  int _totalStories = 0;
  int _totalChapters = 0;
  int _totalGroups = 0;
  int _storiesThisWeek = 0;
  bool _isLoading = false;

  String? _lastUserId;

  StatsProvider({
    required HistoriaRepository historiaRepository,
    required CapituloRepository capituloRepository,
    required GroupRepository groupRepository,
    required AuthProvider authProvider,
  })  : _historiaRepository = historiaRepository,
        _capituloRepository = capituloRepository,
        _groupRepository = groupRepository,
        _authProvider = authProvider {
    _authProvider.addListener(_onAuthChanged);
    _lastUserId = _authProvider.user?.id;
    // Carrega estatísticas iniciais se o usuário já estiver logado
    if (_lastUserId != null && _lastUserId!.isNotEmpty) {
      loadStats();
    }
  }

  void _onAuthChanged() {
    final currentUserId = _authProvider.user?.id;
    if (currentUserId != _lastUserId) {
      _lastUserId = currentUserId;
      loadStats();
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChanged);
    super.dispose();
  }

  int get totalStories => _totalStories;
  int get totalChapters => _totalChapters;
  int get totalGroups => _totalGroups;
  int get storiesThisWeek => _storiesThisWeek;
  bool get isLoading => _isLoading;

  String get _userId => _authProvider.user?.id ?? '';

  Future<void> loadStats() async {
    final userId = _userId;
    debugPrint('STATS_DEBUG: loadStats chamado com userId: "$userId"');
    if (userId.isEmpty) {
      _totalStories = 0;
      _totalChapters = 0;
      _totalGroups = 0;
      _storiesThisWeek = 0;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _historiaRepository.countStories(
          where: 'user_id = ? AND excluido IS NULL',
          whereArgs: [userId],
        ),
        _capituloRepository.countCapitulos(userId),
        _groupRepository.countGrupos(userId),
        _historiaRepository.countStoriesThisWeek(userId),
      ]);

      debugPrint('STATS_DEBUG: resultados obtidos: $results');

      _totalStories = results[0];
      _totalChapters = results[1];
      _totalGroups = results[2];
      _storiesThisWeek = results[3];
    } catch (e) {
      debugPrint('STATS_DEBUG: Erro ao carregar estatísticas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
