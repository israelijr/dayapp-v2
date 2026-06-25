import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:dayapp/providers/auth_provider.dart';
import 'package:dayapp/providers/pin_provider.dart';
import 'package:dayapp/screens/lock_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Widget buildLockScreen({
    required AuthProvider authProvider,
    required PinProvider pinProvider,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<PinProvider>.value(value: pinProvider),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('pt'),
        home: LockScreen(),
      ),
    );
  }

  testWidgets('renders LockScreen elements correctly without lock icon', (WidgetTester tester) async {
    final authProvider = AuthProvider();
    final pinProvider = PinProvider();
    
    // Configura o PIN como habilitado para forçar a tela de PIN a aparecer
    pinProvider.updatePinEnabled(true);

    await tester.pumpWidget(buildLockScreen(
      authProvider: authProvider,
      pinProvider: pinProvider,
    ));
    await tester.pumpAndSettle();

    // Título da LockScreen l10n pt
    expect(find.text('Desbloqueie o App'), findsOneWidget);
    expect(find.text('Digite seu PIN para continuar'), findsOneWidget);

    // Não deve renderizar o ícone de cadeado (Icons.lock_outline)
    expect(find.byIcon(Icons.lock_outline), findsNothing);

    // Verifica botões de números
    for (int i = 0; i <= 9; i++) {
      expect(find.text(i.toString()), findsOneWidget);
    }

    // Verifica botão OK
    expect(find.text('OK'), findsOneWidget);

    // Verifica botão de apagar
    expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);

    // Verifica "Esqueci meu PIN"
    expect(find.text('Esqueci meu PIN'), findsOneWidget);
  });

  testWidgets('LockScreen OK button color/enabled state changes', (WidgetTester tester) async {
    final authProvider = AuthProvider();
    final pinProvider = PinProvider();
    pinProvider.updatePinEnabled(true);

    await tester.pumpWidget(buildLockScreen(
      authProvider: authProvider,
      pinProvider: pinProvider,
    ));
    await tester.pumpAndSettle();

    // Pega o estilo do texto "OK"
    // Inicialmente com menos de 4 dígitos deve ter a cor desabilitada (onSurface com opacidade)
    final Text okTextBefore = tester.widget<Text>(find.text('OK'));
    final okColorBefore = okTextBefore.style?.color;
    expect(okColorBefore, isNotNull);

    // Digita 4 dígitos
    await tester.tap(find.text('1'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('3'));
    await tester.tap(find.text('4'));
    await tester.pumpAndSettle();

    // Agora o botão OK deve estar habilitado
    final Text okTextAfter = tester.widget<Text>(find.text('OK'));
    final okColorAfter = okTextAfter.style?.color;
    expect(okColorAfter, isNotNull);

    // As duas cores devem ser diferentes, indicando mudança de estado/habilitação
    expect(okColorBefore, isNot(okColorAfter));
  });
}
