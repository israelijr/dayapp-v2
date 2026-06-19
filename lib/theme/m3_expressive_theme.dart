import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

/// Tema Material Design 3 Expressive para o DayApp
/// Versão enxuta: expõe `getLightTheme` e `getDarkTheme`.
class M3ExpressiveTheme {
  // Seed color principal do DayApp (roxo)
  static const Color seedColor = Color(0xFFB388FF);

  static ThemeData buildTheme(ColorScheme colorScheme) {
    return ThemeData.from(colorScheme: colorScheme).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        // foregroundColor define a cor do título via defaults do AppBar,
        // sem alterar a fonte (tamanho/peso são preservados naturalmente).
        foregroundColor: colorScheme.primary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  /// Retorna o tema claro com estilo M3 Expressive
  static ThemeData getLightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    );

    final base = buildTheme(colorScheme);
    // M3 Expressive claro: cor específica de branding (roxo escuro)
    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        foregroundColor: AppColors.primaryVariant,
      ),
    );
  }

  /// Retorna o tema escuro com estilo M3 Expressive
  static ThemeData getDarkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    );

    final base = buildTheme(colorScheme);
    // M3 Expressive escuro: lilás claro para contraste sobre fundo escuro
    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        foregroundColor: AppColors.lilacLight,
      ),
    );
  }
}

// Classe imutável com cores do branding para uso em telas e estilos.
class _AppColors {
  const _AppColors();

  // Primárias
  final Color primary = const Color(0xFFB388FF);
  final Color primaryVariant = const Color(0xFF5E35B1);

  // Tons de fundo/brand
  final Color backgroundLight = const Color(0xFFF5E8FA);
  final Color lilacLight = const Color(0xFFE8D5F0);

  // Paleta adicional usada no splash/decoração
  final Color purple700 = const Color(0xFF7B2CBF);
  final Color purple600 = const Color(0xFF9D4EDD);
  final Color purple300 = const Color(0xFFC77DFF);
  final Color purple200 = const Color(0xFFE0AAFF);
  // Paleta adicional usada por estatísticas e ícones
  final Color emoticonBlue = const Color(0xFF81D4FA);
  final Color emoticonTeal = const Color(0xFF80CBC4);
  final Color emoticonLightPurple = const Color(0xFFB39DDB);
  final Color emoticonOrange = const Color(0xFFFFCC80);
  final Color emoticonPink = const Color(0xFFF48FB1);
  final Color emoticonGreen = const Color(0xFFA5D6A7);
  final Color emoticonRed = const Color(0xFFFFAB91);
  final Color emoticonYellow = const Color(0xFFFFE082);
  final Color emoticonPurple = const Color(0xFFCE93D8);
  final Color emoticonBlue2 = const Color(0xFF90CAF9);
  // Neutral greys for UI elements
  final Color neutralGrey = const Color(0xFF9E9E9E);
}

// Conveniência para importadores: `AppColors.primary`
class AppColors {
  static const _AppColors _app = _AppColors();
  static Color get primary => _app.primary;
  static Color get primaryVariant => _app.primaryVariant;
  static Color get backgroundLight => _app.backgroundLight;
  static Color get lilacLight => _app.lilacLight;
  static Color get purple700 => _app.purple700;
  static Color get purple600 => _app.purple600;
  static Color get purple300 => _app.purple300;
  static Color get purple200 => _app.purple200;
  static Color get emoticonBlue => _app.emoticonBlue;
  static Color get emoticonTeal => _app.emoticonTeal;
  static Color get emoticonLightPurple => _app.emoticonLightPurple;
  static Color get emoticonOrange => _app.emoticonOrange;
  static Color get emoticonPink => _app.emoticonPink;
  static Color get emoticonGreen => _app.emoticonGreen;
  static Color get emoticonRed => _app.emoticonRed;
  static Color get emoticonYellow => _app.emoticonYellow;
  static Color get emoticonPurple => _app.emoticonPurple;
  static Color get emoticonBlue2 => _app.emoticonBlue2;
  static Color get neutralGrey => _app.neutralGrey;

  /// Retorna a cor adequada para textos de label conforme o tema ativo.
  /// - CustomColorSchemes: usa [ColorScheme.primary]
  /// - M3Expressive claro: [AppColors.primaryVariant]
  /// - M3Expressive escuro: [AppColors.lilacLight]
  static Color labelColor(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isCustomScheme = themeProvider.selectedSchemeKey != null;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return isCustomScheme
        ? theme.colorScheme.primary
        : (isDark ? AppColors.lilacLight : AppColors.primaryVariant);
  }
}
