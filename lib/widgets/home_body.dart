import 'package:dayapp/providers/home_layout_provider.dart';
import 'package:dayapp/screens/groups_screen.dart';
import 'package:dayapp/screens/home_content.dart';
import 'package:dayapp/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeBody extends StatelessWidget {
  final int selectedIndex;
  final int collectionsTabIndex;
  final ValueChanged<int> onCollectionsTabChanged;

  const HomeBody({
    required this.selectedIndex,
    required this.collectionsTabIndex,
    required this.onCollectionsTabChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: selectedIndex,
      children: [
        HomeContent(
          isCardView: context.select<HomeLayoutProvider, bool>(
            (provider) => provider.isCardView,
          ),
        ),
        GroupsScreen(onTabChanged: onCollectionsTabChanged),
        const SearchScreen(),
      ],
    );
  }
}
