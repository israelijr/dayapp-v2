import 'package:dayapp/sharing/engine/template_selector.dart';
import 'package:dayapp/sharing/story_data.dart';
import 'package:dayapp/sharing/templates/hero_memory_template.dart';
import 'package:dayapp/sharing/templates/minimal_timeline_template.dart';
import 'package:dayapp/sharing/templates/polaroid_stack_template.dart';
import 'package:dayapp/sharing/templates/scrapbook_template.dart';
import 'package:flutter/material.dart';

class StoryShareWidget extends StatelessWidget {
  final StoryData story;

  const StoryShareWidget({required this.story, super.key});

  @override
  Widget build(BuildContext context) {
    final selectedTemplate = StoryShareTemplateSelector.selectTemplate(story);
    return _buildTemplate(context, selectedTemplate);
  }

  Widget _buildTemplate(
    BuildContext context,
    StoryShareTemplateType templateType,
  ) {
    switch (templateType) {
      case StoryShareTemplateType.heroMemory:
        return HeroMemoryTemplate(story: story);
      case StoryShareTemplateType.polaroidStack:
        return PolaroidStackTemplate(story: story);
      case StoryShareTemplateType.scrapbook:
        return ScrapbookTemplate(story: story);
      case StoryShareTemplateType.minimalTimeline:
        return MinimalTimelineTemplate(story: story);
    }
  }
}
