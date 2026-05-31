import '../story_data.dart';

enum StoryShareTemplateType {
  heroMemory,
  polaroidStack,
  scrapbook,
  minimalTimeline,
}

class StoryShareTemplateSelector {
  static StoryShareTemplateType selectTemplate(StoryData story) {
    final count = story.images.length;

    if (count <= 3) {
      return StoryShareTemplateType.heroMemory;
    }

    if (count <= 5) {
      return StoryShareTemplateType.scrapbook;
    }

    return StoryShareTemplateType.polaroidStack;
  }
}
