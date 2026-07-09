import '../db/database_helper.dart';
import '../helpers/rich_text_helper.dart';
import '../models/insight.dart';
import '../services/insight_preferences_service.dart';

/// Serviço responsável por calcular e cachear os insights automáticos.
///
/// Os insights são recalculados ao abrir a Home ou após 24h desde o
/// último cálculo. O resultado é armazenado em SharedPreferences.
class InsightService {
  /// Número mínimo de histórias totais para gerar qualquer insight.
  static const int _minTotalHistorias = 5;

  /// Número mínimo de histórias por tag ou por dia da semana.
  static const int _minGroupHistorias = 3;

  /// Limiar de diferença de humor para gerar insight de tendência.
  static const double _trendThreshold = 0.4;

  /// Máximo de insights exibidos simultaneamente.
  static const int _maxInsights = 20;

  final DatabaseHelper _db = DatabaseHelper();
  final InsightPreferencesService _preferencesService =
      InsightPreferencesService();

  // ---------------------------------------------------------------------------
  // API pública
  // ---------------------------------------------------------------------------

  /// Retorna a lista de insights para o usuário.
  ///
  /// Usa cache de 24h; passe [forceRefresh] = true para ignorar o cache.
  Future<List<Insight>> getInsights(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await _preferencesService.loadCache(userId);
      if (cached != null) return cached;
    }

