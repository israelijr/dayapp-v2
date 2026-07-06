import 'package:flutter/material.dart';

import '../models/historia.dart';
import '../providers/auth_provider.dart';
import '../providers/refresh_provider.dart';
import '../repositories/historia_repository.dart';

class HomeStoriesProvider with ChangeNotifier {
  static const int _pageSize = 15;

  final HistoriaRepository _repository;
  final AuthProvider _authProvider;
  final RefreshProvider _refreshProvider;

  bool _isInitialLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  bool _showAllStories = false;
  final List<Historia> _historias = [];
  String? _errorMessage;

  HomeStoriesProvider({
    required HistoriaRepository repository,
    required AuthProvider authProvider,
    required RefreshProvider refreshProvider,
  }) : _repository = repository,
       _authProvider = authProvider,
       _refreshProvider = refreshProvider;

  bool get isInitialLoading => _isInitialLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  bool get showAllStories => _showAllStories;
  List<Historia> get historias => List.unmodifiable(_historias);
  String? get errorMessage => _errorMessage;

  String get _userId => _authProvider.user?.id ?? '';

  Future<void> loadInitialStories({bool forceRefresh = false}) async {
    _errorMessage = null;

    final showSpinner = _historias.isEmpty || forceRefresh;
    if (showSpinner) {
      _isInitialLoading = true;
      _hasMoreData = true;
      _historias.clear();
      notifyListeners();
    }

    try {
      if (_userId.isEmpty) {
        _hasMoreData = false;
        return;
      }

      if (!_showAllStories) {
        _historias.clear();
        _hasMoreData = false;
        return;
      }

      final items = await _repository.fetchUserStoriesPaginated(
        userId: _userId,
        showAllStories: _showAllStories,
        limit: _pageSize,
        offset: 0,
      );

      _historias
        ..clear()
        ..addAll(items);
      _hasMoreData = items.length == _pageSize;
      if (!_showAllStories && items.length < _pageSize) {
        _hasMoreData = false;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (showSpinner) {
        _isInitialLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> refreshStories({bool forceRefresh = false}) async {
    await loadInitialStories(forceRefresh: forceRefresh);
  }

  Future<void> toggleShowAllStories(bool value) async {
    _showAllStories = value;
    notifyListeners();
    await loadInitialStories(forceRefresh: true);
  }

  Future<void> loadMoreStories() async {
    if (_isLoadingMore || !_hasMoreData || _userId.isEmpty || !_showAllStories) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final items = await _repository.fetchUserStoriesPaginated(
        userId: _userId,
        showAllStories: _showAllStories,
        limit: _pageSize,
        offset: _historias.length,
      );

      if (items.isEmpty) {
        _hasMoreData = false;
      } else {
        _historias.addAll(items);
        _hasMoreData = items.length == _pageSize;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> archiveStory(Historia historia) async {
    await _repository.archiveHistoria(historia);
    _refreshProvider.refresh();
    await refreshStories(forceRefresh: true);
  }

  Future<void> deleteStory(Historia historia) async {
    await _repository.deleteHistoria(historia);
    _refreshProvider.refresh();
    await refreshStories(forceRefresh: true);
  }

  Future<void> updateStory(
    Historia historia, {
    Map<String, dynamic>? updates,
  }) async {
    await _repository.updateHistoria(historia, updates: updates);
    _refreshProvider.refresh();
    await refreshStories(forceRefresh: true);
  }
}
