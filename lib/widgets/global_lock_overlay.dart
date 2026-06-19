import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pin_provider.dart';
import '../screens/lock_screen.dart';
import '../screens/password_recovery_screen.dart';
import '../screens/pin_recovery_screen.dart';

/// Widget que sobrepõe a tela de bloqueio em todo o app
/// sem reconstruir as telas subjacentes, preservando o estado de edição.
class GlobalLockOverlay extends StatelessWidget {
  final Widget child;

  const GlobalLockOverlay({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PinProvider>(
      builder: (context, pinProvider, _) {
        debugPrint(
          'GlobalLockOverlay: shouldShowPinScreen=${pinProvider.shouldShowPinScreen}',
        );

        return Stack(
          children: [
            // Conteúdo do app - SEMPRE presente, nunca reconstruído
            child,

            // Overlay de bloqueio com Overlay próprio para que TextFields e
            // SnackBars funcionem corretamente (MaterialApp.builder não tem Overlay)
            if (pinProvider.shouldShowPinScreen)
              const Positioned.fill(child: _LockOverlay()),
          ],
        );
      },
    );
  }
}

/// Overlay interno com seu próprio widget Overlay que fornece contexto adequado
/// para TextFields (selection handles, magnifier) e SnackBars funcionarem.
class _LockOverlay extends StatefulWidget {
  const _LockOverlay();

  @override
  State<_LockOverlay> createState() => _LockOverlayState();
}

class _LockOverlayState extends State<_LockOverlay> {
  late final OverlayEntry _entry;

  @override
  void initState() {
    super.initState();
    // OverlayEntry criado uma vez; Consumer interno garante reatividade
    _entry = OverlayEntry(builder: _buildContent);
  }

  Widget _buildContent(BuildContext context) {
    return Consumer<PinProvider>(
      builder: (context, pinProvider, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Blur sobre o conteúdo do app
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: ColoredBox(
                color: Theme.of(
                  context,
                ).colorScheme.scrim.withValues(alpha: 0.5),
                child: const SizedBox.expand(),
              ),
            ),
            // Tela ativa conforme estado do provider
            if (pinProvider.showPinRecovery)
              PinRecoveryScreen(
                onCancel: () => pinProvider.stopPinRecovery(),
                onSuccess: () {
                  pinProvider.stopPinRecovery();
                  pinProvider.authenticateWithBiometric();
                },
              )
            else if (pinProvider.showPasswordRecovery)
              PasswordRecoveryScreen(
                onCancel: () => pinProvider.stopPasswordRecovery(),
                onSuccess: () => pinProvider.stopPasswordRecovery(),
              )
            else
              const LockScreen(),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Overlay próprio resolve "No Overlay widget found" em TextFields e SnackBars
    return Overlay(initialEntries: [_entry]);
  }
}
