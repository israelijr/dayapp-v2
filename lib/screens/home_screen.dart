import 'dart:io';

import 'package:dayapp/helpers/route_transition_helper.dart';
import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:dayapp/screens/create_historia_screen.dart';
import 'package:dayapp/widgets/pulse_animation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/database_helper.dart';
import '../providers/auth_provider.dart';
import '../providers/pin_provider.dart';
import '../theme/animation_durations.dart';
import 'edit_profile_screen.dart';
import 'groups_maintenance_screen.dart';
import 'groups_screen.dart';
import 'home_content.dart';
import 'search_screen.dart';

enum _HomeHeaderMenuAction { viewLarge, viewCompact, toggleChapterCard }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isCardView = true;
  bool _showChapterShortcutCard = true;

  // ScaffoldMessenger local — snackbars ficam escopados à HomeScreen e
  // são descartados automaticamente ao navegar para outra rota (ex: logout).
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  // Flag estática para garantir que a sugestão de backup seja mostrada
  // apenas uma vez por inicialização do app.
  static bool _backupSuggestionShown = false;
  static const String _prefKeyIsCardView = 'home_isCardView';
  static const String _prefKeyShowChapterCard = 'home_show_chapter_card';

  @override
  void initState() {
    super.initState();
    _loadLayoutPreference();
    _loadChapterCardPreference();
    // Executar a checagem de histórias não salvas apenas na primeira
    // construção após o carregamento do app.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_backupSuggestionShown) {
        _checkUnsavedStories();
        _backupSuggestionShown = true;
      }
    });
  }

  Future<void> _checkUnsavedStories() async {
    // Pequeno delay para não competir com o carregamento inicial
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    try {
      final db = await DatabaseHelper().database;
      final res = await db.rawQuery(
        'SELECT COUNT(*) as cnt FROM historia WHERE (backed_up IS NULL OR backed_up = 0) AND excluido IS NULL',
      );
      final cnt = (res.first['cnt'] ?? 0) as int;
      if (cnt > 0 && mounted) {
        // Mostrar diálogo amigável com imagem e opções
        showDialog<void>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Imagem amigável para sugerir backup
                  Image.asset(
                    'assets/image/Fazendo backup de maneira amigável.png',
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.unsavedBackups(cnt),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.backupRecommendation,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.pushNamed(context, '/backup-manager');
                  },
                  child: Text(AppLocalizations.of(context)!.performBackup),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Falha não crítica para a experiência inicial, mas útil para diagnóstico.
      debugPrint('HomeScreen: erro durante checagem inicial de backup: $e');
    }
  }

  Future<void> _loadLayoutPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getBool(_prefKeyIsCardView);
      if (val != null) {
        setState(() {
          _isCardView = val;
        });
      }
    } catch (e) {
      // Mantém padrão de layout em caso de falha de leitura.
      debugPrint('HomeScreen: erro ao carregar preferência de layout: $e');
    }
  }

  Future<void> _saveLayoutPreference(bool isCard) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyIsCardView, isCard);
    } catch (e) {
      // Falha de persistência não deve quebrar a navegação.
      debugPrint('HomeScreen: erro ao salvar preferência de layout: $e');
    }
  }

  Future<void> _loadChapterCardPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getBool(_prefKeyShowChapterCard);
      if (val != null) {
        setState(() {
          _showChapterShortcutCard = val;
        });
      }
    } catch (e) {
      // Mantém padrão de card em caso de falha de leitura.
      debugPrint(
        'HomeScreen: erro ao carregar preferência de card de capítulos: $e',
      );
    }
  }

  Future<void> _saveChapterCardPreference(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyShowChapterCard, value);
    } catch (e) {
      // Falha de persistência não deve quebrar o fluxo.
      debugPrint(
        'HomeScreen: erro ao salvar preferência de card de capítulos: $e',
      );
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
    final isCompactHeader = MediaQuery.sizeOf(context).width < 390;

    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset('assets/icon/icon.png', width: 32, height: 32),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  _selectedIndex == 0
                      ? l10n.appTitle
                      : _selectedIndex == 1
                      ? l10n.manageGroups
                      : l10n.search,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSerif(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            // Só mostra os botões de visualização na aba Home
            if (_selectedIndex == 0 && isCompactHeader) ...[
              IconButton(
                tooltip: l10n.homeHeaderOpenCalendarTooltip,
                onPressed: () => Navigator.pushNamed(context, '/calendar'),
                icon: const Icon(Icons.calendar_month_rounded),
              ),
              IconButton(
                tooltip: l10n.chaptersTitle,
                onPressed: () => Navigator.pushNamed(context, '/chapters'),
                icon: const Icon(Icons.auto_stories_outlined),
              ),
              PopupMenuButton<_HomeHeaderMenuAction>(
                tooltip: l10n.moreOptions,
                onSelected: (action) {
                  switch (action) {
                    case _HomeHeaderMenuAction.viewLarge:
                      setState(() {
                        _isCardView = true;
                      });
                      _saveLayoutPreference(true);
                      break;
                    case _HomeHeaderMenuAction.viewCompact:
                      setState(() {
                        _isCardView = false;
                      });
                      _saveLayoutPreference(false);
                      break;
                    case _HomeHeaderMenuAction.toggleChapterCard:
                      setState(() {
                        _showChapterShortcutCard = !_showChapterShortcutCard;
                      });
                      _saveChapterCardPreference(_showChapterShortcutCard);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  CheckedPopupMenuItem<_HomeHeaderMenuAction>(
                    value: _HomeHeaderMenuAction.viewLarge,
                    checked: _isCardView,
                    child: Text(l10n.homeHeaderLargeCards),
                  ),
                  CheckedPopupMenuItem<_HomeHeaderMenuAction>(
                    value: _HomeHeaderMenuAction.viewCompact,
                    checked: !_isCardView,
                    child: Text(l10n.homeHeaderCompactCards),
                  ),
                  const PopupMenuDivider(),
                  CheckedPopupMenuItem<_HomeHeaderMenuAction>(
                    value: _HomeHeaderMenuAction.toggleChapterCard,
                    checked: _showChapterShortcutCard,
                    child: Text(l10n.chapterShortcutToggle),
                  ),
                ],
              ),
            ] else if (_selectedIndex == 0)
              Builder(
                builder: (context) {
                  const duration = AppDurations.listSwitch;
                  Widget buildToggle(
                    IconData icon,
                    bool active,
                    String tooltip,
                    VoidCallback onTap,
                  ) {
                    final colorScheme = Theme.of(context).colorScheme;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Tooltip(
                        message: tooltip,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            onTap();
                          },
                          child: AnimatedContainer(
                            duration: duration,
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: active
                                  ? colorScheme.secondary.withValues(
                                      alpha: 0.14,
                                    )
                                  : const Color(0x00000000),
                              borderRadius: BorderRadius.circular(8),
                              border: active
                                  ? Border.all(
                                      color: colorScheme.secondary,
                                      width: 1.2,
                                    )
                                  : null,
                            ),
                            child: AnimatedScale(
                              duration: duration,
                              curve: Curves.easeOutBack,
                              scale: active ? 1.05 : 1.0,
                              child: Icon(
                                icon,
                                size: 28,
                                color: active
                                    ? colorScheme.secondary
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return Row(
                    children: [
                      buildToggle(
                        Icons.view_agenda_rounded,
                        _isCardView,
                        l10n.homeHeaderLargeCards,
                        () {
                          setState(() {
                            _isCardView = true;
                          });
                          _saveLayoutPreference(true);
                        },
                      ),
                      buildToggle(
                        Icons.grid_view_rounded,
                        !_isCardView,
                        l10n.homeHeaderCompactCards,
                        () {
                          setState(() {
                            _isCardView = false;
                          });
                          _saveLayoutPreference(false);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            Navigator.pushNamed(context, '/calendar');
                          },
                          child: Tooltip(
                            message: l10n.homeHeaderOpenCalendarTooltip,
                            child: AnimatedContainer(
                              duration: duration,
                              curve: Curves.easeInOut,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.calendar_month_rounded,
                                size: 28,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            Navigator.pushNamed(context, '/chapters');
                          },
                          child: Tooltip(
                            message: l10n.chaptersTitle,
                            child: AnimatedContainer(
                              duration: duration,
                              curve: Curves.easeInOut,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.auto_stories_outlined,
                                size: 28,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            setState(() {
                              _showChapterShortcutCard =
                                  !_showChapterShortcutCard;
                            });
                            _saveChapterCardPreference(
                              _showChapterShortcutCard,
                            );
                          },
                          child: Tooltip(
                            message: l10n.chapterShortcutToggle,
                            child: AnimatedContainer(
                              duration: duration,
                              curve: Curves.easeInOut,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _showChapterShortcutCard
                                    ? Theme.of(context).colorScheme.secondary
                                          .withValues(alpha: 0.14)
                                    : const Color(0x00000000),
                                borderRadius: BorderRadius.circular(8),
                                border: _showChapterShortcutCard
                                    ? Border.all(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                        width: 1.2,
                                      )
                                    : null,
                              ),
                              child: Icon(
                                _showChapterShortcutCard
                                    ? Icons.toggle_on_outlined
                                    : Icons.toggle_off_outlined,
                                size: 28,
                                color: _showChapterShortcutCard
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Builder(
                  builder: (context) {
                    final user = Provider.of<AuthProvider>(context).user;
                    ImageProvider profileImage;
                    if (user != null &&
                        user.fotoPerfil != null &&
                        user.fotoPerfil!.isNotEmpty) {
                      final fp = user.fotoPerfil!;
                      if (fp.startsWith('http') || fp.startsWith('https')) {
                        profileImage = NetworkImage(fp);
                      } else {
                        try {
                          final file = File(fp);
                          if (file.existsSync()) {
                            profileImage = FileImage(file);
                          } else {
                            profileImage = const AssetImage(
                              'assets/image/icon.png',
                            );
                          }
                        } catch (e) {
                          debugPrint(
                            'HomeScreen: erro ao carregar imagem de perfil local, usando fallback: $e',
                          );
                          profileImage = const AssetImage(
                            'assets/image/icon.png',
                          );
                        }
                      }
                    } else {
                      profileImage = const AssetImage('assets/image/icon.png');
                    }

                    return Row(
                      children: [
                        Image.asset(
                          'assets/icon/icon.png',
                          width: 48,
                          height: 48,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'DayApp',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                user?.nome ?? '',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),
                              Text(
                                user?.email ?? '',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Mostrar foto ampliada em um diálogo
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  backgroundColor: const Color(0x00000000),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Container(
                                          constraints: BoxConstraints(
                                            maxWidth:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.9,
                                            maxHeight:
                                                MediaQuery.of(
                                                  context,
                                                ).size.height *
                                                0.9,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child:
                                                user?.fotoPerfil != null &&
                                                    user!.fotoPerfil!.isNotEmpty
                                                ? (user.fotoPerfil!.startsWith(
                                                            'http',
                                                          ) ||
                                                          user.fotoPerfil!
                                                              .startsWith(
                                                                'https',
                                                              )
                                                      ? Image.network(
                                                          user.fotoPerfil!,
                                                          fit: BoxFit.contain,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return Image.asset(
                                                                  'assets/image/icon.png',
                                                                  fit: BoxFit
                                                                      .contain,
                                                                );
                                                              },
                                                        )
                                                      : (File(
                                                              user.fotoPerfil!,
                                                            ).existsSync()
                                                            ? Image.file(
                                                                File(
                                                                  user.fotoPerfil!,
                                                                ),
                                                                fit: BoxFit
                                                                    .contain,
                                                              )
                                                            : Image.asset(
                                                                'assets/image/icon.png',
                                                                fit: BoxFit
                                                                    .contain,
                                                              )))
                                                : Image.asset(
                                                    'assets/image/icon.png',
                                                    fit: BoxFit.contain,
                                                  ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                            size: 30,
                                          ),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: CircleAvatar(
                            radius: 24,
                            backgroundImage: profileImage,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(AppLocalizations.of(context)!.editProfile),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.group),
                title: Text(AppLocalizations.of(context)!.manageGroups),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GroupsMaintenanceScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.history_outlined),
                title: Text(AppLocalizations.of(context)!.insightHistoryTitle),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/insight-history');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(AppLocalizations.of(context)!.trash),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/trash');
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: Text(AppLocalizations.of(context)!.help),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/help');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text(AppLocalizations.of(context)!.settings),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(AppLocalizations.of(context)!.about),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/about');
                },
              ),

              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(AppLocalizations.of(context)!.logout),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final auth = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  final pinProvider = Provider.of<PinProvider>(
                    context,
                    listen: false,
                  );

                  // Fecha o drawer antes de iniciar o logout
                  navigator.pop();

                  await auth.logout();
                  pinProvider.updateUserLoginStatus(false);
                  if (!mounted) return;
                  navigator.pushReplacementNamed('/login');
                },
              ),
            ],
          ),
        ),
        body: _selectedIndex == 0
            ? HomeContent(
                isCardView: _isCardView,
                showChapterShortcutCard: _showChapterShortcutCard,
              )
            : _selectedIndex == 1
            ? const GroupsScreen()
            : const SearchScreen(),
        // Mostra o FAB apenas nas abas Home e Grupos
        floatingActionButton: _selectedIndex != 2
            ? PulseAnimation(
                scaleTarget: 1.06,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      RouteTransitionHelper.slideUpRotateTransition(
                        const CreateHistoriaScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: Text(AppLocalizations.of(context)!.newStory),
                ),
              )
            : null,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: AppLocalizations.of(context)!.home,
            ),
            NavigationDestination(
              icon: const Icon(Icons.group_outlined),
              selectedIcon: const Icon(Icons.group),
              label: AppLocalizations.of(context)!.groups,
            ),
            NavigationDestination(
              icon: const Icon(Icons.search_outlined),
              selectedIcon: const Icon(Icons.search),
              label: AppLocalizations.of(context)!.search,
            ),
          ],
        ),
      ), // Scaffold
    ); // ScaffoldMessenger
  }
}
