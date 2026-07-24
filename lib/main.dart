import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:dayapp/helpers/route_transition_helper.dart';
import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'db/database_helper.dart';
import 'models/historia.dart';
import 'providers/auth_provider.dart';
import 'providers/birthday_provider.dart';
import 'providers/chapter_filter_provider.dart';
import 'providers/continuity_hook_provider.dart';
import 'providers/home_layout_provider.dart';
import 'providers/home_stories_provider.dart';
import 'providers/insight_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/notification_preferences_provider.dart';
import 'providers/pin_provider.dart';
import 'providers/premium_provider.dart';
import 'providers/refresh_provider.dart';
import 'providers/scroll_position_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/theme_provider.dart';
import 'repositories/capitulo_repository.dart';
import 'repositories/group_repository.dart';
import 'repositories/historia_repository.dart';
import 'screens/about_screen.dart';
import 'screens/backup_manager_screen.dart';
import 'screens/calendar_view_screen.dart';
import 'screens/chapters_entry_screen.dart';
import 'screens/create_account_complement_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/create_historia_screen.dart';
import 'screens/edit_historia_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/help_screen.dart';
import 'screens/home_screen.dart';
import 'screens/insight_history_screen.dart';
import 'screens/login_screen.dart';
import 'screens/password_recovery_screen.dart';
import 'screens/pin_recovery_screen.dart';
import 'screens/premium_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/story_share_debug_screen.dart';
import 'screens/trash_screen.dart';
import 'services/engagement_service.dart';
import 'services/inactivity_service.dart';
import 'services/notification_service.dart';
import 'services/purchase_service.dart';
import 'theme/custom_color_schemes.dart';
import 'theme/m3_expressive_theme.dart';
import 'widgets/global_lock_overlay.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Habilita o modo edge-to-edge no Flutter para compatibilidade com Android 15+
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  GoogleFonts.config.allowRuntimeFetching = false;

  // Captura erros do framework Flutter (UI)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FLUTTER GLOBAL ERROR: ${details.exceptionAsString()}');
    debugPrint('STACK TRACE: ${details.stack}');
  };

  // Captura erros assíncronos fora do framework Flutter
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('PLATFORM GLOBAL ERROR: $error');
    debugPrint('STACK TRACE: $stack');
    return true; // Indica que o erro foi tratado
  };

  // Inicializa a factory do banco de dados conforme a plataforma
  if (kIsWeb) {
    // Web usa IndexedDB via sqflite_common_ffi_web
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Desktop usa FFI nativo
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Inicialização de data/hora para todos os locales suportados pelo app
  await Future.wait([
    initializeDateFormatting('pt_BR', null),
    initializeDateFormatting('en_US', null),
    initializeDateFormatting('es_ES', null),
    initializeDateFormatting('fr_FR', null),
    initializeDateFormatting('it_IT', null),
  ]);

  // Antes de rodar o app, tenta ler a preferência de idioma para poder usar
  // essa escolha já na splash. Isso evita que o app mostre português na
  // primeira tela quando o sistema está em pt, mesmo que o usuário tenha
  // configurado inglês.
  Locale? initialLocale;
  const localePrefKey = 'app_locale_selection';
  try {
    final prefs = await SharedPreferences.getInstance();
    final sel = prefs.getString(localePrefKey);
    if (sel != null && sel != 'system') {
      final normalized = sel.contains('_') ? sel.split('_').first : sel;
      switch (normalized) {
        case 'en':
          initialLocale = const Locale('en', 'US');
          break;
        case 'es':
          initialLocale = const Locale('es', 'ES');
          break;
        case 'pt':
          initialLocale = const Locale('pt', 'BR');
          break;
      }
    }
  } catch (_) {
    // falhar lendo prefs não é crítico
  }

  runApp(AppLoader(initialLocale: initialLocale));
}

/// Widget que carrega o app de forma assíncrona
/// Mostra a splash screen enquanto inicializa os providers
class AppLoader extends StatefulWidget {
  /// [initialLocale] é usado apenas na primeira MaterialApp que mostra
  /// a splash. Ele é pré-carregado de SharedPreferences antes de chamar
  /// runApp para evitar que o app comece em pt quando o sistema estiver em
  /// português.
  final Locale? initialLocale;

