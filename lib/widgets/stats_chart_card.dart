import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../providers/stats_provider.dart';

class StatsChartCard extends StatefulWidget {
  const StatsChartCard({super.key});

  @override
  State<StatsChartCard> createState() => _StatsChartCardState();
}

class _StatsChartCardState extends State<StatsChartCard> {
  bool _showWeeklyCount = false;

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>();
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    if (stats.totalStories < 7) {
      return const SizedBox.shrink();
    }

    if (stats.isLoading) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        height: 180,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final totalStories = stats.totalStories;
    final totalChapters = stats.totalChapters;
    final totalGroups = stats.totalGroups;
    final hasData = totalStories > 0 || totalChapters > 0 || totalGroups > 0;

    List<PieChartSectionData> getSections() {
      if (!hasData) {
        return [
          PieChartSectionData(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
            value: 1,
            title: '',
            radius: 16,
            showTitle: false,
          ),
        ];
      }

      final sections = <PieChartSectionData>[];

      if (totalStories > 0) {
        sections.add(
          PieChartSectionData(
            color: theme.colorScheme.primary,
            value: totalStories.toDouble(),
            title: '',
            radius: 16,
            showTitle: false,
          ),
        );
      }

      if (totalChapters > 0) {
        sections.add(
          PieChartSectionData(
            color: theme.colorScheme.secondary,
            value: totalChapters.toDouble(),
            title: '',
            radius: 16,
            showTitle: false,
          ),
        );
      }

      if (totalGroups > 0) {
        sections.add(
          PieChartSectionData(
            color: theme.colorScheme.tertiary,
            value: totalGroups.toDouble(),
            title: '',
            radius: 16,
            showTitle: false,
          ),
        );
      }

      return sections;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título do Card (não use fonte pesada, bold)
          Text(
            loc.howMuchWeHaveDoneTogether,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w500, // Fonte não pesada/bold
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),

          // Gráfico + Legendas
          Row(
            children: [
              // Gráfico Circular de Rosquinha
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showWeeklyCount = !_showWeeklyCount;
                  });
                },
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 32,
                          sections: getSections(),
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              if (event is FlTapUpEvent) {
                                setState(() {
                                  _showWeeklyCount = !_showWeeklyCount;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      // Ícone central ou emoji fofo
                      Icon(
                        Icons.favorite_rounded,
                        color: hasData
                            ? theme.colorScheme.primary.withValues(alpha: 0.6)
                            : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Indicadores Estatísticos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatIndicator(
                      label: loc.storiesLabel,
                      count: totalStories,
                      color: theme.colorScheme.primary,
                      theme: theme,
                    ),
                    const SizedBox(height: 10),
                    _buildStatIndicator(
                      label: loc.chaptersLabel,
                      count: totalChapters,
                      color: theme.colorScheme.secondary,
                      theme: theme,
                    ),
                    const SizedBox(height: 10),
                    _buildStatIndicator(
                      label: loc.groupsLabel,
                      count: totalGroups,
                      color: theme.colorScheme.tertiary,
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Interatividade: clique revela estatísticas semanais
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _showWeeklyCount
                ? InkWell(
                    onTap: () {
                      setState(() {
                        _showWeeklyCount = false;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Text(
                        loc.storiesThisWeek(stats.storiesThisWeek),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatIndicator({
    required String label,
    required int count,
    required Color color,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          '$count',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
