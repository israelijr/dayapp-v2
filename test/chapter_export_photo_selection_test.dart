import 'package:dayapp/domain/chapter_export_photo_selection.dart';
import 'package:dayapp/domain/export_block.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps at most one selected image per story', () {
    final blocks = <ExportBlock>[
      const TitleExportBlock(text: 'Story A', storyId: 1),
      const ImageExportBlock(imagePath: '/tmp/a_1.jpg', storyId: 1),
      const ImageExportBlock(imagePath: '/tmp/a_2.jpg', storyId: 1),
      const TitleExportBlock(text: 'Story B', storyId: 2),
      const ImageExportBlock(imagePath: '/tmp/b_1.jpg', storyId: 2),
      const ImageExportBlock(imagePath: '/tmp/b_2.jpg', storyId: 2),
    ];

    final filtered = filterExportBlocksBySelectedImages(
      blocks: blocks,
      selectedImagePathsByStoryId: {
        1: ['/tmp/a_2.jpg'],
        2: ['/tmp/b_1.jpg'],
      },
    );

    final images = filtered.whereType<ImageExportBlock>().toList();
    expect(images.length, 2);
    expect(images[0].imagePath, '/tmp/a_2.jpg');
    expect(images[1].imagePath, '/tmp/b_1.jpg');
  });

  test('allows selecting no image for a story', () {
    final blocks = <ExportBlock>[
      const TitleExportBlock(text: 'Story A', storyId: 1),
      const ImageExportBlock(imagePath: '/tmp/a_1.jpg', storyId: 1),
      const ParagraphExportBlock(text: 'Body A', storyId: 1),
      const TitleExportBlock(text: 'Story B', storyId: 2),
      const ImageExportBlock(imagePath: '/tmp/b_1.jpg', storyId: 2),
      const ParagraphExportBlock(text: 'Body B', storyId: 2),
    ];

    final filtered = filterExportBlocksBySelectedImages(
      blocks: blocks,
      selectedImagePathsByStoryId: {
        1: null,
        2: ['/tmp/b_1.jpg'],
      },
    );

    final story1Images = filtered
        .whereType<ImageExportBlock>()
        .where((block) => block.storyId == 1)
        .toList();
    final story2Images = filtered
        .whereType<ImageExportBlock>()
        .where((block) => block.storyId == 2)
        .toList();

    expect(story1Images, isEmpty);
    expect(story2Images.length, 1);
    expect(story2Images.first.imagePath, '/tmp/b_1.jpg');
    expect(
      filtered.any(
        (block) =>
            block is ParagraphExportBlock &&
            block.storyId == 1 &&
            block.text == 'Body A',
      ),
      isTrue,
    );
  });
}
