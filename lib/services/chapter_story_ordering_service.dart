import '../models/historia.dart';

class ChapterStoryOrderingService {
  const ChapterStoryOrderingService();

  List<Historia> orderStories(
    List<Historia> stories, {
    Map<int, int>? displayOrderByStoryId,
  }) {
    final orderedStories = List<Historia>.from(stories);

    orderedStories.sort((a, b) {
      final aOrder = _storyOrder(a.id, displayOrderByStoryId);
      final bOrder = _storyOrder(b.id, displayOrderByStoryId);

      if (aOrder != null && bOrder != null && aOrder != bOrder) {
        return aOrder.compareTo(bOrder);
      }

      if (aOrder != null && bOrder == null) {
        return -1;
      }

      if (aOrder == null && bOrder != null) {
        return 1;
      }

      final byDate = a.data.compareTo(b.data);
      if (byDate != 0) {
        return byDate;
      }

      final aId = a.id ?? 0;
      final bId = b.id ?? 0;
      return aId.compareTo(bId);
    });

    return orderedStories;
  }

  int? _storyOrder(int? storyId, Map<int, int>? displayOrderByStoryId) {
    if (storyId == null || displayOrderByStoryId == null) {
      return null;
    }
    return displayOrderByStoryId[storyId];
  }
}
