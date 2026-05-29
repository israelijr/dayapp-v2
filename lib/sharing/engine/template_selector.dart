import '../story_data.dart';

enum StoryShareTemplateType { heroMemory, scrapbook, minimalTimeline }

class StoryShareTemplateSelector {
  static StoryShareTemplateType selectTemplate(StoryData story) {
    if (story.images.isEmpty) {
      return StoryShareTemplateType.heroMemory;
    }

    final count = story.images.length;

    if (count <= 1) {
      return StoryShareTemplateType.heroMemory;
    }

    if (count <= 5) {
      return StoryShareTemplateType.scrapbook;
    }

    return StoryShareTemplateType.minimalTimeline;
  }
}
