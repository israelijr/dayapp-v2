import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class HomeBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const HomeBottomNavigation({
    required this.selectedIndex,
    required this.onItemTapped,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onItemTapped,
      destinations: [
        NavigationDestination(
          icon: const ImageIcon(
            AssetImage('assets/image/home_1.png'),
            size: 20,
          ),
          selectedIcon: const ImageIcon(
            AssetImage('assets/image/home_2.png'),
            size: 20,
          ),
          label: l10n.home,
        ),
        NavigationDestination(
          icon: const ImageIcon(
            AssetImage('assets/image/colecao_1.png'),
            size: 20,
          ),
          selectedIcon: const ImageIcon(
            AssetImage('assets/image/colecao_2.png'),
            size: 20,
          ),
          label: l10n.collectionsTitle,
        ),
        NavigationDestination(
          icon: const ImageIcon(
            AssetImage('assets/image/pesquisar_1.png'),
            size: 20,
          ),
          selectedIcon: const ImageIcon(
            AssetImage('assets/image/pesquisar_2.png'),
            size: 20,
          ),
          label: l10n.search,
        ),
      ],
    );
  }
}
