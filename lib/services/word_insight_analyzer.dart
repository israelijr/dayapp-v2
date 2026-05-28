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

/// Estatísticas agregadas de uma palavra após o processamento.
class WordAssociation {
  final String word;
  final int frequency;
  final double averageMood;

  const WordAssociation({
    required this.word,
    required this.frequency,
    required this.averageMood,
  });
}

/// Resultado completo da análise textual por histórias.
class WordInsightAnalysis {
  final List<WordAssociation> positiveWords;
  final List<WordAssociation> difficultWords;
  final int totalStoriesAnalyzed;
  final int totalUniqueWords;

  const WordInsightAnalysis({
    required this.positiveWords,
    required this.difficultWords,
    required this.totalStoriesAnalyzed,
    required this.totalUniqueWords,
  });

  bool get hasAnyInsight =>
      positiveWords.isNotEmpty || difficultWords.isNotEmpty;
}

class _WordAccumulator {
  int frequency = 0;
  int moodSum = 0;

  void add(int mood) {
    frequency += 1;
    moodSum += mood;
  }
}

/// Analisa o texto das histórias para descobrir palavras recorrentes.
///
/// A estratégia desta fase prioriza previsibilidade e baixo custo:
/// - normaliza texto
/// - remove stopwords
/// - ignora palavras curtas
/// - conta cada palavra no máximo uma vez por história
/// - calcula média de humor por palavra
class WordInsightAnalyzer {
  static const int defaultMinWordLength = 4;
  static const int defaultMinFrequency = 3;
  static const int defaultTopWordsLimit = 5;
  static const double defaultPositiveMoodThreshold = 3.4;
  static const double defaultDifficultMoodThreshold = 2.6;

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

