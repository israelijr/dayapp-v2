import 'package:dayapp/widgets/pulse_animation.dart';
import 'package:flutter/material.dart';

class HomeFab extends StatelessWidget {
  final int selectedIndex;
  final int collectionsTabIndex;
  final VoidCallback onCreateStory;
  final VoidCallback onCreateChapter;
  final String newStoryLabel;
  final String chapterCreateTitle;

  const HomeFab({
    required this.selectedIndex,
    required this.collectionsTabIndex,
    required this.onCreateStory,
    required this.onCreateChapter,
    required this.newStoryLabel,
    required this.chapterCreateTitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedIndex == 2 ||
        (selectedIndex != 0 && collectionsTabIndex != 0)) {
      return const SizedBox.shrink();
    }

    return PulseAnimation(
      scaleTarget: 1.06,
      child: FloatingActionButton.extended(
        onPressed: selectedIndex == 0 ? onCreateStory : onCreateChapter,
        icon: const Icon(Icons.add),
        label: Text(selectedIndex == 0 ? newStoryLabel : chapterCreateTitle),
      ),
    );
  }
}
