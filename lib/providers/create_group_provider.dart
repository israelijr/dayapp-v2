import 'package:flutter/material.dart';

import '../helpers/rich_text_helper.dart';
import '../models/historia.dart';
import '../providers/auth_provider.dart';
import '../providers/group_management_provider.dart';
import '../repositories/capitulo_repository.dart';

class CreateGroupProvider with ChangeNotifier {
  final CapituloRepository _capituloRepository;
  final AuthProvider _authProvider;
  final GroupManagementProvider _groupManagementProvider;

  bool _isLoadingStories = true;
  bool _isSaving = false;
  List<Historia> _stories = [];
  Map<int, String> _tagNomesPorId = {};
  
  final Set<int> _selectedStoryIds = {};
  String _searchQuery = '';
  
  String? _selectedEmoticon;
  String? _selectedEmojiTranslation;

  CreateGroupProvider({
    required CapituloRepository capituloRepository,
    required AuthProvider authProvider,
    required GroupManagementProvider groupManagementProvider,
  })  : _capituloRepository = capituloRepository,
        _authProvider = authProvider,
        _groupManagementProvider = groupManagementProvider {
    _loadStories();
  }

  bool get isLoadingStories => _isLoadingStories;
  bool get isSaving => _isSaving;
  List<Historia> get stories => _stories;
  Set<int> get selectedStoryIds => _selectedStoryIds;
  String get searchQuery => _searchQuery;
  
  String? get selectedEmoticon => _selectedEmoticon;
  String? get selectedEmojiTranslation => _selectedEmojiTranslation;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleStorySelection(int id, bool isSelected) {
    if (isSelected) {
      _selectedStoryIds.add(id);
    } else {
      _selectedStoryIds.remove(id);
    }
    notifyListeners();
  }
  
  void setEmoticon(String emoticon, String translation) {
    _selectedEmoticon = emoticon;
    _selectedEmojiTranslation = translation;
    notifyListeners();
  }

  Future<void> _loadStories() async {
    final userId = _authProvider.user?.id;
    if (userId == null) {
      _isLoadingStories = false;
      notifyListeners();
      return;
    }

    try {
      final entries = await _capituloRepository.listEntradasElegiveisComTags(userId);

      final loadedStories = entries
          .map((entry) => entry.historia)
          .where((story) =>
              story.id != null &&
              story.grupo == null &&
              story.excluido == null)
          .toList(growable: false);

      loadedStories.sort((a, b) {
        final aArchived = a.arquivado == 'sim';
        final bArchived = b.arquivado == 'sim';
        if (aArchived != bArchived) {
          return aArchived ? 1 : -1;
        }
        return b.data.compareTo(a.data);
      });

      final tagNomesPorId = <int, String>{
        for (final entry in entries)
          if (entry.historia.id != null) entry.historia.id!: entry.tagNomes,
      };

      _stories = loadedStories;
      _tagNomesPorId = tagNomesPorId;
    } catch (e) {
      debugPrint('CreateGroupProvider: erro ao carregar histórias: $e');
      _stories = [];
      _tagNomesPorId = {};
    } finally {
      _isLoadingStories = false;
      notifyListeners();
    }
  }

  List<Historia> getFilteredStories(String localeName) {
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    
    return _stories.where((story) {
      if (normalizedQuery.isEmpty) return true;

      final title = story.titulo.toLowerCase();
      
      final descriptionText = RichTextHelper.jsonToPlainText(story.descricao).toLowerCase();
      
      final subject = (story.assunto ?? '').toLowerCase();
      final legacyTag = (story.tag ?? '').toLowerCase();
      final tagNames = story.id != null
          ? (_tagNomesPorId[story.id!] ?? '').toLowerCase()
          : '';

      return title.contains(normalizedQuery) ||
          descriptionText.contains(normalizedQuery) ||
          legacyTag.contains(normalizedQuery) ||
          tagNames.contains(normalizedQuery) ||
          subject.contains(normalizedQuery);
    }).toList(growable: false);
  }

  Future<void> saveGroup({
    required String groupName,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      await _groupManagementProvider.createGrupoWithStories(
        groupName: groupName,
        emoticon: _selectedEmoticon,
        storyIds: _selectedStoryIds.toList(growable: false),
      );
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
