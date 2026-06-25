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

  /// Particiona o documento em múltiplas partes respeitando o limite maxBlocksPerPart.
  /// Evita quebrar blocos que pertencem à mesma história.
  List<ChapterExportDocument> split(int maxBlocksPerPart) {
    if (blocks.isEmpty) return [this];
    if (blocks.length <= maxBlocksPerPart) {
      return [this];
    }

    final storyGroups = <List<ExportBlock>>[];
    List<ExportBlock> currentGroup = [];

    for (final block in blocks) {
      if (block.storyId == null) {
        if (currentGroup.isNotEmpty) {
          storyGroups.add(currentGroup);
          currentGroup = [];
        }
        storyGroups.add([block]);
      } else {
        if (currentGroup.isNotEmpty &&
            currentGroup.first.storyId != block.storyId) {
          storyGroups.add(currentGroup);
          currentGroup = [block];
        } else {
          currentGroup.add(block);
        }
      }
    }
    if (currentGroup.isNotEmpty) {
      storyGroups.add(currentGroup);
    }

    final parts = <List<ExportBlock>>[];
    List<ExportBlock> currentPart = [];

    for (final group in storyGroups) {
      if (currentPart.isEmpty) {
        currentPart.addAll(group);
      } else if (currentPart.length + group.length > maxBlocksPerPart) {
        parts.add(currentPart);
        currentPart = List<ExportBlock>.from(group);
      } else {
        currentPart.addAll(group);
      }
    }
    if (currentPart.isNotEmpty) {
      parts.add(currentPart);
    }

    return parts.map((partBlocks) {
      final uniqueStoryIds =
          partBlocks.map((b) => b.storyId).where((id) => id != null).toSet();
      return ChapterExportDocument(
        chapterId: chapterId,
        userId: userId,
        chapterTitle: chapterTitle,
        chapterDescription: chapterDescription,
        startDate: startDate,
        endDate: endDate,
        coverImagePath: coverImagePath,
        storyCount: uniqueStoryIds.length,
        blocks: partBlocks,
      );
    }).toList();
  }
}

