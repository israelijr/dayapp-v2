// Esquemas de cores personalizados do DayApp
// Contém os esquemas nas variantes Light e Dark
import 'package:flutter/material.dart';

// Observação: as colunas da tabela foram mapeadas para os campos do ColorScheme
// do Flutter (SurfaceDim -> surfaceContainerHighest, Surface -> surface, etc.).

class CustomColorSchemes {
  // Chaves de família dos esquemas personalizados
  static const String relvaFamilyKey = 'relva';
  static const String outonoFamilyKey = 'outono';
  static const String ceuFamilyKey = 'ceu';
  static const String confortFamilyKey = 'confort';
  static const String sunsetFamilyKey = 'sunset';
  static const String midnightGalaxyFamilyKey = 'midnightGalaxy';

  static const List<String> familyKeys = [
    relvaFamilyKey,
    outonoFamilyKey,
    ceuFamilyKey,
    confortFamilyKey,
    sunsetFamilyKey,
    midnightGalaxyFamilyKey,
  ];

  // Relva - Light
  static final ColorScheme relvaLight = const ColorScheme.light().copyWith(
    primary: const Color(0xFF326941), // Primary
    secondary: const Color(0xFF506352), // Secondary
    tertiary: const Color(0xFF3A656E), // Tertiary
    error: const Color(0xFFBA1A1A), // Error
    primaryContainer: const Color(0xFFB4F1BD), // Primary Container
    secondaryContainer: const Color(0xFFD3E8D2), // Secondary Container
    tertiaryContainer: const Color(0xFFBDEAF5), // Tertiary Container
    errorContainer: const Color(0xFFFFDAD6), // On Error Container (mapeado)
    surfaceContainerHighest: const Color(0xFFD7DBD4), // Surface Dim
    surface: const Color(0xFFF6FBF3), // Surface
    inverseSurface: const Color(0xFF2D322C), // Inverse Surface
  );

