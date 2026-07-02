import 'package:dayapp/helpers/route_transition_helper.dart';
import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:dayapp/services/backup_service.dart';
import 'package:dayapp/widgets/backup_suggestion_dialog.dart';
import 'package:dayapp/widgets/home_app_bar.dart';
import 'package:dayapp/widgets/home_body.dart';
import 'package:dayapp/widgets/home_bottom_navigation.dart';
import 'package:dayapp/widgets/home_drawer.dart';
import 'package:dayapp/widgets/home_fab.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chapters_screen.dart';
import 'create_group_screen.dart';
import 'create_historia_screen.dart';
import '../providers/refresh_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _collectionsTabIndex = 0;

  // ScaffoldMessenger local — snackbars ficam escopados à HomeScreen e
  // são descartados automaticamente ao navegar para outra rota (ex: logout).
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  // Flag estática para garantir que a sugestão de backup seja mostrada
  // apenas uma vez por inicialização do app.
  static bool _backupSuggestionShown = false;

  @override
  void initState() {
    super.initState();
    // Executar a checagem de histórias não salvas apenas na primeira
    // construção após o carregamento do app.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_backupSuggestionShown) {
        _checkUnsavedStories();
        _backupSuggestionShown = true;
      }
    });
  }

  void _handleCollectionsTabChanged(int index) {
    setState(() => _collectionsTabIndex = index);
  }

  Future<void> _checkUnsavedStories() async {
    // Pequeno delay para não competir com o carregamento inicial
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    try {
      final cnt = await BackupService().countPendingBackupStories();
      if (cnt > 0 && mounted) {
        showDialog<void>(
          context: context,
          builder: (_) {
            return BackupSuggestionDialog(
              pendingCount: cnt,
              onPerformBackup: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/backup-manager');
              },
            );
          },
        );
      }
    } catch (e) {
      // Falha não crítica para a experiência inicial, mas útil para diagnóstico.
      debugPrint('HomeScreen: erro durante checagem inicial de backup: $e');
    }
  }

  // screens list is built dynamically in the body to reflect current view mode

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        appBar: HomeAppBar(
          selectedIndex: _selectedIndex,
          collectionsTabIndex: _collectionsTabIndex,
          onCalendarTap: () => Navigator.pushNamed(context, '/calendar'),
        ),
        drawer: const HomeDrawer(),
        body: HomeBody(
          selectedIndex: _selectedIndex,
          collectionsTabIndex: _collectionsTabIndex,
          onCollectionsTabChanged: _handleCollectionsTabChanged,
        ),
        // Mostra o FAB apenas nas abas Home e, se necessário, na aba Capítulos
        floatingActionButton: HomeFab(
          selectedIndex: _selectedIndex,
          collectionsTabIndex: _collectionsTabIndex,
          onCreateStory: () {
            Navigator.push(
              context,
              RouteTransitionHelper.slideUpRotateTransition(
                const CreateHistoriaScreen(),
              ),
            );
          },
          onCreateChapter: () {
            openCreateChapterScreen(context);
          },
          onCreateGroup: () async {
            final didCreate = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => const CreateGroupScreen(),
              ),
            );

            if (didCreate == true && context.mounted) {
              context.read<RefreshProvider>().refresh();
            }
          },
          newStoryLabel: l10n.newStory,
          chapterCreateTitle: l10n.chapterCreateTitle,
          newGroupLabel: l10n.newGroup,
        ),
        bottomNavigationBar: HomeBottomNavigation(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ), // Scaffold
    ); // ScaffoldMessenger
  }
}