  static const Set<String> _defaultStopwords = {
    // --- Artigos e contrações ---
    'a',
    'ao',
    'aos',
    'as',
    'da',
    'das',
    'de',
    'do',
    'dos',
    'e',
    'em',
    'la',
    'lo',
    'na',
    'nas',
    'no',
    'nos',
    'num',
    'numa',
    'o',
    'os',
    'um',
    'uma',
    'umas',
    'uns',

    // --- Pronomes pessoais ---
    'ela',
    'elas',
    'ele',
    'eles',
    'eu',
    'lhe',
    'lhes',
    'me',
    'si',
    'te',
    'ti',
    'tu',
    'vos',
    'voce',
    'voces',

    // --- Pronomes possessivos ---
    'meu',
    'meus',
    'minha',
    'minhas',
    'nossa',
    'nossas',
    'nosso',
    'nossos',
    'seu',
    'seus',
    'sua',
    'suas',
    'teu',
    'teus',
    'tua',
    'tuas',
    'vossa',
    'vossas',
    'vosso',
    'vossos',

    // --- Pronomes demonstrativos/indefinidos ---
    'aquela',
    'aquelas',
    'aquele',
    'aqueles',
    'aquilo',
    'essa',
    'essas',
    'esse',
    'esses',
    'esta',
    'estas',
    'este',
    'estes',
    'isso',
    'isto',
    'algum',
    'alguma',
    'algumas',
    'alguns',
    'cada',
    'nada',
    'nenhum',
    'nenhuma',
    'ninguem',
    'outro',
    'outra',
    'outros',
    'outras',
    'qualquer',
    'quais',
    'qual',
    'quem',
    'tudo',

    // --- Pronomes relativos/interrogativos ---
    'onde',
    'quando',
    'quanto',
    'quantos',
    'que',

    // --- Preposições ---
    'ante',
    'apos',
    'alem',
    'atras',
    'atraves',
    'ate',
    'ca',
    'com',
    'como',
    'contra',
    'daquela',
    'daquelas',
    'daquele',
    'daqueles',
    'dali',
    'daqui',
    'debaixo',
    'dela',
    'delas',
    'dele',
    'deles',
    'dentro',
    'desde',
    'dessa',
    'dessas',
    'desse',
    'desses',
    'desta',
    'destas',
    'deste',
    'destes',
    'diante',
    'disto',
    'durante',
    'entre',
    'naquela',
    'naquelas',
    'naquele',
    'naqueles',
    'nessa',
    'nessas',
    'nesse',
    'nesses',
    'nesta',
    'nestas',
    'neste',
    'nestes',
    'para',
    'pela',
    'pelas',
    'pelo',
    'pelos',
    'per',
    'perante',
    'por',
    'pra',
    'pras',
    'pro',
    'pros',
    'sem',
    'sob',
    'sobre',

    // --- Conjunções ---
    'contudo',
    'embora',
    'enquanto',
    'entretanto',
    'mas',
    'nem',
    'ou',
    'pois',
    'porque',
    'porquanto',
    'porem',
    'se',
    'tampouco',
    'todavia',

    // --- Advérbios temporais ---
    'agora',
    'ainda',
    'ali',
    'amanha',
    'antes',
    'aqui',
    'cedo',
    'depois',
    'hoje',
    'ja',
    'logo',
    'longe',
    'nunca',
    'ontem',
    'perto',
    'sempre',
    'tarde',

    // --- Advérbios modais e de intensidade ---
    'apenas',
    'assim',
    'bastante',
    'bem',
    'certamente',
    'dito',
    'jamais',
    'mais',
    'mal',
    'mesmo',
    'menos',
    'muito',
    'possivelmente',
    'principalmente',
    'quase',
    'realmente',
    'simplesmente',
    'so',
    'talvez',
    'tambem',

    // --- Formas do verbo "ser/estar" ---
    'era',
    'eram',
    'eramos',
    'es',
    'estamos',
    'estao',
    'estar',
    'estava',
    'estavam',
    'estavamos',
    'esteja',
    'estejam',
    'estejamos',
    'esteve',
    'estive',
    'estivemos',
    'estiver',
    'estivera',
    'estiveram',
    'estiverem',
    'estivermos',
    'estivesse',
    'estivessem',
    'estou',
    'foi',
    'fomos',
    'for',
    'fora',
    'foram',
    'foramos',
    'forem',
    'formos',
    'fosse',
    'fossem',
    'fossemos',
    'foste',
    'fostes',
    'fui',
    'sao',
    'seja',
    'sejam',
    'sejamos',
    'sendo',
    'ser',
    'sera',
    'serao',
    'serei',
    'seremos',
    'seria',
    'seriam',
    'seriamos',
    'sido',
    'sim',
    'somos',
    'sou',
    'sois',

    // --- Formas do verbo "ter/haver" ---
    'ha',
    'haja',
    'hajam',
    'hajamos',
    'hao',
    'havemos',
    'havia',
    'hei',
    'houve',
    'houvemos',
    'houver',
    'houvera',
    'houveram',
    'houverao',
    'houverei',
    'houverem',
    'houveremos',
    'houveria',
    'houveriam',
    'houvermos',
    'houvesse',
    'houvessem',
    'tem',
    'temos',
    'tendes',
    'tendo',
    'tenha',
    'tenham',
    'tenhamos',
    'tenho',
    'tens',
    'ter',
    'tera',
    'terao',
    'terei',
    'teremos',
    'teria',
    'teriam',
    'teriamos',
    'teve',
    'tido',
    'tinha',
    'tinham',
    'tinhamos',
    'tive',
    'tivemos',
    'tiver',
    'tivera',
    'tiveram',
    'tiveramos',
    'tiverem',
    'tivermos',
    'tivesse',
    'tivessem',
    'tivessemos',
    'tiveste',
    'tivestes',

    // --- Formas do verbo "ir/vir" ---
    'vai',
    'vais',
    'vao',
    'vem',
    'vendo',
    'vens',
    'ver',
    'vindo',
    'vir',
    'vou',

    // --- Formas do verbo "poder" ---
    'pode',
    'podem',
    'podendo',
    'poder',
    'poderia',
    'poderiam',
    'podia',
    'podiam',
    'posso',
    'pude',
    'puderam',

    // --- Formas do verbo "querer" ---
    'quer',
    'quereis',
    'querem',
    'queres',
    'quero',

    // --- Formas do verbo "saber" ---
    'sabe',
    'sabem',
    'sei',

    // --- Formas do verbo "dizer/fazer/dar" ---
    'dao',
    'dar',
    'disse',
    'disso',
    'diz',
    'dizem',
    'dizer',
    'faco',
    'faz',
    'fazeis',
    'fazem',
    'fazemos',
    'fazendo',
    'fazes',
    'fez',

    // --- Formas do verbo "dever" ---
    'deve',
    'devem',
    'devendo',
    'dever',
    'devera',
    'deverao',
    'deveria',
    'deveriam',
    'devia',
    'deviam',

    // --- Formas verbais genéricas ---
    'fica',
    'ficam',
    'ficava',
    'ficou',
    'ficar',
    'falar',
    'falou',
    'fazia',
    'feita',
    'feitas',
    'feito',
    'feitos',
    'fazer',
    'parece',
    'partir',
    'poem',

    // --- Numerais (não carregam emoção) ---
    'catorze',
    'cento',
    'cinco',
    'dez',
    'dezanove',
    'dezasseis',
    'dezassete',
    'dezoito',
    'dois',
    'doze',
    'duas',
    'mil',
    'nove',
    'oito',
    'onze',
    'quatro',
    'quinze',
    'seis',
    'sete',
    'tres',
    'treze',
    'vinte',
    'zero',

    // --- Ordinais (não carregam emoção) ---
    'oitava',
    'oitavo',
    'primeira',
    'primeiras',
    'primeiro',
    'primeiros',
    'quarta',
    'quarto',
    'quinta',
    'quinto',
    'segunda',
    'segundo',
    'setima',
    'setimo',
    'sexta',
    'sexto',
    'terceira',
    'terceiro',
    'ultima',
    'ultimas',
    'ultimo',
    'ultimos',

    // --- Adjetivos genéricos sem carga emocional própria ---
    'ampla',
    'amplas',
    'amplo',
    'amplos',
    'boa',
    'boas',
    'bom',
    'bons',
    'breve',
    'grande',
    'grandes',
    'maior',
    'menor',
    'nova',
    'novas',
    'novo',
    'novos',
    'pequena',
    'pequenas',
    'pequeno',
    'pequenos',
    'pouca',
    'poucas',
    'pouco',
    'poucos',
    'propria',
    'proprias',
    'proprio',
    'proprios',
    'proxima',
    'proximas',
    'proximo',
    'proximos',
    'tanta',
    'tantas',
    'tanto',
    'tao',

    // --- Substantivos genéricos sem valor emocional ---
    'ano',
    'anos',
    'coisa',
    'coisas',
    'dia',
    'duvida',
    'exemplo',
    'falta',
    'favor',
    'fim',
    'final',
    'forma',
    'geral',
    'grupo',
    'hora',
    'horas',
    'lado',
    'local',
    'lugar',
    'maioria',
    'maximo',
    'meio',
    'mes',
    'meses',
    'momento',
    'muita',
    'muitas',
    'muitos',
    'nivel',
    'noite',
    'nome',
    'numero',
    'obra',
    'obrigada',
    'obrigado',
    'parte',
    'ponto',
    'pontos',
    'possivel',
    'questao',
    'relacao',
    'sistema',
    'tal',
    'tipo',
    'trabalho',
    'vez',
    'vezes',
    'viagem',

    // --- Expressões de cortesia / interjeições ---
    'adeus',
    'etc',
  };

