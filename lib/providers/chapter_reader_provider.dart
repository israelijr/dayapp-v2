import 'package:flutter/material.dart';

import '../domain/chapter_export_document.dart';
import '../repositories/capitulo_repository.dart';

class ChapterReaderProvider with ChangeNotifier {
  final int chapterId;
  final CapituloRepository _capituloRepository;

  bool _isLoading = false;
  ChapterExportDocument? _document;
  String? _errorMessage;

  ChapterReaderProvider({
    required this.chapterId,
    CapituloRepository? capituloRepository,
  }) : _capituloRepository = capituloRepository ?? CapituloRepository();

  bool get isLoading => _isLoading;
  ChapterExportDocument? get document => _document;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loadedDocument = await _capituloRepository
          .fetchChapterExportDocument(chapterId);
      _document = loadedDocument;
      if (loadedDocument == null) {
        _errorMessage = 'chapter_not_found';
      }
    } catch (_) {
      _errorMessage = 'chapter_reader_load_failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
