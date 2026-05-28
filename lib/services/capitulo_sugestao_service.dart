import '../db/capitulo_helper.dart';
import '../helpers/rich_text_helper.dart';
import '../models/capitulo_sugestao.dart';
import '../models/historia.dart';
import 'word_insight_analyzer.dart';

class CapituloSugestaoService {
  static const int _minEntradasPorCapitulo = 3;
  static const int _maxDiasEntreEntradas = 30;
  static const double _similaridadeMinima = 0.15;

  final CapituloHelper _capituloHelper;
  final WordInsightAnalyzer _analyzer;

  CapituloSugestaoService({
    CapituloHelper? capituloHelper,
    WordInsightAnalyzer analyzer = const WordInsightAnalyzer(),
  }) : _capituloHelper = capituloHelper ?? CapituloHelper(),
       _analyzer = analyzer;

  Future<List<CapituloSugestao>> sugerirCapitulos(String userId) async {
    // Usa JOIN com historia_tags para obter as tags reais de cada entrada
    final entradasComTags = await _capituloHelper.listEntradasElegiveisComTags(
      userId,
    );
    if (entradasComTags.length < _minEntradasPorCapitulo) return const [];

    final ignoradas = await _capituloHelper.getIgnoredSuggestionFingerprints(
      userId,
    );
    final entradasJaVinculadas = await _capituloHelper.getEntradasJaVinculadas(
      userId,
    );

    final candidatasComTags =
        entradasComTags
            .where(
              (item) =>
                  item.historia.id != null &&
                  !entradasJaVinculadas.contains(item.historia.id),
            )
            .toList(growable: false)
          ..sort((a, b) => a.historia.data.compareTo(b.historia.data));

    if (candidatasComTags.length < _minEntradasPorCapitulo) return const [];

    final candidatas = candidatasComTags
        .map((item) => item.historia)
        .toList(growable: false);

    // Mapa de id → tagNomes obtidos via JOIN (inclui nome e slug das tags)
    final tagNomesMap = {
      for (final item in candidatasComTags) item.historia.id!: item.tagNomes,
    };

    final featureMap = {
      for (final entry in candidatas)
        entry.id!: _buildFeatures(entry, tagNomesMap[entry.id!] ?? ''),
    };

    final grupos = <List<Historia>>[];
    List<Historia> atual = [];

    for (final entry in candidatas) {
      if (atual.isEmpty) {
        atual.add(entry);
        continue;
      }

      final ultimo = atual.last;
      final dias = entry.data.difference(ultimo.data).inDays;
      final similaridade = _similaridadeEntre(
        featureMap[ultimo.id!]!,
        featureMap[entry.id!]!,
      );

      if (dias <= _maxDiasEntreEntradas &&
          similaridade >= _similaridadeMinima) {
        atual.add(entry);
      } else {
        if (atual.length >= _minEntradasPorCapitulo) {
          grupos.add(List<Historia>.from(atual));
        }
        atual = [entry];
      }
    }

    if (atual.length >= _minEntradasPorCapitulo) {
      grupos.add(List<Historia>.from(atual));
    }

    final sugestoes = <CapituloSugestao>[];
    for (final grupo in grupos) {
      final entradaIds = grupo.map((h) => h.id!).toList(growable: false)
        ..sort();
      final fingerprint = entradaIds.join('-');
      if (ignoradas.contains(fingerprint)) continue;

      final tags = <String, int>{};
      final palavras = <String, int>{};

      for (final entry in grupo) {
        final feature = featureMap[entry.id!]!;
        for (final tag in feature.tags) {
          tags[tag] = (tags[tag] ?? 0) + 1;
        }
        for (final token in feature.tokens) {
          palavras[token] = (palavras[token] ?? 0) + 1;
        }
      }

      final topTags = _topByCount(tags, limit: 3);
      final topPalavras = _topByCount(palavras, limit: 4);
      final titulo = _sugerirTitulo(topTags, topPalavras, grupo);
      final score = _scoreDoGrupo(grupo, featureMap);

      sugestoes.add(
        CapituloSugestao(
          fingerprint: fingerprint,
          tituloSugerido: titulo,
          dataInicio: grupo.first.data,
          dataFim: grupo.last.data,
          scoreConfianca: score,
          entradaIds: entradaIds,
          entradas: List<Historia>.from(grupo.reversed),
          topTags: topTags,
          topPalavras: topPalavras,
        ),
      );
    }

    sugestoes.sort((a, b) => b.scoreConfianca.compareTo(a.scoreConfianca));
    return sugestoes;
  }

  _EntryFeatures _buildFeatures(Historia entry, [String tagNomes = '']) {
    // Prioriza as tags da tabela relacional; recorre ao campo legado se vazio
    final rawTags = tagNomes.isNotEmpty ? tagNomes : (entry.tag ?? '');
    final tagParts = rawTags
        .split(',')
        .map((item) => item.trim().toLowerCase())
        .where((item) => item.isNotEmpty)
        .toSet();

    final rawDescription = entry.descricao ?? '';
    final description = RichTextHelper.isValidQuillJson(rawDescription)
        ? RichTextHelper.jsonToPlainText(rawDescription)
        : rawDescription;

    final text = '${entry.titulo} $description'.trim();
    final tokens = _analyzer
        .tokenize(
          text,
          minWordLength: 4,
          stopwords: WordInsightAnalyzer.defaultStopwords,
        )
        .toSet();

    return _EntryFeatures(tags: tagParts, tokens: tokens);
  }

  double _similaridadeEntre(_EntryFeatures a, _EntryFeatures b) {
    final tagsScore = _jaccard(a.tags, b.tags);
    final tokenScore = _jaccard(a.tokens, b.tokens);

    if (a.tags.isEmpty && b.tags.isEmpty) {
      return tokenScore;
    }

    return (tagsScore * 0.6) + (tokenScore * 0.4);
  }

  double _jaccard(Set<String> a, Set<String> b) {
    if (a.isEmpty && b.isEmpty) return 0;
    final inter = a.intersection(b).length;
    final uniao = a.union(b).length;
    if (uniao == 0) return 0;
    return inter / uniao;
  }

  List<String> _topByCount(Map<String, int> source, {required int limit}) {
    final entries = source.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        if (byCount != 0) return byCount;
        return a.key.compareTo(b.key);
      });
    return entries
        .take(limit)
        .map((entry) => entry.key)
        .toList(growable: false);
  }

  String _sugerirTitulo(
    List<String> topTags,
    List<String> topPalavras,
    List<Historia> grupo,
  ) {
    if (topTags.isNotEmpty) {
      final tag = topTags.first;
      return _capitalize(tag);
    }

    if (topPalavras.isNotEmpty) {
      final palavra = topPalavras.first;
      return _capitalize(palavra);
    }

    return grupo.first.titulo;
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  double _scoreDoGrupo(
    List<Historia> grupo,
    Map<int, _EntryFeatures> features,
  ) {
    if (grupo.length <= 1) return 0.0;

    double soma = 0;
    int pares = 0;
    for (var i = 1; i < grupo.length; i++) {
      final anterior = features[grupo[i - 1].id!]!;
      final atual = features[grupo[i].id!]!;
      soma += _similaridadeEntre(anterior, atual);
      pares += 1;
    }

    final media = pares == 0 ? 0.0 : soma / pares;
    return double.parse(media.toStringAsFixed(2));
  }
}

class _EntryFeatures {
  final Set<String> tags;
  final Set<String> tokens;

  const _EntryFeatures({required this.tags, required this.tokens});
}