  /// Stopwords padrão do analisador, útil para composição com listas dinâmicas.
  static Set<String> get defaultStopwords =>
      Set.unmodifiable(_defaultStopwords);

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
    Set<String> stopwords = _defaultStopwords,
  }) {
    if (text.trim().isEmpty) return const [];

    final normalized = normalizeText(text);
    if (normalized.isEmpty) return const [];

    return normalized
        .split(' ')
        .where((token) => token.isNotEmpty)
        .where((token) => token.length >= minWordLength)
        .where((token) => !RegExp(r'\d').hasMatch(token))
        .where((token) => !stopwords.contains(token))
        .toList(growable: false);
  }

  WordInsightAnalysis analyzeStories(
    Iterable<StoryTextEntry> stories, {
    int minWordLength = defaultMinWordLength,
    int minFrequency = defaultMinFrequency,
    int topWordsLimit = defaultTopWordsLimit,
    double positiveMoodThreshold = defaultPositiveMoodThreshold,
    double difficultMoodThreshold = defaultDifficultMoodThreshold,
    bool countWordOncePerStory = true,
    Set<String> stopwords = _defaultStopwords,
  }) {
    final accumulators = <String, _WordAccumulator>{};
    var totalStoriesAnalyzed = 0;

    for (final story in stories) {
      final text = story.combinedText;
      if (text.isEmpty) {
        continue;
      }

      final tokens = tokenize(
        text,
        minWordLength: minWordLength,
        stopwords: stopwords,
      );
      if (tokens.isEmpty) {
        continue;
      }

      totalStoriesAnalyzed += 1;
      final iterable = countWordOncePerStory ? tokens.toSet() : tokens;
      for (final word in iterable) {
        final accumulator = accumulators.putIfAbsent(
          word,
          _WordAccumulator.new,
        );
        accumulator.add(story.mood);
      }
    }

    final rankedWords = accumulators.entries
        .where((entry) => entry.value.frequency >= minFrequency)
        .map(
          (entry) => WordAssociation(
            word: entry.key,
            frequency: entry.value.frequency,
            averageMood: entry.value.moodSum / entry.value.frequency,
          ),
        )
        .toList(growable: false);

    List<WordAssociation> rank(
      bool Function(WordAssociation association) predicate,
      bool descendingMood,
    ) {
      final filtered = rankedWords.where(predicate).toList();
      // Prioriza o sinal de humor (palavras mais fortemente associadas ao mood)
      // e usa frequência como critério de desempate para reduzir ruído.
      filtered.sort((a, b) {
        final moodCompare = descendingMood
            ? b.averageMood.compareTo(a.averageMood)
            : a.averageMood.compareTo(b.averageMood);
        if (moodCompare != 0) return moodCompare;

        final frequencyCompare = b.frequency.compareTo(a.frequency);
        if (frequencyCompare != 0) return frequencyCompare;

        return a.word.compareTo(b.word);
      });
      return filtered.take(topWordsLimit).toList(growable: false);
    }

    return WordInsightAnalysis(
      positiveWords: rank(
        (association) => association.averageMood >= positiveMoodThreshold,
        true,
      ),
      difficultWords: rank(
        (association) => association.averageMood <= difficultMoodThreshold,
        false,
      ),
      totalStoriesAnalyzed: totalStoriesAnalyzed,
      totalUniqueWords: accumulators.length,
    );
  }
}