    final insights = await _calculateAll(userId);
    await _preferencesService.saveCache(userId, insights);
    return insights;
  }

  // ---------------------------------------------------------------------------
  // Orquestrador interno
  // ---------------------------------------------------------------------------

  Future<List<Insight>> _calculateAll(String userId) async {
    // Verifica se há histórias suficientes no total
    final db = await _db.database;
    final totalResult = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM historia
      WHERE user_id = ?
        AND excluido IS NULL
      ''',
      [userId],
    );
    final total = (totalResult.first['total'] as int?) ?? 0;
    if (total < _minTotalHistorias) return [];

    // Dispara todos os cálculos em paralelo para melhor performance.
    final trendFuture = calculateTrend(userId);
    final positiveTagFuture = calculatePositiveTag(userId);
    final bestWeekdayFuture = calculateBestWeekday(userId);
    final monthlySummaryFuture = calculateMonthlySummary(userId);
    final storyBalanceFuture = calculateStoryBalance(userId);
    final writingTimeFuture = calculateWritingTime(userId);
    final moodChartFuture = calculateMoodChart(userId);
    final chapterEngagementFuture = calculateChapterEngagement(userId);
    final chapterHappiestFuture = calculateChapterHappiest(userId);
    final writingLengthFuture = calculateWritingLength(userId);
    final wellnessCircleFuture = calculateWellnessCircle(userId);
    final peacefulPlacesFuture = calculatePeacefulPlaces(userId);
    final breatheDeepFuture = calculateBreatheDeep(userId);

    final trendInsight = await trendFuture;
    final positiveTagInsight = await positiveTagFuture;
    final bestWeekdayInsight = await bestWeekdayFuture;
    final monthlySummaryInsight = await monthlySummaryFuture;
    final storyBalanceInsight = await storyBalanceFuture;
    final writingTimeInsight = await writingTimeFuture;
    final moodChartInsight = await moodChartFuture;
    final chapterEngagementInsight = await chapterEngagementFuture;
    final chapterHappiestInsight = await chapterHappiestFuture;
    final writingLengthInsight = await writingLengthFuture;
    final wellnessCircleInsight = await wellnessCircleFuture;
    final peacefulPlacesInsight = await peacefulPlacesFuture;
    final breatheDeepInsight = await breatheDeepFuture;

    // Prioridade: tendência > equilíbrio > horário > escrita detalhada > capítulos > tag > dia > resumo > energia
    final ordered = <Insight>[];
    if (trendInsight != null) ordered.add(trendInsight);
    if (storyBalanceInsight != null) ordered.add(storyBalanceInsight);
    if (writingTimeInsight != null) ordered.add(writingTimeInsight);
    if (writingLengthInsight != null) ordered.add(writingLengthInsight);
    if (chapterEngagementInsight != null) ordered.add(chapterEngagementInsight);
    if (chapterHappiestInsight != null) ordered.add(chapterHappiestInsight);
    if (wellnessCircleInsight != null) ordered.add(wellnessCircleInsight);
    if (peacefulPlacesInsight != null) ordered.add(peacefulPlacesInsight);
    if (breatheDeepInsight != null) ordered.add(breatheDeepInsight);
    if (positiveTagInsight != null) ordered.add(positiveTagInsight);
    if (bestWeekdayInsight != null) ordered.add(bestWeekdayInsight);
    if (monthlySummaryInsight != null) ordered.add(monthlySummaryInsight);
    if (moodChartInsight != null) ordered.add(moodChartInsight);

    // Limita ao máximo configurado
    return ordered.take(_maxInsights).toList();
  }

  // ---------------------------------------------------------------------------
  // Cálculo: Melhor Dia da Semana (§4)
  // ---------------------------------------------------------------------------

  /// Identifica o dia da semana com maior humor médio do usuário.
  /// Retorna null se não houver dados suficientes.
  Future<Insight?> calculateBestWeekday(String userId) async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      '''
      SELECT
        strftime('%w', data) AS dia_semana,
        AVG(humor)           AS media_humor,
        COUNT(*)             AS total
      FROM historia
      WHERE user_id = ?
        AND excluido IS NULL
      GROUP BY dia_semana
      HAVING total >= ?
      ORDER BY media_humor DESC
      LIMIT 1
      ''',
      [userId, _minGroupHistorias],
    );

    if (rows.isEmpty) return null;

    final row = rows.first;
    final diaSemanaIndex = int.tryParse(row['dia_semana'] as String? ?? '');
    if (diaSemanaIndex == null) return null;

    return Insight(
      type: InsightType.bestWeekday,
      icon: '💡',
      title: 'insightDiscovery', // chave l10n — resolvida no widget
      description: 'insightBestWeekday', // chave l10n — resolvida no widget
      metadata: {
        'weekday_index': diaSemanaIndex,
        'avg_mood': (row['media_humor'] as num?)?.toDouble() ?? 0.0,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Cálculo: Tag com Humor Mais Positivo (§5)
  // ---------------------------------------------------------------------------

  /// Identifica a tag associada ao maior humor médio.
  /// Retorna null se não houver dados suficientes.
  Future<Insight?> calculatePositiveTag(String userId) async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      '''
      SELECT
        t.nome,
        AVG(h.humor) AS media_humor,
        COUNT(*)     AS total
      FROM historia h
      JOIN historia_tags ht ON ht.historia_id = h.id
      JOIN tags t           ON t.id = ht.tag_id
      WHERE h.user_id = ?
        AND h.excluido IS NULL
      GROUP BY t.id
      HAVING total >= ?
      ORDER BY media_humor DESC
      LIMIT 1
      ''',
      [userId, _minGroupHistorias],
    );

    if (rows.isEmpty) return null;

    final row = rows.first;
    final tagNome = row['nome'] as String?;
    if (tagNome == null) return null;

    return Insight(
      type: InsightType.positiveTag,
      icon: '💡',
      title: 'insightPattern', // chave l10n
      description: 'insightPositiveTag', // chave l10n
      metadata: {
        'tag': tagNome,
        'avg_mood': (row['media_humor'] as num?)?.toDouble() ?? 0.0,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Cálculo: Tendência Recente (§6)
  // ---------------------------------------------------------------------------

  /// Compara humor médio dos últimos 7 dias com o dos últimos 30 dias.
  /// Gera insight positivo se a diferença for >= 0.4.
  /// Retorna null se não houver dados suficientes ou tendência relevante.
  Future<Insight?> calculateTrend(String userId) async {
    final db = await _db.database;

    final rows7 = await db.rawQuery(
      '''
      SELECT AVG(humor) AS media
      FROM historia
      WHERE user_id = ?
        AND excluido IS NULL
        AND data >= datetime('now', '-7 day')
      ''',
      [userId],
    );

    final rows30 = await db.rawQuery(
      '''
      SELECT AVG(humor) AS media
      FROM historia
      WHERE user_id = ?
        AND excluido IS NULL
        AND data >= datetime('now', '-30 day')
      ''',
      [userId],
    );

    final media7 = (rows7.first['media'] as num?)?.toDouble();
    final media30 = (rows30.first['media'] as num?)?.toDouble();

    if (media7 == null || media30 == null) return null;
    if (media7 - media30 < _trendThreshold) return null;

    return Insight(
      type: InsightType.trend,
      icon: '📈',
      title: 'insightTrend', // chave l10n
      description: 'insightTrendPositive', // chave l10n
      metadata: {
        'avg_7d': media7,
        'avg_30d': media30,
        'diff': media7 - media30,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Cálculo: Resumo do Mês (§7)
  // ---------------------------------------------------------------------------

  /// Gera um resumo do mês atual com total de histórias, humor médio,
  /// energia média e tag mais frequente.
  /// Retorna null se não houver histórias no mês.
  Future<Insight?> calculateMonthlySummary(String userId) async {
    final db = await _db.database;

    final summaryRows = await db.rawQuery(
      '''
      SELECT
        COUNT(*)     AS total,
        AVG(humor)   AS humor_medio,
        AVG(energia) AS energia_media
      FROM historia
      WHERE user_id = ?
        AND excluido IS NULL
        AND strftime('%Y-%m', data) = strftime('%Y-%m', 'now', 'localtime')
      ''',
      [userId],
    );

    if (summaryRows.isEmpty) return null;
    final summary = summaryRows.first;
    final total = (summary['total'] as int?) ?? 0;
    if (total == 0) return null;

    final humorMedio = (summary['humor_medio'] as num?)?.toDouble() ?? 0.0;
    final energiaMedia = (summary['energia_media'] as num?)?.toDouble() ?? 0.0;

    // Tag mais usada no mês
    final tagRows = await db.rawQuery(
      '''
      SELECT
        t.nome,
        COUNT(*) AS total
      FROM historia h
      JOIN historia_tags ht ON ht.historia_id = h.id
      JOIN tags t           ON t.id = ht.tag_id
      WHERE h.user_id = ?
        AND h.excluido IS NULL
        AND strftime('%Y-%m', h.data) = strftime('%Y-%m', 'now', 'localtime')
      GROUP BY t.id, t.nome
      ORDER BY total DESC, MAX(h.data) DESC, t.nome ASC
      LIMIT 1
      ''',
      [userId],
    );

    final topTag = tagRows.isNotEmpty ? tagRows.first['nome'] as String? : null;

    return Insight(
      type: InsightType.monthlySummary,
      icon: '📊',
      title: 'insightMonthlySummary', // chave l10n
      description: 'insightMonthlySummaryText', // chave l10n
      metadata: {
        'total': total,
        'humor_medio': humorMedio,
        'energia_media': energiaMedia,
        'top_tag': ?topTag,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Cálculo: Equilíbrio de Histórias (últimos 10 dias) — FREE
  // ---------------------------------------------------------------------------

  /// Compara histórias positivas (humor >= 4) vs difíceis (humor <= 2) nos últimos 10 dias.
  /// Retorna null se não houver dominância clara ou dados insuficientes.
  Future<Insight?> calculateStoryBalance(String userId) async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      '''
      SELECT
        SUM(CASE WHEN humor >= 4 THEN 1 ELSE 0 END) AS positive,
        SUM(CASE WHEN humor <= 2 THEN 1 ELSE 0 END) AS difficult,
        COUNT(*) AS total
      FROM historia
      WHERE user_id = ?
        AND excluido IS NULL
        AND date(data) >= date('now', '-9 day')
      ''',
      [userId],
    );

    if (rows.isEmpty) return null;
    final positive = (rows.first['positive'] as int?) ?? 0;
    final difficult = (rows.first['difficult'] as int?) ?? 0;
    final total = (rows.first['total'] as int?) ?? 0;

    if (total < _minTotalHistorias) return null;
    if (positive < _minGroupHistorias && difficult < _minGroupHistorias) {
      return null;
    }

    // Exige dominância clara (50% mais do lado dominante)
    final larger = positive > difficult ? positive : difficult;
    final smaller = positive > difficult ? difficult : positive;
    if (smaller > 0 && larger < smaller * 1.5) return null;

    final isPositive = positive >= difficult;
    return Insight(
      type: InsightType.storyBalance,
      icon: isPositive ? '🌟' : '⛈️',
      title: 'insightStoryBalanceTitle',
      description: isPositive
          ? 'insightStoryBalancePositive'
          : 'insightStoryBalanceDifficult',
      metadata: {
        'balance': isPositive ? 'positive' : 'difficult',
        'positive_count': positive,
        'difficult_count': difficult,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Cálculo: Horário de Escrita (esta semana) — FREE
  // ---------------------------------------------------------------------------

  /// Identifica o período do dia com mais histórias escritas nos últimos 7 dias.
  /// Períodos: manhã (5–11h), tarde (12–17h), noite (18‣4h).
  /// Retorna null se não houver dados suficientes.
  Future<Insight?> calculateWritingTime(String userId) async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      '''
      SELECT
        CASE
          WHEN CAST(strftime('%H', data) AS INTEGER) BETWEEN 5 AND 11 THEN 'morning'
          WHEN CAST(strftime('%H', data) AS INTEGER) BETWEEN 12 AND 17 THEN 'afternoon'
          ELSE 'night'
        END AS period,
        COUNT(*) AS total
      FROM historia
      WHERE user_id = ?
        AND excluido IS NULL
        AND date(data) >= date('now', '-6 day')
      GROUP BY period
      ORDER BY total DESC
      LIMIT 1
      ''',
      [userId],
    );

    if (rows.isEmpty) return null;
    final total = (rows.first['total'] as int?) ?? 0;
    if (total < _minGroupHistorias) return null;

    final period = rows.first['period'] as String? ?? 'night';
    final icon = switch (period) {
      'morning' => '🌅',
      'afternoon' => '☀️',
      _ => '🌙',
    };

    return Insight(
      type: InsightType.writingTime,
      icon: icon,
      title: 'insightWritingTimeTitle',
      description: period,
      metadata: {'period': period, 'count': total},
    );
  }

  // ---------------------------------------------------------------------------
  // Cálculo: Gráfico de Humor — 7 dias (PREMIUM)
  // ---------------------------------------------------------------------------

  /// Coleta o humor médio por dia nos últimos 7 dias e retorna um insight
  /// com os dados para renderizar o gráfico de barras.
  /// Retorna null se houver menos de 3 dias com registro.
  Future<Insight?> calculateMoodChart(String userId) async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      '''
      SELECT
        date(data)           AS day,
        strftime('%w', data) AS weekday_idx,
        AVG(humor)           AS avg_mood
      FROM historia
      WHERE user_id = ?
        AND excluido IS NULL
        AND data >= date('now', '-6 day')
      GROUP BY date(data)
      ORDER BY date(data) ASC
      ''',
      [userId],
    );

    // Monta mapa dia → humor médio
    final moodByDay = <String, double>{};
    for (final row in rows) {
      final day = row['day'] as String?;
      if (day != null) {
        moodByDay[day] = (row['avg_mood'] as num?)?.toDouble() ?? 0.0;
      }
    }

    // Preenche os 7 dias (do mais antigo ao mais recente)
    final now = DateTime.now();
    final moodData = <double>[];
    final weekdayIdxs = <int>[];

    for (var i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayStr =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      moodData.add(moodByDay[dayStr] ?? 0.0);
      // Converte Dart weekday (1=Seg..7=Dom) para SQLite (0=Dom..6=Sáb)
      weekdayIdxs.add(day.weekday % 7);
    }

    final daysWithData = moodData.where((value) => value > 0).length;
    if (daysWithData < 3) return null;

    final avgMood =
        moodData.where((value) => value > 0).reduce((a, b) => a + b) /
        daysWithData;

    return Insight(
      type: InsightType.energyChart,
      icon: '⚡',
      title: 'insightMoodChartTitle',
      description: 'insightMoodChartSubtitle',
      metadata: {
        'mood_data': moodData,
        'weekday_indices': weekdayIdxs,
        'avg_mood': avgMood,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Cálculo: Capítulo Mais Ativo (PREMIUM)
  // ---------------------------------------------------------------------------

  /// Encontra o capítulo com o maior número de histórias registradas.
  Future<Insight?> calculateChapterEngagement(String userId) async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      '''
      SELECT c.titulo, COUNT(ce.entrada_id) AS total_entradas
      FROM capitulos c
      JOIN capitulo_entradas ce ON ce.capitulo_id = c.id
      JOIN historia h ON h.id = ce.entrada_id AND h.excluido IS NULL
      WHERE c.user_id = ?
      GROUP BY c.id
      HAVING total_entradas >= 3
      ORDER BY total_entradas DESC
      LIMIT 1
      ''',
      [userId],
    );

    if (rows.isEmpty) return null;

    final row = rows.first;
    final titulo = row['titulo'] as String?;
    final total = row['total_entradas'] as int? ?? 0;
    if (titulo == null || titulo.isEmpty) return null;

    return Insight(
      type: InsightType.chapterEngagement,
      icon: '📖',
      title: 'insightChapterEngagementTitle',
      description: 'insightChapterEngagementDesc',
      metadata: {'chapter_title': titulo, 'count': total},
    );
  }

  // ---------------------------------------------------------------------------
  // Cálculo: Capítulo Mais Feliz (PREMIUM)
  // ---------------------------------------------------------------------------

  /// Encontra o capítulo com a maior média de humor.
  Future<Insight?> calculateChapterHappiest(String userId) async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      '''
      SELECT c.titulo, AVG(h.humor) AS media_humor, COUNT(ce.entrada_id) AS total_entradas
      FROM capitulos c
      JOIN capitulo_entradas ce ON ce.capitulo_id = c.id
      JOIN historia h ON h.id = ce.entrada_id AND h.excluido IS NULL
      WHERE c.user_id = ?
      GROUP BY c.id
      HAVING total_entradas >= 3
      ORDER BY media_humor DESC
      LIMIT 1
      ''',
      [userId],
    );

    if (rows.isEmpty) return null;

    final row = rows.first;
    final titulo = row['titulo'] as String?;
    final mediaHumor = (row['media_humor'] as num?)?.toDouble() ?? 0.0;
    if (titulo == null || titulo.isEmpty) return null;

    return Insight(
      type: InsightType.chapterHappiest,
      icon: '💖',
      title: 'insightChapterHappiestTitle',
      description: 'insightChapterHappiestDesc',
      metadata: {'chapter_title': titulo, 'avg_mood': mediaHumor},
    );
  }

  // ---------------------------------------------------------------------------
  // Cálculo: Estimulador de Escrita Longa (FREE)
  // ---------------------------------------------------------------------------

  /// Incentiva o usuário a detalhar suas reflexões se a média semanal for baixa,
  /// ou o parabeniza se tiver escrito um diário substancial recentemente.
  Future<Insight?> calculateWritingLength(String userId) async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      '''
      SELECT descricao, data
      FROM historia
      WHERE user_id = ?
        AND excluido IS NULL
        AND data >= date('now', '-6 day')
      ORDER BY data DESC
      ''',
      [userId],
    );

    if (rows.isEmpty) return null;

    final wordsList = rows.map((r) {
      final text = r['descricao'] as String? ?? '';
      final plainText = RichTextHelper.jsonToPlainText(text);
      return plainText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    }).toList();

    // 1. Verifica se escreveu uma história longa nos últimos 3 dias (ex: > 150 palavras)
    final now = DateTime.now();
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final dateStr = row['data'] as String? ?? '';
      final date = DateTime.tryParse(dateStr);
      if (date != null && now.difference(date).inDays <= 3) {
        final words = wordsList[i];
        if (words > 150) {
          return Insight(
            type: InsightType.writingLength,
            icon: '✍️',
            title: 'insightWritingLengthTitle',
            description: 'insightWritingLengthCongrats',
            metadata: {'style': 'congrats', 'count': words},
          );
        }
      }
    }

    // 2. Se tiver pelo menos 3 histórias na semana e média de palavras < 40, sugere escrever mais
    if (wordsList.length >= 3) {
      final totalWords = wordsList.reduce((a, b) => a + b);
      final avgWords = totalWords / wordsList.length;
      if (avgWords < 40) {
        return Insight(
          type: InsightType.writingLength,
          icon: '✍️',
          title: 'insightWritingLengthTitle',
          description: 'insightWritingLengthTip',
          metadata: {'style': 'tip', 'avg_words': avgWords.round()},
        );
      }
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Cálculo: Círculo de Bem-Estar (PREMIUM)
  // ---------------------------------------------------------------------------

  /// Pessoas mais presentes quando o dia foi radiante
  /// (humor entre 4 e 5, energia = 3).
  Future<Insight?> calculateWellnessCircle(String userId) async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      '''
      SELECT p.nome, COUNT(*) AS total
      FROM historia h
      JOIN historia_pessoas hp ON hp.historia_id = h.id
      JOIN pessoas p ON p.id = hp.pessoa_id
      WHERE h.user_id = ?
        AND h.excluido IS NULL
        AND h.humor BETWEEN 4 AND 5
        AND h.energia = 3
      GROUP BY p.id, p.nome
      HAVING total >= ?
      ORDER BY total DESC, MAX(h.data) DESC, p.nome ASC
      LIMIT 3
      ''',
      [userId, _minGroupHistorias],
    );

    if (rows.isEmpty) return null;

    final names = rows
        .map((r) => (r['nome'] as String? ?? '').trim())
        .where((name) => name.isNotEmpty)
        .toList();
    if (names.isEmpty) return null;

    final totalStoriesRows = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM historia
      WHERE user_id = ?
        AND excluido IS NULL
        AND humor BETWEEN 4 AND 5
        AND energia = 3
      ''',
      [userId],
    );
    final totalStories = (totalStoriesRows.first['total'] as int?) ?? 0;

    return Insight(
      type: InsightType.wellnessCircle,
      icon: '🤝',
      title: 'insightWellnessCircleTitle',
      description: 'insightWellnessCircleDescription',
      metadata: {
        'names': names,
        'count': names.length,
        'stories_count': totalStories,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Cálculo: Locais de Paz (PREMIUM)
  // ---------------------------------------------------------------------------

  /// Locais com humor positivo consistente
  /// (humor entre 4 e 5, energia 2 ou 3).
  Future<Insight?> calculatePeacefulPlaces(String userId) async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      '''
      SELECT h.local, COUNT(*) AS total, AVG(h.humor) AS avg_mood
      FROM historia h
      WHERE h.user_id = ?
        AND h.excluido IS NULL
        AND h.local IS NOT NULL
        AND TRIM(h.local) <> ''
        AND h.humor BETWEEN 4 AND 5
        AND h.energia IN (2, 3)
      GROUP BY LOWER(TRIM(h.local))
      HAVING total >= ?
      ORDER BY avg_mood DESC, total DESC, MAX(h.data) DESC
      LIMIT 3
      ''',
      [userId, _minGroupHistorias],
    );

    if (rows.isEmpty) return null;

    final places = rows
        .map((r) => (r['local'] as String? ?? '').trim())
        .where((place) => place.isNotEmpty)
        .toList();
    if (places.isEmpty) return null;

    final avgMood = (rows.first['avg_mood'] as num?)?.toDouble() ?? 0.0;

    return Insight(
      type: InsightType.peacefulPlaces,
      icon: '🌿',
      title: 'insightPeacefulPlacesTitle',
      description: 'insightPeacefulPlacesDescription',
      metadata: {'places': places, 'count': places.length, 'avg_mood': avgMood},
    );
  }

  // ---------------------------------------------------------------------------
  // Cálculo: Respirar Fundo (PREMIUM)
  // ---------------------------------------------------------------------------

  /// Locais com baixa energia e humor
  /// (humor entre 1 e 2, energia = 1).
  Future<Insight?> calculateBreatheDeep(String userId) async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      '''
      SELECT h.local, COUNT(*) AS total
      FROM historia h
      WHERE h.user_id = ?
        AND h.excluido IS NULL
        AND h.local IS NOT NULL
        AND TRIM(h.local) <> ''
        AND h.humor BETWEEN 1 AND 2
        AND h.energia = 1
      GROUP BY LOWER(TRIM(h.local))
      HAVING total >= ?
      ORDER BY total DESC, MAX(h.data) DESC
      LIMIT 3
      ''',
      [userId, _minGroupHistorias],
    );

    if (rows.isEmpty) return null;

    final places = rows
        .map((r) => (r['local'] as String? ?? '').trim())
        .where((place) => place.isNotEmpty)
        .toList();
    if (places.isEmpty) return null;

    return Insight(
      type: InsightType.breatheDeep,
      icon: '🫁',
      title: 'insightBreatheDeepTitle',
      description: 'insightBreatheDeepDescription',
      metadata: {'places': places, 'count': places.length},
    );
  }
}