  const AppLoader({this.initialLocale, super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  late Future<AppInitData> _initFuture;

  /// Payload de notificação aguardando o navigator estar pronto (cold start).
  String? _pendingNotificationPayload;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeApp();
  }

  /// Inicializa todos os providers e serviços necessários
  Future<AppInitData> _initializeApp() async {
    // Dá um pequeno tempo para a engine do Flutter registrar todos os plugins
    // nativos antes de tentarmos acessar o FlutterSecureStorage.
    // Isso resolve o MissingPluginException em alguns dispositivos na Play Store.
    await Future.delayed(const Duration(milliseconds: 500));

    // Inicializar AuthProvider e tentar auto-login
    final authProvider = AuthProvider();
    try {
      await authProvider.tryAutoLogin();
    } catch (e) {
      debugPrint('Erro no auto-login: $e');
    }

    // Limpa automaticamente histórias expiradas da lixeira (30 dias).
    await DatabaseHelper().deleteExpiredTrashStories(
      userId: authProvider.user?.id,
    );

    // Inicializar ThemeProvider
    final themeProvider = ThemeProvider();
    await themeProvider.waitForLoad();

    // Inicializar RefreshProvider
    final refreshProvider = RefreshProvider();

    // Inicializar PinProvider (passa o status de login do usuário)
    final pinProvider = PinProvider();
    await pinProvider.initialize(isUserLoggedIn: authProvider.isLoggedIn);

    // Inicializar LocaleProvider (carrega preferência de idioma)
    final localeProvider = LocaleProvider();
    await localeProvider.load();

    // Inicializar PremiumProvider e vincular ao PurchaseService para atualizações em tempo real
    final premiumProvider = PremiumProvider();
    await premiumProvider.load();
    PurchaseService().initialize(onPurchaseSuccess: () {
      premiumProvider.load();
    });
    unawaited(PurchaseService().restorePurchases());

    // Inicializar notificações primeiro para evitar corrida com agendamentos
    await NotificationService().init((String? payload) async {
      if (payload != null) {
        // Verifica se é uma notificação de engajamento
        if (payload == 'engagement') {
          await EngagementService().registerAppUsage();
          return;
        }

        // Se o navigator ainda não está pronto (app reiniciando), guarda o
        // payload para navegar após a inicialização completar.
        if (navigatorKey.currentState == null) {
          if (mounted) setState(() => _pendingNotificationPayload = payload);
          return;
        }

        // Notificação de história - tenta abrir a história específica
        final int? historiaId = int.tryParse(payload);
        if (historiaId != null) {
          final Historia? historia = await DatabaseHelper().getHistoria(
            historiaId,
          );
          if (historia != null) {
            navigatorKey.currentState?.push(
              RouteTransitionHelper.slideUpRotateTransition(
                EditHistoriaScreen(historia: historia),
              ),
            );
          }
        }
      }
    });

    // Registra uso do app após inicializar notificações
    await EngagementService().registerAppUsage();

    // Verifica se o app foi iniciado por um toque em notificação (cold start).
    // Nesse caso, onDidReceiveNotificationResponse não é chamado; o payload
    // precisa ser recuperado aqui e aplicado após o navigator estar pronto.
    final coldStartPayload = await NotificationService()
        .getPendingLaunchPayload();
    if (coldStartPayload != null) {
      if (coldStartPayload == 'engagement') {
        await EngagementService().registerAppUsage();
      } else {
        _pendingNotificationPayload = coldStartPayload;
      }
    }

    return AppInitData(
      authProvider: authProvider,
      themeProvider: themeProvider,
      refreshProvider: refreshProvider,
      pinProvider: pinProvider,
      localeProvider: localeProvider,
      premiumProvider: premiumProvider,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppInitData>(
      future: _initFuture,
      builder: (context, snapshot) {
        // Enquanto carrega, mostra a splash screen bonita com animações
        // A native splash (cor sólida) já foi removida, agora mostramos a splash do Flutter
        // Aqui não temos acesso ainda ao LocaleProvider carregado, portanto
        // aplicamos o idioma do sistema (caso esteja diferenciado) para que o
        // texto inicial não apareça sempre em português. Se um locale inicial
        // foi fornecido pelo widget (lido antes do runApp), usamos ele em vez
        // do padrão do sistema.
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: M3ExpressiveTheme.getLightTheme(),
            darkTheme: M3ExpressiveTheme.getDarkTheme(),
            // Configurações de localidade semelhantes às do app principal,
            // porém usando o locale fornecido ou o sistema.
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              FlutterQuillLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: widget.initialLocale ?? PlatformDispatcher.instance.locale,
            home: const SplashScreen(),
          );
        }

        // Se houve erro na inicialização
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: M3ExpressiveTheme.getLightTheme(),
            darkTheme: M3ExpressiveTheme.getDarkTheme(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              FlutterQuillLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: PlatformDispatcher.instance.locale,
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.errorInitializingApp,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      Text('${snapshot.error}', textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _initFuture = _initializeApp();
                          });
                        },
                        child: Text(AppLocalizations.of(context)!.tryAgain),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Inicialização completa - carrega o app principal
        final data = snapshot.data!;

        // Se houver payload pendente de notificação (cold start), navega após
        // o frame ser pintado para garantir que o navigator já está montado.
        if (_pendingNotificationPayload != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final payload = _pendingNotificationPayload;
            if (payload == null || !mounted) return;
            setState(() => _pendingNotificationPayload = null);

            final int? historiaId = int.tryParse(payload);
            if (historiaId != null) {
              final Historia? historia = await DatabaseHelper().getHistoria(
                historiaId,
              );
              if (historia != null && mounted) {
                navigatorKey.currentState?.push(
                  RouteTransitionHelper.slideUpRotateTransition(
                    EditHistoriaScreen(historia: historia),
                  ),
                );
              }
            }
          });
        }

