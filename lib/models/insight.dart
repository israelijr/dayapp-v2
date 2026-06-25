import 'dart:convert';

/// Tipos de insights suportados pelo sistema.
enum InsightType {
  bestWeekday,
  positiveTag,
  trend,
  monthlySummary, // PREMIUM
  storyBalance, // FREE: proporção positivas vs difíceis (últimos 10 dias)
  writingTime, // FREE: período do dia mais frequente de escrita (esta semana)
  energyChart, // gráfico de humor dos últimos 7 dias
  writingLength, // FREE: incentivo de escrita de textos maiores/longos
  chapterEngagement, // PREMIUM: engajamento do capítulo
  chapterHappiest; // PREMIUM: capítulo mais feliz

  /// Converte para string armazenável (cache, banco).
  String get value {
    switch (this) {
      case InsightType.bestWeekday:
        return 'best_weekday';
      case InsightType.positiveTag:
        return 'positive_tag';
      case InsightType.trend:
        return 'trend';
      case InsightType.monthlySummary:
        return 'monthly_summary';
      case InsightType.storyBalance:
        return 'story_balance';
      case InsightType.writingTime:
        return 'writing_time';
      case InsightType.energyChart:
        return 'energy_chart';
      case InsightType.writingLength:
        return 'writing_length';
      case InsightType.chapterEngagement:
        return 'chapter_engagement';
      case InsightType.chapterHappiest:
        return 'chapter_happiest';
    }
  }

  /// Reconstrói a partir da string armazenada.
  static InsightType fromString(String value) {
    switch (value) {
      case 'best_weekday':
        return InsightType.bestWeekday;
      case 'positive_tag':
        return InsightType.positiveTag;
      case 'trend':
        return InsightType.trend;
      case 'monthly_summary':
        return InsightType.monthlySummary;
      case 'story_balance':
        return InsightType.storyBalance;
      case 'writing_time':
        return InsightType.writingTime;
      case 'energy_chart':
        return InsightType.energyChart;
      case 'writing_length':
        return InsightType.writingLength;
      case 'chapter_engagement':
        return InsightType.chapterEngagement;
      case 'chapter_happiest':
        return InsightType.chapterHappiest;
      default:
        // Tipo desconhecido (cache antigo) — trata como tendência por segurança
        return InsightType.trend;
    }
  }

  /// Indica se este tipo de insight é exclusivo para usuários Premium.
  bool get isPremium {
    switch (this) {
      case InsightType.monthlySummary:
      case InsightType.energyChart:
      case InsightType.chapterEngagement:
      case InsightType.chapterHappiest:
        return true;
      default:
        return false;
    }
  }
}

/// Representa um insight gerado automaticamente a partir das histórias.
///
/// Os insights são exibidos como cards no topo da Home, abaixo do card de capítulos.
class Insight {
  /// Tipo do insight (determina a query e o layout de texto).
  final InsightType type;

  /// Título exibido no card (ex.: "Descoberta").
  final String title;

  /// Texto descritivo principal do insight.
  final String description;

  /// Emoji ou ícone representativo.
  final String icon;

  /// Metadados adicionais usados pelo card (tag, dia da semana, etc.).
  final Map<String, dynamic>? metadata;

  /// Indica se o insight exige o plano Premium.
  bool get isPremium => type.isPremium;

  Insight({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    this.metadata,
  });

  /// Reconstrói um Insight a partir de um mapa (cache JSON).
  factory Insight.fromMap(Map<String, dynamic> map) {
    return Insight(
      type: InsightType.fromString(map['type'] as String),
      title: map['title'] as String,
      description: map['description'] as String,
      icon: map['icon'] as String,
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : null,
    );
  }

  /// Serializa para mapa (cache JSON).
  Map<String, dynamic> toMap() {
    return {
      'type': type.value,
      'title': title,
      'description': description,
      'icon': icon,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Serializa lista de insights para JSON (usado no cache local).
  static String encodeList(List<Insight> insights) {
    return jsonEncode(insights.map((i) => i.toMap()).toList());
  }

  /// Reconstrói lista de insights a partir de JSON (cache local).
  static List<Insight> decodeList(String json) {
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((item) => Insight.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  @override
  String toString() => 'Insight(type: ${type.value}, title: $title)';
}
