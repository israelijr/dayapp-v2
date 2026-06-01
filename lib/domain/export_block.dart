enum ExportBlockType { title, date, paragraph, image }

abstract class ExportBlock {
  final ExportBlockType type;
  final int? storyId;

  const ExportBlock({required this.type, this.storyId});

  Map<String, dynamic> toMap();

  static ExportBlock fromMap(Map<String, dynamic> map) {
    final typeName = map['type'] as String?;
    final storyId = map['story_id'] as int?;

    switch (typeName) {
      case 'title':
        return TitleExportBlock(text: map['text'] as String, storyId: storyId);
      case 'date':
        return DateExportBlock(
          date: DateTime.parse(map['date'] as String),
          storyId: storyId,
        );
      case 'paragraph':
        return ParagraphExportBlock(
          text: map['text'] as String,
          storyId: storyId,
        );
      case 'image':
        return ImageExportBlock(
          imagePath: map['image_path'] as String,
          caption: map['caption'] as String?,
          storyId: storyId,
          fullWidth: (map['full_width'] as int? ?? 1) == 1,
        );
      default:
        throw ArgumentError('Unsupported export block type: $typeName');
    }
  }
}

class TitleExportBlock extends ExportBlock {
  final String text;

  const TitleExportBlock({required this.text, super.storyId})
    : super(type: ExportBlockType.title);

  @override
  Map<String, dynamic> toMap() {
    return {'type': 'title', 'text': text, 'story_id': storyId};
  }
}

class DateExportBlock extends ExportBlock {
  final DateTime date;

  const DateExportBlock({required this.date, super.storyId})
    : super(type: ExportBlockType.date);

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'date',
      'date': date.toIso8601String(),
      'story_id': storyId,
    };
  }
}

class ParagraphExportBlock extends ExportBlock {
  final String text;

  const ParagraphExportBlock({required this.text, super.storyId})
    : super(type: ExportBlockType.paragraph);

  @override
  Map<String, dynamic> toMap() {
    return {'type': 'paragraph', 'text': text, 'story_id': storyId};
  }
}

class ImageExportBlock extends ExportBlock {
  final String imagePath;
  final String? caption;
  final bool fullWidth;

  const ImageExportBlock({
    required this.imagePath,
    this.caption,
    this.fullWidth = true,
    super.storyId,
  }) : super(type: ExportBlockType.image);

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'image',
      'image_path': imagePath,
      'caption': caption,
      'full_width': fullWidth ? 1 : 0,
      'story_id': storyId,
    };
  }
}
