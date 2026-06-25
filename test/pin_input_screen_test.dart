import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:dayapp/providers/pin_provider.dart';
import 'package:dayapp/screens/pin_input_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Widget buildPinInputScreen({required PinProvider pinProvider}) {
    return ChangeNotifierProvider<PinProvider>.value(
      value: pinProvider,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('pt'),
        home: PinInputScreen(),
      ),
    );
  }

  testWidgets('renders PIN screen elements correctly', (WidgetTester tester) async {
    final pinProvider = PinProvider();
    await tester.pumpWidget(buildPinInputScreen(pinProvider: pinProvider));

    // Verifica que o título está presente
    expect(find.text('Digite seu PIN'), findsOneWidget);
    expect(find.text('Para acessar o DayApp'), findsOneWidget);

    // Verifica os botões do teclado numérico (0 a 9)
    for (int i = 0; i <= 9; i++) {
      expect(find.text(i.toString()), findsOneWidget);
    }

    // Verifica o botão OK
    expect(find.text('OK'), findsOneWidget);

    // O botão de voltar/apagar está presente (ícone)
    expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);

    // O botão "Esqueceu PIN?" está presente (via l10n)
    expect(find.text('Esqueci meu PIN'), findsOneWidget);
  });

  testWidgets('OK button state transitions when digits are entered', (WidgetTester tester) async {
    final pinProvider = PinProvider();
    await tester.pumpWidget(buildPinInputScreen(pinProvider: pinProvider));

    // Inicialmente, o botão OK deve estar desabilitado (opacidade 0.5)
    final AnimatedOpacity initialOkOpacity = tester.widget<AnimatedOpacity>(
      find.ancestor(
        of: find.text('OK'),
        matching: find.byType(AnimatedOpacity),
      ),
    );
    expect(initialOkOpacity.opacity, 0.5);

    // Digita 3 dígitos
    await tester.tap(find.text('1'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();

    // Ainda deve estar desabilitado
    final AnimatedOpacity opacityAfter3Digits = tester.widget<AnimatedOpacity>(
      find.ancestor(
        of: find.text('OK'),
        matching: find.byType(AnimatedOpacity),
      ),
    );
    expect(opacityAfter3Digits.opacity, 0.5);

    // Digita o 4º dígito
    await tester.tap(find.text('4'));
    await tester.pumpAndSettle();

    // Agora deve estar habilitado (opacidade 1.0)
    final AnimatedOpacity opacityAfter4Digits = tester.widget<AnimatedOpacity>(
      find.ancestor(
        of: find.text('OK'),
        matching: find.byType(AnimatedOpacity),
      ),
    );
    expect(opacityAfter4Digits.opacity, 1.0);

    // Apaga um dígito
    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pumpAndSettle();

    // Deve voltar a ficar desabilitado
    final AnimatedOpacity opacityAfterBackspace = tester.widget<AnimatedOpacity>(
      find.ancestor(
        of: find.text('OK'),
        matching: find.byType(AnimatedOpacity),
      ),
    );
    expect(opacityAfterBackspace.opacity, 0.5);
  });
}
