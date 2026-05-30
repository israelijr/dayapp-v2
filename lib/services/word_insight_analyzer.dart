import '../helpers/rich_text_helper.dart';

/// Entrada textual simplificada usada na análise por palavras.
class StoryTextEntry {
  final String title;
  final String? description;
  final int mood;

  const StoryTextEntry({
    required this.title,
    required this.description,
    required this.mood,
  });

  /// Texto consolidado da história para análise.
  String get combinedText {
    final rawDescription = description?.trim() ?? '';
    final plainDescription = rawDescription.isEmpty
        ? ''
        : RichTextHelper.isValidQuillJson(rawDescription)
        ? RichTextHelper.jsonToPlainText(rawDescription).trim()
        : rawDescription;
    final parts = <String>[title.trim()];
    if (plainDescription.isNotEmpty) {
      parts.add(plainDescription);
    }
    return parts.where((part) => part.isNotEmpty).join(' ').trim();
  }
}

/// Analisa o texto das histórias para descobrir palavras recorrentes.
///
/// A estratégia desta fase prioriza previsibilidade e baixo custo:
/// - normaliza texto
/// - ignora palavras curtas
class WordInsightAnalyzer {
  static const int defaultMinWordLength = 4;

  static const Map<String, String> _accentMap = {
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'ì': 'i',
    'í': 'i',
    'î': 'i',
    'ï': 'i',
    'ò': 'o',
    'ó': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'ù': 'u',
    'ú': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
    'ñ': 'n',
    'ý': 'y',
    'ÿ': 'y',
  };

  const WordInsightAnalyzer();

  String normalizeText(String text) {
    var normalized = text.toLowerCase().trim();

    for (final entry in _accentMap.entries) {
      normalized = normalized.replaceAll(entry.key, entry.value);
    }

    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized;
  }

  List<String> tokenize(
    String text, {
    int minWordLength = defaultMinWordLength,
  }) {
    if (text.trim().isEmpty) return const [];

    final normalized = normalizeText(text);
    if (normalized.isEmpty) return const [];

    return normalized
        .split(' ')
        .where((token) => token.isNotEmpty)
        .where((token) => token.length >= minWordLength)
        .where((token) => !RegExp(r'\d').hasMatch(token))
        .toList(growable: false);
  }
}
