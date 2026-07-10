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

import '../providers/auth_provider.dart';
import '../providers/birthday_provider.dart';
import '../providers/refresh_provider.dart';
import '../widgets/birthday_dialog.dart';
import 'chapters_screen.dart';
import 'create_group_screen.dart';

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

  BirthdayProvider? _birthdayProvider;
  bool _isBirthdayDialogOpen = false;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Remove listener anterior se existir
    if (_birthdayProvider != null) {
      _birthdayProvider!.removeListener(_onBirthdayProviderChanged);
    }
    
    _birthdayProvider = Provider.of<BirthdayProvider>(context);
    _birthdayProvider!.addListener(_onBirthdayProviderChanged);

    // Se já terminou a checagem e deve mostrar agora, dispara o diálogo após o frame
    if (_birthdayProvider!.shouldShow) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _birthdayProvider != null && _birthdayProvider!.shouldShow) {
          _showBirthdayDialog();
        }
      });
    }
  }

  @override
  void dispose() {
    if (_birthdayProvider != null) {
      _birthdayProvider!.removeListener(_onBirthdayProviderChanged);
    }
    super.dispose();
  }

  void _onBirthdayProviderChanged() {
    if (_birthdayProvider != null && _birthdayProvider!.shouldShow && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _birthdayProvider != null && _birthdayProvider!.shouldShow) {
          _showBirthdayDialog();
        }
      });
    }
  }

  Future<void> _showBirthdayDialog() async {
    if (_isBirthdayDialogOpen) return;
    _isBirthdayDialogOpen = true;

    final provider = _birthdayProvider!;
    final status = provider.status;
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      _isBirthdayDialogOpen = false;
      return;
    }

    // Primeiro marca localmente como mostrado para evitar múltiplos disparos e concorrência
    await provider.markAsShown();
    if (!mounted) {
      _isBirthdayDialogOpen = false;
      return;
    }

    // Exibe o diálogo com animação de abertura premium
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'BirthdayDialog',
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return BirthdayDialog(
          status: status,
          userName: user.nome,
          birthDate: user.dtNascimento!,
        );
      },
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: child,
          ),
        );
      },
    );

    _isBirthdayDialogOpen = false;
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
        // Mostra o FAB apenas nas abas de capítulos ou grupos se necessário
        floatingActionButton: HomeFab(
          selectedIndex: _selectedIndex,
          collectionsTabIndex: _collectionsTabIndex,
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
