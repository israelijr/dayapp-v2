import 'package:dayapp/domain/chapter_export_document.dart';
import 'package:dayapp/domain/export_block.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chapter export document supports map roundtrip', () {
    final document = ChapterExportDocument(
      chapterId: 10,
      userId: 'user-1',
      chapterTitle: 'Carro na oficina',
      chapterDescription: 'Capitulo de manutencao',
      startDate: DateTime(2026, 3, 10),
      endDate: DateTime(2026, 5, 4),
      coverImagePath: '/tmp/cover.jpg',
      storyCount: 2,
      blocks: [
        const TitleExportBlock(text: 'Carro na oficina'),
        DateExportBlock(date: DateTime(2026, 3, 10), storyId: 1),
        const ParagraphExportBlock(text: 'Levei para a oficina', storyId: 1),
        const ImageExportBlock(
          imagePath: '/tmp/story-1.jpg',
          caption: 'Primeira vistoria',
          storyId: 1,
        ),
      ],
    );

    final map = document.toMap();
    final restored = ChapterExportDocument.fromMap(map);

    expect(restored.chapterId, 10);
    expect(restored.userId, 'user-1');
    expect(restored.chapterTitle, 'Carro na oficina');
    expect(restored.chapterDescription, 'Capitulo de manutencao');
    expect(restored.storyCount, 2);
    expect(restored.blocks.length, 4);
    expect(restored.blocks[0], isA<TitleExportBlock>());
    expect(restored.blocks[1], isA<DateExportBlock>());
    expect(restored.blocks[2], isA<ParagraphExportBlock>());
    expect(restored.blocks[3], isA<ImageExportBlock>());
  });
}