        return MyApp(
          authProvider: data.authProvider,
          themeProvider: data.themeProvider,
          refreshProvider: data.refreshProvider,
          pinProvider: data.pinProvider,
          localeProvider: data.localeProvider,
          premiumProvider: data.premiumProvider,
        );
      },
    );
  }
}

/// Classe para armazenar os dados inicializados
class AppInitData {
  final AuthProvider authProvider;
  final ThemeProvider themeProvider;
  final RefreshProvider refreshProvider;
  final PinProvider pinProvider;
  final LocaleProvider localeProvider;
  final PremiumProvider premiumProvider;

  AppInitData({
    required this.authProvider,
    required this.themeProvider,
    required this.refreshProvider,
    required this.pinProvider,
    required this.localeProvider,
    required this.premiumProvider,
  });
}

class MyApp extends StatefulWidget {
  final AuthProvider authProvider;
  final ThemeProvider themeProvider;
  final RefreshProvider refreshProvider;
  final PinProvider pinProvider;
  final LocaleProvider localeProvider;
  final PremiumProvider premiumProvider;

  const MyApp({
    required this.authProvider,
    required this.themeProvider,
    required this.refreshProvider,
    required this.pinProvider,
    required this.localeProvider,
    required this.premiumProvider,
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final InactivityService _inactivityService = InactivityService();
  DateTime? _pausedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Garante que o estado do PIN seja notificado após o widget estar montado
    // Isso força o PinProtectedWrapper a reagir ao estado inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.pinProvider.shouldShowPinScreen) {
        // Força uma notificação para garantir que os listeners reajam
        widget.pinProvider.requireAuthentication();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkBackgroundLock() async {
    if (_pausedTime == null) return;

    debugPrint(
      'LOCK: _checkBackgroundLock chamado, isPickingExternalMedia=${widget.pinProvider.isPickingExternalMedia}, isAttachingMedia=${widget.pinProvider.isAttachingMedia}',
    );

    if (widget.pinProvider.isAuthenticatingWithBiometrics) {
      debugPrint(
        'LOCK: Ignorando bloqueio - isAuthenticatingWithBiometrics=true',
      );
      _pausedTime = null;
      return;
    }

    // Verifica o tempo em segundo plano
    final pauseDuration = DateTime.now().difference(_pausedTime!);
    final backgroundTimeoutSeconds = await _inactivityService
        .getBackgroundLockTimeout();

    // Nunca bloquear quando o valor for -1
    if (backgroundTimeoutSeconds == InactivityService.neverLockValue) {
      debugPrint('LOCK: Ignorando bloqueio - configurado para nunca bloquear');
      _pausedTime = null;
      return;
    }

    var backgroundTimeout = Duration(seconds: backgroundTimeoutSeconds);
    
    // Adiciona tolerância de 30 segundos se estiver selecionando mídia externa ou anexando mídia
    final isAttaching = widget.pinProvider.isPickingExternalMedia || widget.pinProvider.isAttachingMedia;
    if (isAttaching) {
      backgroundTimeout += const Duration(seconds: 30);
      debugPrint(
        'LOCK: Adicionando tolerância de 30 segundos. Timeout total: ${backgroundTimeout.inSeconds}s',
      );
    }

    // Bloqueia se o tempo de pausa excedeu o configurado
    if (pauseDuration > backgroundTimeout) {
      debugPrint('LOCK: Chamando requireAuthentication(force: true)');
      widget.pinProvider.requireAuthentication(force: true);
    }

    _pausedTime = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    debugPrint(
      'LIFECYCLE: $state, isPickingExternalMedia=${widget.pinProvider.isPickingExternalMedia}, isAttachingMedia=${widget.pinProvider.isAttachingMedia}',
    );

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // App foi para background ou perdeu foco.
        // Usamos ??= para registrar apenas o primeiro evento de perda de foco
        // e evitar sobrescrever o tempo original com transições subsequentes
        // ou transições que ocorrem no retorno para o primeiro plano.
        _pausedTime ??= DateTime.now();
        break;
      case AppLifecycleState.resumed:
        // Registra uso do app para notificações de engajamento
        EngagementService().registerAppUsage();

        // App voltou para foreground
        if (_pausedTime != null) {
          if (widget.pinProvider.isLockEnabled) {
            // Se estiver autenticando com biometria, não bloqueia
            if (widget.pinProvider.isAuthenticatingWithBiometrics) {
              debugPrint(
                'LIFECYCLE: Ignorando - isAuthenticatingWithBiometrics=true',
              );
              widget.pinProvider.isAuthenticatingWithBiometrics = false;
              _pausedTime = null;
              return;
            }

            debugPrint('LIFECYCLE: Chamando _checkBackgroundLock');
            _checkBackgroundLock();
          } else {
            // Se o bloqueio não estiver ativo, limpa o timer antigo para evitar lixo
            _pausedTime = null;
          }
        }
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.authProvider),
        ChangeNotifierProxyProvider<AuthProvider, BirthdayProvider>(
          create: (context) => BirthdayProvider(
            authProvider: context.read<AuthProvider>(),
          ),
          update: (context, authProvider, previous) {
            if (previous == null ||
                previous.userId != authProvider.user?.id ||
                previous.birthDate != authProvider.user?.dtNascimento) {
              return BirthdayProvider(authProvider: authProvider);
            }
            return previous;
          },
        ),
        ChangeNotifierProvider.value(value: widget.themeProvider),
        ChangeNotifierProvider.value(value: widget.refreshProvider),
        ChangeNotifierProvider.value(value: widget.localeProvider),
        ChangeNotifierProvider(
          create: (context) => HomeStoriesProvider(
            repository: HistoriaRepository(),
            authProvider: context.read<AuthProvider>(),
            refreshProvider: context.read<RefreshProvider>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => StatsProvider(
            historiaRepository: HistoriaRepository(),
            capituloRepository: CapituloRepository(),
            groupRepository: GroupRepository(),
            authProvider: context.read<AuthProvider>(),
          ),
        ),
        // Provider para insights automáticos do feed da Home
        ChangeNotifierProvider(create: (_) => InsightProvider()),
        ChangeNotifierProvider.value(value: widget.pinProvider),
        ChangeNotifierProvider(
          create: (_) => NotificationPreferencesProvider()..load(),
        ),
        // Provider para controle de plano Free/Premium
        ChangeNotifierProvider.value(value: widget.premiumProvider),
        // Provider para manter o modo de layout da Home (card/list)
        ChangeNotifierProvider(create: (_) => HomeLayoutProvider()),
        // Provider para manter posição do scroll em listas
        ChangeNotifierProvider(create: (_) => ScrollPositionProvider()),
        ChangeNotifierProvider(create: (_) => ChapterFilterProvider()),
        // Provider para o Motor de Ganchos de Continuidade
        ChangeNotifierProvider(create: (_) => ContinuityHookProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          // Determina os ThemeData a partir do esquema selecionado (se houver)
          ThemeData lightTheme = M3ExpressiveTheme.getLightTheme();
          ThemeData darkTheme = M3ExpressiveTheme.getDarkTheme();

          final schemeFamilyKey = themeProvider.selectedSchemeKey;
          if (schemeFamilyKey != null) {
            final ColorScheme? lightScheme =
                CustomColorSchemes.getSchemeForFamily(
                  schemeFamilyKey,
                  Brightness.light,
                );
            if (lightScheme != null) {
              lightTheme = M3ExpressiveTheme.buildTheme(lightScheme);
            }

            final ColorScheme? darkScheme =
                CustomColorSchemes.getSchemeForFamily(
                  schemeFamilyKey,
                  Brightness.dark,
                );
            if (darkScheme != null) {
              darkTheme = M3ExpressiveTheme.buildTheme(darkScheme);
            }
          }

          // DEBUG: verificar qual locale está sendo usado pelo MaterialApp
          debugPrint(
            'MaterialApp localeProvider.locale=${localeProvider.locale?.toString() ?? 'null'} system=${PlatformDispatcher.instance.locale}',
          );

          return MaterialApp(
            title: AppLocalizations.of(context)?.appTitle ?? 'DayApp',
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            // Localizações geradas (ARB)
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              FlutterQuillLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            // Quando `locale` é null, o app usa o padrão do dispositivo
            // Mas no momento da construção o sistema já está disponível, então
            // deixamos explícito para evitar confusão em cenários estranhos.
            locale: localeProvider.locale ?? PlatformDispatcher.instance.locale,
            // Overlay global de bloqueio - preserva estado de todas as telas
            builder: (context, child) {
              return GlobalLockOverlay(child: child ?? const SizedBox.shrink());
            },
            // Vai direto para home ou login (splash já foi mostrada durante carregamento)
            initialRoute: widget.authProvider.isLoggedIn ? '/home' : '/login',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/password_recovery': (context) => const PasswordRecoveryScreen(),
              '/pin_recovery': (context) => const PinRecoveryScreen(),
              '/create_account': (context) => const CreateAccountScreen(),
              '/create_account_complement': (context) =>
                  const CreateAccountComplementScreen(),
              '/home': (context) => const HomeScreen(),
              '/create_historia': (context) => const CreateHistoriaScreen(),
              '/edit_profile': (context) => const EditProfileScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/help': (context) => const HelpScreen(),
              '/calendar': (context) => const CalendarViewScreen(),
              '/chapters': (context) => const ChaptersEntryScreen(),
              '/about': (context) => const AboutScreen(),
              '/backup-manager': (context) => const BackupManagerScreen(),
              '/trash': (context) => const TrashScreen(),
              '/search': (context) => const SearchScreen(),
              '/premium': (context) => const PremiumScreen(),
              '/insight-history': (context) => const InsightHistoryScreen(),
              '/story-share-debug': (context) => const StoryShareDebugScreen(),
            },
          );
        },
      ),
    );
  }
}

// This widget is the home page of your application. It is stateful, meaning
// that it has a State object (defined below) that contains fields that affect
// how it looks and behaves.
