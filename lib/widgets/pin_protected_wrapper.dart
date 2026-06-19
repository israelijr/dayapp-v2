import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pin_provider.dart';
import '../screens/lock_screen.dart';

class PinProtectedWrapper extends StatelessWidget {
  final Widget child;

  const PinProtectedWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PinProvider>(
      builder: (context, pinProvider, child) {
        debugPrint(
          'PinProtectedWrapper: shouldShowPinScreen=${pinProvider.shouldShowPinScreen}',
        );

        if (pinProvider.shouldShowPinScreen) {
          return Stack(
            children: [
              // Conteúdo com blur
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: ColoredBox(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.3),
                  child: this.child,
                ),
              ),
              // Tela de bloqueio sobreposta
              const LockScreen(),
            ],
          );
        }

        return this.child;
      },
    );
  }
}
