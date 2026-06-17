import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/insight.dart';
import '../providers/premium_provider.dart';
import '../theme/animation_durations.dart';
import '../widgets/mood_energy_selectors.dart';

/// Card que exibe um insight gerado automaticamente no topo da Home.
///
/// Layout:
/// ```
/// [ícone] [título]  [X dispensar]
/// [descrição]
/// [gráfico de barras]  ← apenas InsightType.energyChart (humor)
/// [ Ver histórias ]    ← opcional
/// ```
///
/// Se o insight for Premium e o usuário não tiver o plano, exibe um teaser
/// com lock e CTA de upgrade.
class InsightCard extends StatelessWidget {
  final Insight insight;

  /// Chamado quando o usuário toca em "Ver histórias".
  final void Function(String query)? onSeeStories;

  /// Chamado quando o usuário dispensa (fecha) o insight.
  final VoidCallback? onDismiss;

  /// Chamado quando o usuário tocar duas vezes no insight.
  final VoidCallback? onDoubleTap;

  /// Chamado quando o usuário toca no CTA de upgrade para Premium.
  final VoidCallback? onPremiumCTA;

  const InsightCard({
    required this.insight,
    this.onSeeStories,
    this.onDismiss,
    this.onDoubleTap,
    this.onPremiumCTA,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final premium = context.watch<PremiumProvider>();
    final isPremiumUser = premium.isPremium;
    final isLocked = insight.isPremium && !isPremiumUser;

    final title = _resolveTitle(l10n);
    final description = _resolveDescription(l10n);
    final searchQuery = _resolveSearchQuery();
    final showButton =
        !isLocked &&
        onSeeStories != null &&
        searchQuery != null &&
        searchQuery.isNotEmpty;

    final cardColor = insight.type == InsightType.energyChart
        ? colorScheme.surface.withValues(alpha: 0.88)
        : colorScheme.secondaryContainer;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: AnimatedContainer(
        duration: AppDurations.short,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: onDoubleTap,
          child: Card(
            elevation: 0,
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: colorScheme.secondary.withValues(alpha: 0.25),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (insight.type != InsightType.energyChart) ...[
                    // Cabeçalho: ícone + título + badge premium + botão dispensar
                    Row(
                      children: [
                        Text(
                          insight.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  style: GoogleFonts.playfairDisplay(
                                    textStyle: theme.textTheme.titleSmall
                                        ?.copyWith(
                                          color:
                                              colorScheme.onSecondaryContainer,
                                          fontWeight: FontWeight.w600,
                                          height: 1.1,
                                        ),
                                  ),
                                ),
                              ),
                              if (insight.isPremium) ...[
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.workspace_premium,
                                  size: 14,
                                  color: colorScheme.primary,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (onDismiss != null)
                          IconButton(
                            tooltip: l10n.insightDismiss,
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: onDismiss,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                            color: colorScheme.onSecondaryContainer.withValues(
                              alpha: 0.6,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],

                  // Corpo: conteúdo bloqueado ou conteúdo normal
                  if (isLocked)
                    _buildPremiumLock(context, l10n, theme, colorScheme)
                  else if (insight.type == InsightType.energyChart)
                    _buildMoodChartCard(l10n, theme, colorScheme, onDismiss)
                  else ...[
                    Text(
                      description,
                      style: GoogleFonts.plusJakartaSans(
                        textStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          height: 1.4,
                        ),
                      ),
                    ),
                    // Botão "Ver histórias"
                    if (showButton) ...[
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => onSeeStories!(searchQuery),
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.secondary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                          ),
                          child: Text(
                            l10n.insightSeeStories,
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: theme.textTheme.labelLarge?.copyWith(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Conteúdo bloqueado (Premium)
  // ---------------------------------------------------------------------------

  Widget _buildPremiumLock(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lock_outline, size: 16, color: colorScheme.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                l10n.insightPremiumRequired,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSecondaryContainer.withValues(
                    alpha: 0.75,
                  ),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.tonalIcon(
            icon: const Icon(Icons.workspace_premium, size: 16),
            label: Text(l10n.insightPremiumCTA),
            onPressed:
                onPremiumCTA ??
                () => Navigator.of(context).pushNamed('/premium'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              textStyle: theme.textTheme.labelMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodChartCard(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
    VoidCallback? onDismiss,
  ) {
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 6));
    final periodLabel = l10n.chapterPeriod(
      DateFormat('dd/MM').format(start),
      DateFormat('dd/MM').format(today),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _resolveTitle(l10n),
                    style: GoogleFonts.playfairDisplay(
                      textStyle: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                        height: 1.05,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    periodLabel,
                    style: GoogleFonts.plusJakartaSans(
                      textStyle: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSecondaryContainer.withValues(
                          alpha: 0.74,
                        ),
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _resolveDescription(l10n),
                    style: GoogleFonts.plusJakartaSans(
                      textStyle: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSecondaryContainer.withValues(
                          alpha: 0.74,
                        ),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_graph,
                size: 24,
                color: colorScheme.primary,
              ),
            ),
            if (onDismiss != null) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: l10n.insightDismiss,
                icon: const Icon(Icons.close, size: 18),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                color: colorScheme.onSecondaryContainer.withValues(alpha: 0.6),
              ),
            ],
          ],
        ),
        const SizedBox(height: 18),
        _buildMoodChart(l10n, theme, colorScheme),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Gráfico de barras de humor
  // ---------------------------------------------------------------------------

  Widget _buildMoodChart(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final moodData =
        (insight.metadata?['mood_data'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        List.filled(7, 0.0);
    final weekdayIndices =
        (insight.metadata?['weekday_indices'] as List<dynamic>?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        List.generate(7, (i) => i);

    const maxBarHeight = 98.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: maxBarHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (
                var i = 0;
                i < moodData.length && i < weekdayIndices.length;
                i++
              )
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: moodData[i] == 0
                            ? 16
                            : (16 +
                                  (maxBarHeight - 16) *
                                      ((moodData[i].clamp(1.0, 5.0) - 1) / 4)),
                        width: 34,
                        decoration: BoxDecoration(
                          color: _barColor(moodData[i], colorScheme),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (
              var i = 0;
              i < moodData.length && i < weekdayIndices.length;
              i++
            )
              Expanded(
                child: Text(
                  _weekdayAbbr(l10n, weekdayIndices[i]).toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    textStyle: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSecondaryContainer.withValues(
                        alpha: 0.7,
                      ),
                      fontSize: 10,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Color _barColor(double mood, ColorScheme colorScheme) {
    final value = mood.round();
    switch (value) {
      case 1:
        return colorScheme.error.withValues(alpha: 0.75);
      case 2:
        return colorScheme.error.withValues(alpha: 0.55);
      case 3:
        return colorScheme.secondary.withValues(alpha: 0.7);
      case 4:
        return colorScheme.tertiary.withValues(alpha: 0.85);
      case 5:
        return colorScheme.primary.withValues(alpha: 0.88);
      default:
        return colorScheme.surfaceContainerHighest;
    }
  }

  // ---------------------------------------------------------------------------
  // Resolução de título a partir da chave l10n
  // ---------------------------------------------------------------------------

  String _resolveTitle(AppLocalizations l10n) {
    switch (insight.type) {
      case InsightType.bestWeekday:
        return l10n.insightDiscovery;
      case InsightType.positiveTag:
        return l10n.insightPattern;
      case InsightType.trend:
        return l10n.insightTrend;
      case InsightType.monthlySummary:
        return l10n.insightMonthlySummary;
      case InsightType.storyBalance:
        return l10n.insightStoryBalanceTitle;
      case InsightType.writingTime:
        return l10n.insightWritingTimeTitle;
      case InsightType.energyChart:
        return _resolveMoodChartTitle(l10n);
    }
  }

  // ---------------------------------------------------------------------------
  // Resolução de descrição a partir dos metadados e chaves l10n
  // ---------------------------------------------------------------------------

  String _resolveDescription(AppLocalizations l10n) {
    switch (insight.type) {
      case InsightType.bestWeekday:
        return _resolveBestWeekday(l10n);
      case InsightType.positiveTag:
        return _resolvePositiveTag(l10n);
      case InsightType.trend:
        return l10n.insightTrendPositive;
      case InsightType.monthlySummary:
        return _resolveMonthlySummary(l10n);
      case InsightType.storyBalance:
        return _resolveStoryBalance(l10n);
      case InsightType.writingTime:
        return _resolveWritingTime(l10n);
      case InsightType.energyChart:
        return _resolveMoodChartSubtitle(l10n);
    }
  }

  String _resolveMoodChartTitle(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'pt':
      case 'pt_BR':
        return 'Humor — 7 Dias';
      case 'en':
        return 'Mood — Last 7 Days';
      case 'es':
        return 'Humor — 7 Días';
      case 'fr':
        return 'Humeur — 7 derniers jours';
      case 'it':
        return 'Umore — Ultimi 7 giorni';
      default:
        return 'Mood — Last 7 Days';
    }
  }

  String _resolveMoodChartSubtitle(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'pt':
      case 'pt_BR':
        return 'Sua variação de humor essa semana';
      case 'en':
        return 'Your mood variation this week';
      case 'es':
        return 'Tu variación de humor esta semana';
      case 'fr':
        return 'Votre variation d\'humeur cette semaine';
      case 'it':
        return 'La tua variazione di umore questa settimana';
      default:
        return 'Your mood variation this week';
    }
  }

  String _resolveBestWeekday(AppLocalizations l10n) {
    final index = insight.metadata?['weekday_index'] as int? ?? 0;
    final weekday = _weekdayName(l10n, index);
    return l10n.insightBestWeekday(weekday);
  }

  String _resolvePositiveTag(AppLocalizations l10n) {
    final tag = insight.metadata?['tag'] as String? ?? '';
    return l10n.insightPositiveTag(tag);
  }

  String _resolveMonthlySummary(AppLocalizations l10n) {
    final total = insight.metadata?['total'] as int? ?? 0;
    final humorMedio =
        (insight.metadata?['humor_medio'] as num?)?.toDouble() ?? 0.0;
    final energiaMedia =
        (insight.metadata?['energia_media'] as num?)?.toDouble() ?? 0.0;
    final topTag = insight.metadata?['top_tag'] as String?;

    // Converte médias numéricas para emojis representativos
    final moodStr = moodEmoji(humorMedio.round().clamp(1, 5));
    final energyStr = _energyEmoji(energiaMedia.round().clamp(1, 3));

    if (topTag != null && topTag.isNotEmpty) {
      return l10n.insightMonthlySummaryWithTag(
        total,
        moodStr,
        energyStr,
        topTag,
      );
    }
    return l10n.insightMonthlySummaryText(total, moodStr, energyStr);
  }

  String _resolveStoryBalance(AppLocalizations l10n) {
    final balance = insight.metadata?['balance'] as String?;
    return balance == 'difficult'
        ? l10n.insightStoryBalanceDifficult
        : l10n.insightStoryBalancePositive;
  }

  String _resolveWritingTime(AppLocalizations l10n) {
    final period = insight.metadata?['period'] as String?;
    switch (period) {
      case 'morning':
        return l10n.insightWritingTimeMorning;
      case 'afternoon':
        return l10n.insightWritingTimeAfternoon;
      default:
        return l10n.insightWritingTimeNight;
    }
  }

  String? _resolveSearchQuery() {
    final directQuery = insight.metadata?['search_query'] as String?;
    if (directQuery != null && directQuery.isNotEmpty) {
      return directQuery;
    }

    final tag = insight.metadata?['tag'] as String?;
    if (tag != null && tag.isNotEmpty) {
      return tag;
    }

    final words = insight.metadata?['words'] as List<dynamic>?;
    final firstWord = words?.whereType<String>().firstWhere(
      (word) => word.isNotEmpty,
      orElse: () => '',
    );

    if (firstWord == null || firstWord.isEmpty) {
      return null;
    }
    return firstWord;
  }

  /// Mapeia índice SQLite strftime('%w') para abreviação localizada do dia (3 chars).
  String _weekdayAbbr(AppLocalizations l10n, int index) {
    switch (index) {
      case 0:
        return l10n.weekdaySunday.substring(0, 3);
      case 1:
        return l10n.weekdayMonday.substring(0, 3);
      case 2:
        return l10n.weekdayTuesday.substring(0, 3);
      case 3:
        return l10n.weekdayWednesday.substring(0, 3);
      case 4:
        return l10n.weekdayThursday.substring(0, 3);
      case 5:
        return l10n.weekdayFriday.substring(0, 3);
      case 6:
        return l10n.weekdaySaturday.substring(0, 3);
      default:
        return '';
    }
  }

  /// Mapeia índice SQLite strftime('%w') para nome localizado completo do dia.
  String _weekdayName(AppLocalizations l10n, int index) {
    switch (index) {
      case 0:
        return l10n.weekdaySunday;
      case 1:
        return l10n.weekdayMonday;
      case 2:
        return l10n.weekdayTuesday;
      case 3:
        return l10n.weekdayWednesday;
      case 4:
        return l10n.weekdayThursday;
      case 5:
        return l10n.weekdayFriday;
      case 6:
        return l10n.weekdaySaturday;
      default:
        return '';
    }
  }

  /// Converte valor numérico de energia (1–3) para emojis de bateria.
  String _energyEmoji(int value) {
    switch (value) {
      case 1:
        return '🔋';
      case 2:
        return '🔋🔋';
      case 3:
        return '🔋🔋🔋';
      default:
        return '🔋🔋';
    }
  }
}
