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
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

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
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ChaptersScreen(),
      ),
    );
  }

  testWidgets('ChaptersScreen manually create chapter, triggers discard dialog when dirty', (tester) async {
    print('DEBUG: Test started');
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

    print('DEBUG: Database set up, pumping widget...');
    // 2. Pump ChaptersScreen
    await tester.pumpWidget(buildChaptersScreen(
      authProvider: auth,
      premiumProvider: premium,
    ));
    print('DEBUG: Widget pumped, starting first pump loop...');
    // Let database load complete and remove loader
    for (int i = 0; i < 10; i++) {
      print('DEBUG: pump loop $i');
      await tester.pump(const Duration(milliseconds: 100));
    }
    print('DEBUG: First pump loop finished');

    // Verify ChaptersScreen loaded
    expect(find.byType(ChaptersScreen), findsOneWidget);
    print('DEBUG: Verified ChaptersScreen exists');

    // Tap Floating Action Button to create chapter
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    print('DEBUG: Tapped FAB, starting second pump loop...');
    for (int i = 0; i < 5; i++) {
      print('DEBUG: second pump loop $i');
      await tester.pump(const Duration(milliseconds: 100));
    }
    print('DEBUG: Second pump loop finished');

    // Verify _CreateCapituloPage has loaded
    expect(find.text('Criar Capítulo'), findsOneWidget);
    print('DEBUG: Verified _CreateCapituloPage loaded');

    // 3. Make changes and verify discard dialog
    // Type in the title field
    final titleField = find.byType(TextField).first;
    await tester.enterText(titleField, 'New Chapter Title');
    await tester.pump();
    print('DEBUG: Text entered in title field');

    // Try to go back via the AppBar back button
    final backButton = find.byIcon(Icons.arrow_back);
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    print('DEBUG: Tapped back button, pumping and settling...');
    await tester.pumpAndSettle();
    print('DEBUG: Pump and settle finished');

    // Verify AlertDialog popped up with title "Descartar alterações?"
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Descartar alterações?'), findsOneWidget);
    print('DEBUG: Verified AlertDialog exists');

    // Tap "Cancelar" in the dialog to close it and stay on page
    final cancelButton = find.text('Cancelar');
    expect(cancelButton, findsOneWidget);
    await tester.tap(cancelButton);
    print('DEBUG: Tapped cancel button, pumping and settling...');
    await tester.pumpAndSettle();
    print('DEBUG: Pump and settle finished');

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Criar Capítulo'), findsOneWidget);
    print('DEBUG: Test finished successfully');
  });
}
