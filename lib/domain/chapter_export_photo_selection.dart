import 'export_block.dart';

List<ExportBlock> filterExportBlocksBySelectedImages({
  required List<ExportBlock> blocks,
  required Map<int, List<String>?> selectedImagePathsByStoryId,
}) {
  if (selectedImagePathsByStoryId.isEmpty) {
    return List<ExportBlock>.from(blocks, growable: false);
  }

  final filtered = <ExportBlock>[];

  for (final block in blocks) {
    if (block is! ImageExportBlock || block.storyId == null) {
      filtered.add(block);
      continue;
    }

    final storyId = block.storyId!;
    if (!selectedImagePathsByStoryId.containsKey(storyId)) {
      filtered.add(block);
      continue;
    }

    final selectedPaths = selectedImagePathsByStoryId[storyId];
    if (selectedPaths == null || selectedPaths.isEmpty) {
      // none selected for this story -> skip image blocks
      continue;
    }

    // Special token to include all photos for the story
    const allToken = '__ALL_PHOTOS__';
    if (selectedPaths.length == 1 && selectedPaths.first == allToken) {
      filtered.add(block);
      continue;
    }

    if (selectedPaths.contains(block.imagePath)) {
      filtered.add(block);
    }
  }

  return List<ExportBlock>.unmodifiable(filtered);
}
