import 'export_block.dart';

List<ExportBlock> filterExportBlocksBySelectedImages({
  required List<ExportBlock> blocks,
  required Map<int, String?> selectedImagePathByStoryId,
}) {
  if (selectedImagePathByStoryId.isEmpty) {
    return List<ExportBlock>.from(blocks, growable: false);
  }

  final selectedImageAlreadyIncluded = <int>{};
  final filtered = <ExportBlock>[];

  for (final block in blocks) {
    if (block is! ImageExportBlock || block.storyId == null) {
      filtered.add(block);
      continue;
    }

    final storyId = block.storyId!;
    if (!selectedImagePathByStoryId.containsKey(storyId)) {
      filtered.add(block);
      continue;
    }

    final selectedPath = selectedImagePathByStoryId[storyId];
    if (selectedPath == null) {
      continue;
    }

    final wasAlreadyIncluded = selectedImageAlreadyIncluded.contains(storyId);
    if (!wasAlreadyIncluded && block.imagePath == selectedPath) {
      filtered.add(block);
      selectedImageAlreadyIncluded.add(storyId);
    }
  }

  return List<ExportBlock>.unmodifiable(filtered);
}
