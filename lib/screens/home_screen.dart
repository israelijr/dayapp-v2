import 'dart:io';

import 'package:dayapp/helpers/route_transition_helper.dart';
import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:dayapp/screens/chapters_screen.dart';
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isCardView = true;
  int _collectionsTabIndex = 0;

  // ScaffoldMessenger local — snackbars ficam escopados à HomeScreen e
  // são descartados automaticamente ao navegar para outra rota (ex: logout).
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  // Flag estática para garantir que a sugestão de backup seja mostrada
  // apenas uma vez por inicialização do app.
  static bool _backupSuggestionShown = false;
  static const String _prefKeyIsCardView = 'home_isCardView';

  @override
  void initState() {
    super.initState();
    _loadLayoutPreference();
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
        appBar: AppBar(
          title: Text(
            _selectedIndex == 0
                ? l10n.appTitle
                : _selectedIndex == 1
                ? l10n.collectionsTitle
                : l10n.search,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.notoSerif(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          actions: [
            if (_selectedIndex == 0)
              Builder(
                builder: (context) {
                  const duration = AppDurations.listSwitch;
                  return Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _isCardView = !_isCardView;
                            });
                            _saveLayoutPreference(_isCardView);
                          },
                          icon: Icon(
                            _isCardView
                                ? Icons.grid_view_rounded
                                : Icons.view_agenda_rounded,
                            size: 22,
                          ),
                          tooltip: _isCardView
                              ? l10n.homeHeaderCompactCards
                              : l10n.homeHeaderLargeCards,
                          splashRadius: 24,
                          constraints: const BoxConstraints(
                            minWidth: 38,
                            minHeight: 38,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            Navigator.pushNamed(context, '/calendar');
                          },
                          child: Tooltip(
                            message: l10n.homeHeaderOpenCalendarTooltip,
                            child: AnimatedContainer(
                              duration: duration,
                              curve: Curves.easeInOut,
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.calendar_month_rounded,
                                  size: 22,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
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
            ? HomeContent(isCardView: _isCardView)
            : _selectedIndex == 1
            ? GroupsScreen(onTabChanged: _handleCollectionsTabChanged)
            : const SearchScreen(),
        // Mostra o FAB apenas nas abas Home e, se necessário, na aba Capítulos
        floatingActionButton:
            _selectedIndex != 2 &&
                (_selectedIndex == 0 || _collectionsTabIndex == 0)
            ? PulseAnimation(
                scaleTarget: 1.06,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    if (_selectedIndex == 0) {
                      Navigator.push(
                        context,
                        RouteTransitionHelper.slideUpRotateTransition(
                          const CreateHistoriaScreen(),
                        ),
                      );
                    } else {
                      openCreateChapterScreen(context);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: Text(
                    _selectedIndex == 0
                        ? AppLocalizations.of(context)!.newStory
                        : AppLocalizations.of(context)!.chapterCreateTitle,
                  ),
                ),
              )
            : null,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: [
            NavigationDestination(
              icon: Image.asset(
                'assets/image/home_1.png',
                width: 20,
                height: 20,
              ),
              selectedIcon: Image.asset(
                'assets/image/home_2.png',
                width: 20,
                height: 20,
              ),
              label: AppLocalizations.of(context)!.home,
            ),
            NavigationDestination(
              icon: Image.asset(
                'assets/image/colecao_1.png',
                width: 20,
                height: 20,
              ),
              selectedIcon: Image.asset(
                'assets/image/colecao_2.png',
                width: 20,
                height: 20,
              ),
              label: AppLocalizations.of(context)!.collectionsTitle,
            ),
            NavigationDestination(
              icon: Image.asset(
                'assets/image/pesquisar_1.png',
                width: 20,
                height: 20,
              ),
              selectedIcon: Image.asset(
                'assets/image/pesquisar_2.png',
                width: 20,
                height: 20,
              ),
              label: AppLocalizations.of(context)!.search,
            ),
          ],
        ),
      ), // Scaffold
    ); // ScaffoldMessenger
  }
}
