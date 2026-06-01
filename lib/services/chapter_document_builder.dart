import '../domain/chapter_export_document.dart';
import '../domain/export_block.dart';
import '../helpers/rich_text_helper.dart';
import '../models/capitulo.dart';
import '../models/historia.dart';
import '../models/historia_foto_v2.dart';
import 'chapter_story_ordering_service.dart';

class ChapterDocumentBuilder {
  final ChapterStoryOrderingService _orderingService;

  const ChapterDocumentBuilder({
    ChapterStoryOrderingService orderingService =
        const ChapterStoryOrderingService(),
  }) : _orderingService = orderingService;

  ChapterExportDocument build({
    required Capitulo chapter,
    required List<Historia> stories,
    Map<int, List<HistoriaFoto>> photosByStoryId = const {},
    Map<int, int>? displayOrderByStoryId,
  }) {
    final orderedStories = _orderingService.orderStories(
      stories,
      displayOrderByStoryId: displayOrderByStoryId,
    );

    final blocks = <ExportBlock>[
      TitleExportBlock(text: chapter.titulo),
      DateExportBlock(date: chapter.dataInicio),
      DateExportBlock(date: chapter.dataFim),
    ];

    final chapterDescription = _normalizeText(chapter.descricao);
    if (chapterDescription != null) {
      blocks.add(ParagraphExportBlock(text: chapterDescription));
    }

    for (final story in orderedStories) {
      final storyId = story.id;

      blocks.add(DateExportBlock(date: story.data, storyId: storyId));
      blocks.add(TitleExportBlock(text: story.titulo, storyId: storyId));

      final description = _normalizeText(story.descricao);
      if (description != null) {
        blocks.add(ParagraphExportBlock(text: description, storyId: storyId));
      }

      final photoEntries = storyId != null ? photosByStoryId[storyId] : null;
      if (photoEntries != null && photoEntries.isNotEmpty) {
        for (final photo in photoEntries) {
          blocks.add(
            ImageExportBlock(
              imagePath: photo.fotoPath,
              caption: _normalizeText(photo.legenda),
              storyId: storyId,
              fullWidth: true,
            ),
          );
        }
      } else {
        final coverPath = story.fotoHistoria;
        if (coverPath != null && coverPath.trim().isNotEmpty) {
          blocks.add(
            ImageExportBlock(
              imagePath: coverPath,
              storyId: storyId,
              fullWidth: true,
            ),
          );
        }
      }
    }

    return ChapterExportDocument.fromChapter(
      chapter: chapter,
      storyCount: orderedStories.length,
      blocks: List<ExportBlock>.unmodifiable(blocks),
    );
  }

  String? _normalizeText(String? rawText) {
    if (rawText == null || rawText.trim().isEmpty) {
      return null;
    }

    final text = RichTextHelper.isValidQuillJson(rawText)
        ? RichTextHelper.jsonToPlainText(rawText)
        : rawText;

    final normalized = text.trim();
    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }
}
