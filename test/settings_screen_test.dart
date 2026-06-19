import 'package:dayapp/l10n/app_localizations.dart';
import 'package:dayapp/l10n/app_localizations_en.dart';
import 'package:dayapp/l10n/app_localizations_es.dart';
import 'package:dayapp/l10n/app_localizations_fr.dart';
import 'package:dayapp/l10n/app_localizations_it.dart';
import 'package:dayapp/l10n/app_localizations_pt.dart';
import 'package:dayapp/providers/auth_provider.dart';
import 'package:dayapp/providers/locale_provider.dart';
import 'package:dayapp/providers/notification_preferences_provider.dart';
import 'package:dayapp/providers/pin_provider.dart';
import 'package:dayapp/providers/premium_provider.dart';
import 'package:dayapp/providers/settings_security_provider.dart';
import 'package:dayapp/providers/theme_provider.dart';
import 'package:dayapp/screens/settings_screen.dart';
import 'package:dayapp/services/notification_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('notification advance labels are localized', () {
    expect(
      NotificationPreferencesService.getLocalizedAdvanceLabel(
        60,
        AppLocalizationsEn(),
      ),
      '1 hour before',
    );
    expect(
      NotificationPreferencesService.getLocalizedAdvanceLabel(
        1440,
        AppLocalizationsEs(),
      ),
      '1 día antes',
    );
    expect(
      NotificationPreferencesService.getLocalizedAdvanceLabel(
        10080,
        AppLocalizationsFr(),
      ),
      '1 semaine avant',
    );
    expect(
      NotificationPreferencesService.getLocalizedAdvanceLabel(
        180,
        AppLocalizationsIt(),
      ),
      '3 ore prima',
    );
    expect(
      NotificationPreferencesService.getLocalizedAdvanceLabel(
        30,
        AppLocalizationsPt(),
      ),
      '30 minutos antes',
    );
  });

  testWidgets('settings renders the main sections', (tester) async {
    await _useLargeSurface(tester);
    await tester.pumpWidget(_buildSettingsScreen());

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Security'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Backup'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Backup'), findsOneWidget);
  });

  testWidgets('settings opens language, theme, and notification dialogs', (
    tester,
  ) async {
    await _useLargeSurface(tester);
    await tester.pumpWidget(_buildSettingsScreen());

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    expect(find.text('Device default'), findsWidgets);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    expect(find.text('Theme and Scheme'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Default advance'),
      300,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Default advance'));
    await tester.pumpAndSettle();
    expect(find.text('Notification advance'), findsOneWidget);
  });
}

Future<void> _useLargeSurface(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(900, 1200);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _buildSettingsScreen() {
  final pinProvider = PinProvider();
  final securityProvider = SettingsSecurityProvider(
    pinProvider: pinProvider,
    userId: null,
  );

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ChangeNotifierProvider(create: (_) => NotificationPreferencesProvider()),
      ChangeNotifierProvider.value(value: pinProvider),
      ChangeNotifierProvider(create: (_) => PremiumProvider()),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: SettingsScreen(securityProvider: securityProvider),
    ),
  );
}
