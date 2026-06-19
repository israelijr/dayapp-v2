import '../models/capitulo.dart';
import 'export_block.dart';

class ChapterExportDocument {
  final int? chapterId;
  final String userId;
  final String chapterTitle;
  final String? chapterDescription;
  final DateTime startDate;
  final DateTime endDate;
  final String? coverImagePath;
  final int storyCount;
  final List<ExportBlock> blocks;

  const ChapterExportDocument({
    required this.userId,
    required this.chapterTitle,
    required this.startDate,
    required this.endDate,
    required this.storyCount,
    required this.blocks,
    this.chapterId,
    this.chapterDescription,
    this.coverImagePath,
  });

  factory ChapterExportDocument.fromChapter({
    required Capitulo chapter,
    required int storyCount,
    required List<ExportBlock> blocks,
  }) {
    return ChapterExportDocument(
      chapterId: chapter.id,
      userId: chapter.userId,
      chapterTitle: chapter.titulo,
      chapterDescription: chapter.descricao,
      startDate: chapter.dataInicio,
      endDate: chapter.dataFim,
      coverImagePath: chapter.fotoPath,
      storyCount: storyCount,
      blocks: blocks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chapter_id': chapterId,
      'user_id': userId,
      'chapter_title': chapterTitle,
      'chapter_description': chapterDescription,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'cover_image_path': coverImagePath,
      'story_count': storyCount,
      'blocks': blocks.map((block) => block.toMap()).toList(growable: false),
    };
  }

  factory ChapterExportDocument.fromMap(Map<String, dynamic> map) {
    final rawBlocks = map['blocks'] as List<dynamic>? ?? <dynamic>[];

    return ChapterExportDocument(
      chapterId: map['chapter_id'] as int?,
      userId: map['user_id'] as String,
      chapterTitle: map['chapter_title'] as String,
      chapterDescription: map['chapter_description'] as String?,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      coverImagePath: map['cover_image_path'] as String?,
      storyCount: map['story_count'] as int,
      blocks: rawBlocks
          .map((item) => ExportBlock.fromMap(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}
