import 'dart:io';

import 'package:dayapp/db/database_helper.dart';
import 'package:dayapp/l10n/app_localizations.dart';
import 'package:dayapp/models/user.dart';
import 'package:dayapp/providers/auth_provider.dart';
import 'package:dayapp/providers/locale_provider.dart';
import 'package:dayapp/providers/premium_provider.dart';
import 'package:dayapp/providers/refresh_provider.dart';
import 'package:dayapp/providers/theme_provider.dart';
import 'package:dayapp/screens/chapters_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform({
    required this.temporaryPath,
    required this.documentsPath,
  });

  final String temporaryPath;
  final String documentsPath;

  @override
  Future<String?> getTemporaryPath() async => temporaryPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => documentsPath;

  @override
  Future<String?> getApplicationSupportPath() async => documentsPath;

  @override
  Future<String?> getLibraryPath() async => documentsPath;

  @override
  Future<String?> getApplicationCachePath() async => temporaryPath;

  @override
  Future<String?> getExternalStoragePath() async => null;

  @override
  Future<List<String>?> getExternalCachePaths() async => null;

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    return null;
  }

  @override
  Future<String?> getDownloadsPath() async => null;
}

class _FakePremiumProvider extends PremiumProvider {
  @override
  bool get isPremium => true;

  @override
  bool get canUseChapters => true;

  @override
  bool get canUseAutoChapterSuggestion => true;
}

class _FakeAuthProvider extends AuthProvider {
  final User? mockUser;
  _FakeAuthProvider({this.mockUser});

  @override
  User? get user => mockUser;

  @override
  bool get isLoggedIn => mockUser != null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempRoot;
  late Directory documentsDir;
  late PathProviderPlatform originalPlatform;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp('chapters_test_');
    documentsDir = Directory(p.join(tempRoot.path, 'documents'));
    await documentsDir.create(recursive: true);
    originalPlatform = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _FakePathProviderPlatform(
      temporaryPath: tempRoot.path,
      documentsPath: documentsDir.path,
    );

    final dbPath = await getDatabasesPath();
    final dbDir = Directory(dbPath);
    if (await dbDir.exists()) {
      await dbDir.delete(recursive: true);
    }
    await dbDir.create(recursive: true);

    final currentDb = File(p.join(dbPath, 'dayapp.db'));
    if (await currentDb.exists()) {
      await currentDb.delete();
    }

    DatabaseHelper().resetDatabase();

    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() async {
    await DatabaseHelper().resetDatabase();
    PathProviderPlatform.instance = originalPlatform;
    if (await tempRoot.exists()) {
      await tempRoot.delete(recursive: true);
    }
  });

  Widget buildChaptersScreen({required AuthProvider authProvider, required PremiumProvider premiumProvider}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => RefreshProvider()),
        ChangeNotifierProvider.value(value: premiumProvider),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ChaptersScreen(),
      ),
    );
  }

  testWidgets('ChaptersScreen manually create chapter, triggers discard dialog when dirty', (tester) async {
    // 1. Setup Auth and database user/entries
    final testUser = User(
      id: 'test-user',
      nome: 'Test User',
      email: 'test@example.com',
    );
    final auth = _FakeAuthProvider(mockUser: testUser);

    final db = await DatabaseHelper().database;
    await db.insert('users', {
      'id': 'test-user',
      'nome': 'Test User',
      'email': 'test@example.com',
      'senha': 'hashed-password',
    });

    // Insert an eligible story entry
    await db.insert('historia', {
      'user_id': 'test-user',
      'titulo': 'Test Story Title',
      'data': DateTime.now().toIso8601String(),
      'descricao': 'Test Story Description',
      'humor': 3,
      'energia': 2,
    });

    final premium = _FakePremiumProvider();

    // 2. Pump ChaptersScreen
    await tester.pumpWidget(buildChaptersScreen(
      authProvider: auth,
      premiumProvider: premium,
    ));
    // Let database load complete and remove loader
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Verify ChaptersScreen loaded
    expect(find.byType(ChaptersScreen), findsOneWidget);

    // Tap Floating Action Button to create chapter
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Verify _CreateCapituloPage has loaded
    expect(find.text('Criar Capítulo'), findsOneWidget);

    // 3. Make changes and verify discard dialog
    // Type in the title field
    final titleField = find.byType(TextField).first;
    await tester.enterText(titleField, 'New Chapter Title');
    await tester.pump();

    // Try to go back via the AppBar back button
    final backButton = find.byIcon(Icons.arrow_back);
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // Verify AlertDialog popped up with title "Descartar alterações?"
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Descartar alterações?'), findsOneWidget);

    // Tap "Cancelar" in the dialog to close it and stay on page
    final cancelButton = find.text('Cancelar');
    expect(cancelButton, findsOneWidget);
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Criar Capítulo'), findsOneWidget);
  });
}
