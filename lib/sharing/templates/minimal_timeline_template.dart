import 'package:dayapp/sharing/story_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// MinimalTimeline template:
///
/// - Modelo de linha do tempo minimalista.
/// - Está disponível como artefato, mas não é selecionado pelo mecanismo atual.
class MinimalTimelineTemplate extends StatelessWidget {
  final StoryData story;

  const MinimalTimelineTemplate({required this.story, super.key});

  @override
  Widget build(BuildContext context) {
    final primary = story.images.isNotEmpty ? story.images.first : null;
    final colorScheme = Theme.of(context).colorScheme;
    final dateLabel = DateFormat.yMMMMd(story.localeName).format(story.date);

    return Container(
      color: colorScheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 80), // Área de segurança para botões
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              color: colorScheme.surfaceContainerHighest,
              child: primary != null
                  ? Image.memory(primary, fit: BoxFit.cover)
                  : Container(color: colorScheme.surfaceContainerHighest),
            ),
          ),
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 30, 40, 30),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.subtitle ?? dateLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        letterSpacing: 0.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      story.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 42,
                        color: colorScheme.onSurface,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      story.description ?? '',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        height: 1.7,
                        color: colorScheme.onSurface.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: story.tags
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                '#$tag',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'DayApp',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