  // Relva - Dark
  static final ColorScheme relvaDark = const ColorScheme.dark().copyWith(
    primary: const Color(0xFF99D4A3),
    onPrimary: const Color(0xFF00391B),
    secondary: const Color(0xFFB7CCB7),
    onSecondary: const Color(0xFF243427),
    tertiary: const Color(0xFFA2CED8),
    onTertiary: const Color(0xFF00363F),
    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF690005),
    primaryContainer: const Color(0xFF18512B),
    onPrimaryContainer: const Color(0xFFB4F1BD),
    secondaryContainer: const Color(0xFF394B3B),
    onSecondaryContainer: const Color(0xFFD3E8D2),
    tertiaryContainer: const Color(0xFF204D55),
    onTertiaryContainer: const Color(0xFFBDEAF5),
    errorContainer: const Color(0xFF93000A),
    onErrorContainer: const Color(0xFFFFDAD6),
    surfaceContainerHighest: const Color.fromARGB(255, 61, 58, 58),
    surface: const Color(0xFF101510),
    onSurface: const Color(0xFFDFE4DC),
    inverseSurface: const Color(0xFFDFE4DC),
    onInverseSurface: const Color(0xFF101510),
  );

  // Outono (base Botanical Garden) - Light
  static final ColorScheme outonoLight = const ColorScheme.light().copyWith(
    primary: const Color(0xFF4A7C59),
    onPrimary: const Color(0xFFFFFFFF),
    secondary: const Color(0xFFF9A620),
    onSecondary: const Color(0xFF3A2500),
    tertiary: const Color(0xFFB7472A),
    onTertiary: const Color(0xFFFFFFFF),
    error: const Color(0xFFBA1A1A),
    primaryContainer: const Color(0xFFCDE9D2),
    onPrimaryContainer: const Color(0xFF12361E),
    secondaryContainer: const Color(0xFFFFE1A6),
    onSecondaryContainer: const Color(0xFF4A2F00),
    tertiaryContainer: const Color(0xFFFFD9D0),
    onTertiaryContainer: const Color(0xFF4B1A11),
    errorContainer: const Color(0xFFFFDAD6),
    surfaceContainerHighest: const Color(0xFFE3E8DF),
    surface: const Color(0xFFF5F3ED),
    inverseSurface: const Color(0xFF2B332D),
  );

  // Outono (base Botanical Garden) - Dark
  static final ColorScheme outonoDark = const ColorScheme.dark().copyWith(
    primary: const Color(0xFF99CFA6),
    onPrimary: const Color(0xFF0F2F1A),
    secondary: const Color(0xFFFFC85C),
    onSecondary: const Color(0xFF3F2800),
    tertiary: const Color(0xFFFFB59E),
    onTertiary: const Color(0xFF5A1E13),
    error: const Color(0xFFFFB4AB),
    primaryContainer: const Color(0xFF2E5F3E),
    onPrimaryContainer: const Color(0xFFCDE9D2),
    secondaryContainer: const Color(0xFF6D4700),
    onSecondaryContainer: const Color(0xFFFFE1A6),
    tertiaryContainer: const Color(0xFF8E3723),
    onTertiaryContainer: const Color(0xFFFFD9D0),
    errorContainer: const Color(0xFF93000A),
    surfaceContainerHighest: const Color(0xFF2E372F),
    surface: const Color(0xFF171D18),
    inverseSurface: const Color(0xFFDCE5DA),
  );

  // Céu - Light
  static final ColorScheme ceuLight = const ColorScheme.light().copyWith(
    primary: const Color(0xFF415F91),
    secondary: const Color(0xFF565F71),
    tertiary: const Color(0xFF705575),
    error: const Color(0xFFBA1A1A),
    primaryContainer: const Color.fromRGBO(157, 188, 253, 1),
    secondaryContainer: const Color.fromARGB(255, 99, 138, 255),
    //secondaryContainer: const Color.fromARGB(255, 3, 52, 197),
    tertiaryContainer: const Color(0xFFFAD8FD),
    errorContainer: const Color(0xFFFFDAD6),
    surfaceContainerHighest: const Color(0xFFE2E2E9),
    surface: const Color(0xFFF9F9FF),
    inverseSurface: const Color(0xFF2E3036),
  );

  // Céu - Dark
  static final ColorScheme ceuDark = const ColorScheme.dark().copyWith(
    primary: const Color(0xFFADC6FF),
    onPrimary: const Color(0xFF1B2F56),
    secondary: const Color(0xFFBFC6DC),
    onSecondary: const Color(0xFF283041),
    tertiary: const Color(0xFFDEBCDF),
    onTertiary: const Color(0xFF402843),
    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF690005),
    primaryContainer: const Color(0xFF2B4678),
    onPrimaryContainer: const Color(0xFFD8E2FF),
    secondaryContainer: const Color(0xFF3F4759),
    onSecondaryContainer: const Color(0xFFD7E3FF),
    tertiaryContainer: const Color(0xFF583E5B),
    onTertiaryContainer: const Color(0xFFFFD6FB),
    errorContainer: const Color(0xFF93000A),
    onErrorContainer: const Color(0xFFFFDAD6),
    surfaceContainerHighest: const Color(0xFF282A2F),
    surface: const Color(0xFF111318),
    onSurface: const Color(0xFFE2E2E9),
    inverseSurface: const Color(0xFFE2E2E9),
    onInverseSurface: const Color(0xFF111318),
  );

  // Confort - Light
  // primary: usar #665E40 (marrom quente escuro, ~6.3:1 contra branco)
  // em vez do amarelo claro original #FFF0BA que não tem contraste suficiente
  static final ColorScheme confortLight = const ColorScheme.light().copyWith(
    primary: const Color(0xFF665E40),
    onPrimary: Colors.white,
    secondary: const Color(0xFF43664E),
    tertiary: const Color(0xFF3B6070),
    error: const Color(0xFFBA1A1A),
    primaryContainer: const Color(0xFFF8E287),
    onPrimaryContainer: const Color(0xFF1C1400),
    secondaryContainer: const Color(0xFFEEE2BC),
    tertiaryContainer: const Color(0xFFC5ECCE),
    errorContainer: const Color(0xFFFFDAD6),
    surfaceContainerHighest: const Color(0xFFEEE8DA),
    surface: const Color(0xFFFFF9EE),
    inverseSurface: const Color(0xFF333027),
  );

  // Confort - Dark
  static final ColorScheme confortDark = const ColorScheme.dark().copyWith(
    primary: const Color(0xFFDBC66E),
    onPrimary: const Color(0xFF3B2F00),
    secondary: const Color(0xFFD1C6A1),
    onSecondary: const Color(0xFF373016),
    tertiary: const Color(0xFFA9D0B3),
    onTertiary: const Color(0xFF143722),
    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF690005),
    primaryContainer: const Color(0xFF534600),
    onPrimaryContainer: const Color(0xFFFFF0BA),
    secondaryContainer: const Color(0xFF4E472A),
    onSecondaryContainer: const Color(0xFFEDE2BC),
    tertiaryContainer: const Color(0xFF2C4E38),
    onTertiaryContainer: const Color(0xFFC5ECCE),
    errorContainer: const Color(0xFF93000A),
    onErrorContainer: const Color(0xFFFFDAD6),
    surfaceContainerHighest: const Color(0xFF38352B),
    surface: const Color(0xFF15130B),
    onSurface: const Color(0xFFE8E2D4),
    inverseSurface: const Color(0xFFE8E2D4),
    onInverseSurface: const Color(0xFF15130B),
  );

  // Sunset - Light
  // static final ColorScheme sunsetLight = const ColorScheme.light().copyWith(
  //   primary: const Color(0xFF9C4330),
  //   onPrimary: Colors.white,
  //   secondary: const Color(0xFF77574E),
  //   tertiary: const Color(0xFF6C5D2F),
  //   error: const Color(0xFFBA1A1A),
  //   primaryContainer: const Color(0xFFFFDAD3),
  //   onPrimaryContainer: const Color(0xFF3B0A02),
  //   secondaryContainer: const Color(0xFFFFDBD1),
  //   tertiaryContainer: const Color(0xFFF5E1A7),
  //   errorContainer: const Color(0xFFFFDAD6),
  //   surfaceContainerHighest: const Color(0xFFEDE0DC),
  //   surface: const Color(0xFFFFFBFF),
  //   inverseSurface: const Color(0xFF3C2A26),
  // );
  // SUNSET LIGHT
  static final ColorScheme sunsetLight = const ColorScheme.light().copyWith(
    primary: const Color(0xFFFFA000), // Âmbar 700
    onPrimary: Colors.white,

    secondary: const Color(0xFFFB8C00), // Laranja 600
    onSecondary: Colors.white,

    tertiary: const Color(0xFFFFD54F), // Âmbar 300
    onTertiary: const Color(0xFF3A2A00),

    error: const Color(0xFFBA1A1A),
    onError: Colors.white,

    primaryContainer: const Color(0xFFFFECB3), // Âmbar 100
    onPrimaryContainer: const Color(0xFF3B2A00),

    secondaryContainer: const Color(0xFFFFCC80), // Laranja 200
    onSecondaryContainer: const Color(0xFF3A1E00),

    tertiaryContainer: const Color(0xFFFFF176), // Yellow 300
    onTertiaryContainer: const Color(0xFF332700),

    surface: const Color(0xFFFFFBF7),
    onSurface: const Color(0xFF2B2118),

    surfaceContainerHighest: const Color(0xFFF2E7DC),

    inverseSurface: const Color(0xFF382F28),
    onInverseSurface: const Color(0xFFFFF1E8),
  );

  // Sunset - Dark
  // static final ColorScheme sunsetDark = const ColorScheme.dark().copyWith(
  //   primary: const Color(0xFFFFB4A3),
  //   secondary: const Color(0xFFE7BDB2),
  //   tertiary: const Color(0xFFD8C58D),
  //   error: const Color(0xFFFFB4AB),
  //   primaryContainer: const Color(0xFF7D2C1B),
  //   secondaryContainer: const Color(0xFF5D4037),
  //   tertiaryContainer: const Color(0xFF534619),
  //   errorContainer: const Color(0xFF93000A),
  //   surfaceContainerHighest: const Color(0xFF2E2220),
  //   surface: const Color(0xFF201A18),
  //   inverseSurface: const Color(0xFFF1DFDA),
  // );

  // SUNSET DARK
  static final ColorScheme sunsetDark = const ColorScheme.dark().copyWith(
    primary: const Color(0xFFFFCA28), // Âmbar 400
    onPrimary: const Color(0xFF3D2D00),

    secondary: const Color(0xFFFF9800), // Laranja 500
    onSecondary: const Color(0xFF3A1F00),

    tertiary: const Color(0xFFFFE082), // Âmbar 200
    onTertiary: const Color(0xFF3B2A00),

    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF690005),

    primaryContainer: const Color(0xFF5D4300),
    onPrimaryContainer: const Color(0xFFFFE082),

    secondaryContainer: const Color(0xFF5A3200),
    onSecondaryContainer: const Color(0xFFFFCC80),

    tertiaryContainer: const Color(0xFF665000),
    onTertiaryContainer: const Color(0xFFFFF176),

    surface: const Color(0xFF18120D),
    onSurface: const Color(0xFFF4E7DA),

    surfaceContainerHighest: const Color(0xFF2B241E),

    inverseSurface: const Color(0xFFF4E7DA),
    onInverseSurface: const Color(0xFF241A12),
  );

  // Midnight Galaxy - Light
  static final ColorScheme midnightGalaxyLight = const ColorScheme.light()
      .copyWith(
        primary: const Color(0xFF4A4E8F),
        onPrimary: const Color(0xFFFFFFFF),

        secondary: const Color(0xFF2B1E3E),
        onSecondary: const Color(0xFFFFFFFF),

        tertiary: const Color(0xFFA490C2),
        onTertiary: const Color(0xFF2A2340),

        error: const Color(0xFFBA1A1A),
        onError: const Color(0xFFFFFFFF),

        primaryContainer: const Color(0xFFCCD4FF),
        onPrimaryContainer: const Color(0xFF262A5C),

        secondaryContainer: const Color(0xFFBFC8FF),
        onSecondaryContainer: const Color(0xFF1E2250),

        tertiaryContainer: const Color(0xFFE3DCFF),
        onTertiaryContainer: const Color(0xFF2A2340),

        surface: const Color(0xFFEEF0FF),
        onSurface: const Color(0xFF1B1F33),
        surfaceContainerHighest: const Color(0xFFD6DDF9),

        inverseSurface: const Color(0xFF22263B),
        onInverseSurface: const Color(0xFFE6E6FA),
      );

  // Midnight Galaxy - Dark
  static final ColorScheme midnightGalaxyDark = const ColorScheme.dark()
      .copyWith(
        primary: const Color(0xFFB8C1FF),
        onPrimary: const Color(0xFF1F2359),

        secondary: const Color(0xFFA490C2),
        onSecondary: const Color(0xFF2E2342),

        tertiary: const Color(0xFFF48FB1),
        onTertiary: const Color(0xFF2B1E3E),

        error: const Color(0xFFFFB4AB),
        onError: const Color(0xFF690005),

        primaryContainer: const Color(0xFF2F3670),
        onPrimaryContainer: const Color(0xFFDCE1FF),

        secondaryContainer: const Color(0xFF283063),
        onSecondaryContainer: const Color(0xFFD7DDFF),

        tertiaryContainer: const Color(0xFF3A2D56),
        onTertiaryContainer: const Color(0xFFE9DFFF),

        surface: const Color(0xFF0F1324),
        onSurface: const Color(0xFFE6E6FA),
        surfaceContainerHighest: const Color(0xFF222B4F),

        inverseSurface: const Color(0xFFE6E6FA),
        onInverseSurface: const Color(0xFF1A1F33),
      );

  // Mapa de fácil acesso aos esquemas criados
  static final Map<String, ColorScheme> customSchemes = {
    'relvaLight': relvaLight,
    'relvaDark': relvaDark,
    'outonoLight': outonoLight,
    'outonoDark': outonoDark,
    'ceuLight': ceuLight,
    'ceuDark': ceuDark,
    'confortLight': confortLight,
    'confortDark': confortDark,
    'sunsetLight': sunsetLight,
    'sunsetDark': sunsetDark,
    'midnightGalaxyLight': midnightGalaxyLight,
    'midnightGalaxyDark': midnightGalaxyDark,
  };

  // --- Utilitários de família ---

  /// Normaliza qualquer chave (antiga ou nova) para a chave de família.
  static String? normalizeFamilyKey(String? key) {
    switch (key) {
      case relvaFamilyKey:
      case 'relvaLight':
      case 'relvaDark':
        return relvaFamilyKey;
      case outonoFamilyKey:
      case 'outonoLight':
      case 'outonoDark':
        return outonoFamilyKey;
      case ceuFamilyKey:
      case 'ceuLight':
      case 'ceuDark':
        return ceuFamilyKey;
      case confortFamilyKey:
      case 'confortLight':
      case 'confortDark':
        return confortFamilyKey;
      case sunsetFamilyKey:
      case 'sunsetLight':
      case 'sunsetDark':
        return sunsetFamilyKey;
      case midnightGalaxyFamilyKey:
      case 'midnightGalaxyLight':
      case 'midnightGalaxyDark':
        return midnightGalaxyFamilyKey;
      default:
        return null;
    }
  }

  static String lightKeyForFamily(String familyKey) {
    switch (familyKey) {
      case relvaFamilyKey:
        return 'relvaLight';
      case outonoFamilyKey:
        return 'outonoLight';
      case ceuFamilyKey:
        return 'ceuLight';
      case confortFamilyKey:
        return 'confortLight';
      case sunsetFamilyKey:
        return 'sunsetLight';
      case midnightGalaxyFamilyKey:
        return 'midnightGalaxyLight';
      default:
        return familyKey;
    }
  }

  static String darkKeyForFamily(String familyKey) {
    switch (familyKey) {
      case relvaFamilyKey:
        return 'relvaDark';
      case outonoFamilyKey:
        return 'outonoDark';
      case ceuFamilyKey:
        return 'ceuDark';
      case confortFamilyKey:
        return 'confortDark';
      case sunsetFamilyKey:
        return 'sunsetDark';
      case midnightGalaxyFamilyKey:
        return 'midnightGalaxyDark';
      default:
        return familyKey;
    }
  }

  /// Retorna o ColorScheme correto para a família e brilho informados.
  static ColorScheme? getSchemeForFamily(
    String? familyKey,
    Brightness brightness,
  ) {
    final normalizedKey = normalizeFamilyKey(familyKey);
    if (normalizedKey == null) return null;

    final schemeKey = brightness == Brightness.dark
        ? darkKeyForFamily(normalizedKey)
        : lightKeyForFamily(normalizedKey);

    return customSchemes[schemeKey];
  }
}
