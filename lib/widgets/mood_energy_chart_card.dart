import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:dayapp/models/historia.dart';
import 'package:dayapp/widgets/mood_energy_selectors.dart'; // Contém a função moodEmoji
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MoodEnergyChartCard extends StatelessWidget {
  final List<Historia> stories;

  const MoodEnergyChartCard({required this.stories, super.key});

  @override
  Widget build(BuildContext context) {
    if (stories.length < 2) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final localeName = loc.localeName;

    // Normalização da energia (1-3) para a escala de humor (1-5)
    // 1 (Baixa) -> 1.0
    // 2 (Normal) -> 3.0
    // 3 (Alta) -> 5.0
    double normalizeEnergy(int value) {
      switch (value) {
        case 1:
          return 1.0;
        case 2:
          return 3.0;
        case 3:
          return 5.0;
        default:
          return 3.0;
      }
    }

    // Geração dos spots do gráfico
    final moodSpots = <FlSpot>[];
    final energySpots = <FlSpot>[];

    for (int i = 0; i < stories.length; i++) {
      final s = stories[i];
      moodSpots.add(FlSpot(i.toDouble(), s.humor.toDouble().clamp(1.0, 5.0)));
      energySpots.add(FlSpot(i.toDouble(), normalizeEnergy(s.energia)));
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
          // Cabeçalho do Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.moodEnergyChartTitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    loc.moodEnergyChartSubtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
              // Legenda do Gráfico
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        loc.moodLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 3,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        loc.energyLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Gráfico
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 0.5,
                maxY: 5.5,
                minX: -0.4,
                maxX: (stories.length - 1) + 0.4,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) =>
                        theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.95),
                    tooltipBorder: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      width: 1,
                    ),
                    getTooltipItems: (touchedSpots) {
                      if (touchedSpots.isEmpty) return [];

                      final index = touchedSpots.first.x.toInt();
                      if (index < 0 || index >= stories.length) return [];

                      final s = stories[index];
                      // Formata data do dia
                      final dateStr = DateFormat.E(localeName).format(s.data);
                      final dayStr = DateFormat.d(localeName).format(s.data);
                      final capitalizedDate = dateStr[0].toUpperCase() + dateStr.substring(1);
                      final fullDate = '$capitalizedDate, $dayStr';

                      final moodEmojiStr = moodEmoji(s.humor);
                      String energyStr = '';
                      if (s.energia == 1) {
                        energyStr = loc.energyLow;
                      } else if (s.energia == 2) {
                        energyStr = loc.energyNormal;
                      } else if (s.energia == 3) {
                        energyStr = loc.energyHigh;
                      }

                      // Agrupamos as informações em um tooltip consolidado ancorado no Humor (barIndex == 1)
                      return touchedSpots.map((spot) {
                        if (spot.barIndex == 1) {
                          return LineTooltipItem(
                            '$fullDate\n'
                            '${loc.moodLabel}: $moodEmojiStr\n'
                            '${loc.energyLabel}: $energyStr',
                            GoogleFonts.plusJakartaSans(
                              color: theme.colorScheme.onSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }
                        return null;
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 1.0,
                      getTitlesWidget: (value, meta) {
                        final valInt = value.round();
                        if (value - valInt != 0.0) return const SizedBox.shrink();
                        if (valInt < 1 || valInt > 5) return const SizedBox.shrink();
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            moodEmoji(valInt),
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      interval: 1.0,
                      getTitlesWidget: (value, meta) {
                        final valInt = value.round();
                        if (value - valInt != 0.0) return const SizedBox.shrink();
                        String label = '';
                        if (valInt == 1) {
                          label = loc.energyLow;
                        } else if (valInt == 3) {
                          label = loc.energyNormal;
                        } else if (valInt == 5) {
                          label = loc.energyHigh;
                        } else {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              label,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1.0,
                      getTitlesWidget: (value, meta) {
                        final index = value.round();
                        // Evita duplicações causadas por pontos intermediários arredondados
                        if (value - index != 0.0) return const SizedBox.shrink();
                        if (index < 0 || index >= stories.length) {
                          return const SizedBox.shrink();
                        }
                        final s = stories[index];
                        final rawDay = DateFormat.E(localeName).format(s.data);
                        final formattedDay = rawDay[0].toUpperCase() + rawDay.substring(1, rawDay.length > 3 ? 3 : rawDay.length);
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            formattedDay,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  verticalLines: [
                    VerticalLine(
                      x: (stories.length - 1).toDouble(),
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      strokeWidth: 1.5,
                      dashArray: [4, 4],
                      label: VerticalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        labelResolver: (line) => loc.today.toUpperCase(),
                      ),
                    ),
                  ],
                ),
                lineBarsData: [
                  // Linha 1: Energia (Renderiza primeiro, no fundo)
                  LineChartBarData(
                    spots: energySpots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: theme.colorScheme.tertiary,
                    barWidth: 2,
                    dashArray: [6, 4],
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.tertiary.withValues(alpha: 0.12),
                          theme.colorScheme.tertiary.withValues(alpha: 0.01),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Linha 2: Humor (Renderiza por cima)
                  LineChartBarData(
                    spots: moodSpots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: theme.colorScheme.primary,
                    barWidth: 2, // Afinada para 2
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        final isToday = index == stories.length - 1;
                        if (isToday) {
                          // Destaque para o ponto de hoje
                          return FlDotCirclePainter(
                            radius: 5,
                            color: theme.colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: theme.colorScheme.surface,
                          );
                        }
                        // Ponto padrão simples
                        return FlDotCirclePainter(
                          radius: 3,
                          color: theme.colorScheme.primary,
                          strokeWidth: 1.5,
                          strokeColor: theme.colorScheme.surface,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
