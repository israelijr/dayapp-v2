import 'package:flutter/material.dart';
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
/// [gráfico de barras]  ← apenas InsightType.energyChart
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

  /// Chamado quando o usuário toca no CTA de upgrade para Premium.
  final VoidCallback? onPremiumCTA;

  const InsightCard({
    required this.insight,
    this.onSeeStories,
    this.onDismiss,
    this.onPremiumCTA,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPremiumUser = context.watch<PremiumProvider>().isPremium;
    final isLocked = insight.isPremium && !isPremiumUser;

    final title = _resolveTitle(l10n);
    final description = _resolveDescription(l10n);
    final searchQuery = _resolveSearchQuery();
    final showButton =
        !isLocked &&
        onSeeStories != null &&
        searchQuery != null &&
        searchQuery.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: AnimatedContainer(
        duration: AppDurations.short,
        child: Card(
          elevation: 0,
          color: colorScheme.secondaryContainer,
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
                // Cabeçalho: ícone + título + badge premium + botão dispensar
                Row(
                  children: [
                    Text(insight.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.bold,
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

                // Corpo: conteúdo bloqueado ou conteúdo normal
                if (isLocked)
                  _buildPremiumLock(context, l10n, theme, colorScheme)
                else ...[
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  // Gráfico de barras de energia (apenas para InsightType.energyChart)
                  if (insight.type == InsightType.energyChart) ...[
                    const SizedBox(height: 12),
                    _buildEnergyChart(l10n, colorScheme),
                  ],
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
                        child: Text(l10n.insightSeeStories),
                      ),
                    ),
                  ],
                ],
              ],
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
                () => Navigator.of(context).pushNamed('/settings'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              textStyle: theme.textTheme.labelMedium,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Gráfico de barras de energia
  // ---------------------------------------------------------------------------

  Widget _buildEnergyChart(AppLocalizations l10n, ColorScheme colorScheme) {
    final energyData =
        (insight.metadata?['energy_data'] as List<dynamic>?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        List.filled(7, 0);
    final weekdayIndices =
        (insight.metadata?['weekday_indices'] as List<dynamic>?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        List.generate(7, (i) => i);

    const maxBarHeight = 50.0;
    const barWidth = 24.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < energyData.length && i < weekdayIndices.length; i++)
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Barra proporcional à energia (1-3); 0 = sem dado
              Container(
                width: barWidth,
                height: energyData[i] == 0
                    ? 4
                    : maxBarHeight * (energyData[i] / 3),
                decoration: BoxDecoration(
                  color: _barColor(energyData[i], colorScheme),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              // Abreviação do dia da semana
              Text(
                _weekdayAbbr(l10n, weekdayIndices[i]),
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSecondaryContainer.withValues(
                    alpha: 0.65,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Color _barColor(int energy, ColorScheme colorScheme) {
    switch (energy) {
      case 1:
        return colorScheme.error.withValues(alpha: 0.75);
      case 2:
        return colorScheme.tertiary.withValues(alpha: 0.8);
      case 3:
        return colorScheme.primary.withValues(alpha: 0.85);
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
        return l10n.insightEnergyChartTitle;
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
        return l10n.insightEnergyChartSubtitle;
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
