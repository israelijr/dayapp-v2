import 'package:dayapp/l10n/app_localizations.dart';
import 'package:dayapp/providers/auth_provider.dart';
import 'package:dayapp/providers/locale_provider.dart';
import 'package:dayapp/providers/refresh_provider.dart';
import 'package:dayapp/providers/theme_provider.dart';
import 'package:dayapp/screens/group_selection_screen.dart';
import 'package:dayapp/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<void> setupSmallScreen(WidgetTester tester) async {
    // 320x480 representa um dispositivo de tela muito pequena (ex: iPhone 4S ou relógio inteligente/modo reduzido)
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 480);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget buildTestableWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => RefreshProvider()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  testWidgets('SearchScreen renders on small screen without overflow', (
    tester,
  ) async {
    await setupSmallScreen(tester);
    await tester.pumpWidget(buildTestableWidget(const SearchScreen()));
    await tester.pumpAndSettle();

    // Verifica se a tela foi renderizada com o título correspondente
    expect(find.byType(SearchScreen), findsOneWidget);
    // Não deve lançar nenhuma exceção de overflow
  });

  testWidgets('GroupSelectionScreen renders on small screen without overflow', (
    tester,
  ) async {
    await setupSmallScreen(tester);
    await tester.pumpWidget(buildTestableWidget(const GroupSelectionScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(GroupSelectionScreen), findsOneWidget);
    // Não deve lançar nenhuma exceção de overflow
  });
}
