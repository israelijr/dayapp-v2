import '../story_data.dart';

enum StoryShareTemplateType {
  heroMemory,
  polaroidStack,
  scrapbook,
  minimalTimeline,
}

class StoryShareTemplateSelector {
  static StoryShareTemplateType selectTemplate(StoryData story) {
    if (story.images.isEmpty) {
      return StoryShareTemplateType.heroMemory;
    }

    final count = story.images.length;

    if (count == 5) {
      return StoryShareTemplateType.polaroidStack;
    }

    if (count <= 3) {
      return StoryShareTemplateType.heroMemory;
    }

    return StoryShareTemplateType.scrapbook;
  }
}
