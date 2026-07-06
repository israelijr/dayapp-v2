import 'package:dayapp/widgets/pulse_animation.dart';
import 'package:flutter/material.dart';

class HomeFab extends StatelessWidget {
  final int selectedIndex;
  final int collectionsTabIndex;
  final VoidCallback onCreateChapter;
  final VoidCallback onCreateGroup;
  final String chapterCreateTitle;
  final String newGroupLabel;

  const HomeFab({
    required this.selectedIndex,
    required this.collectionsTabIndex,
    required this.onCreateChapter,
    required this.onCreateGroup,
    required this.chapterCreateTitle,
    required this.newGroupLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedIndex == 2) {
      return const SizedBox.shrink();
    }

    final isHome = selectedIndex == 0;
    final isCollections = selectedIndex == 1;
    final isChaptersTab = isCollections && collectionsTabIndex == 0;
    final isGroupsTab = isCollections && collectionsTabIndex == 1;

    if (isHome || (!isChaptersTab && !isGroupsTab)) {
      return const SizedBox.shrink();
    }

    final onPressed = isChaptersTab ? onCreateChapter : onCreateGroup;
    final label = isChaptersTab ? chapterCreateTitle : newGroupLabel;

    return PulseAnimation(
      scaleTarget: 1.06,
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        icon: const Icon(Icons.add),
        label: Text(label),
      ),
    );
  }
}
