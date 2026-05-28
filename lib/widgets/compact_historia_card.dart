import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../db/tag_helper.dart';
import '../models/historia.dart';
import '../models/tag.dart';

class CompactHistoriaCard extends StatefulWidget {
  final Historia historia;
  final String localeName;
  final Widget? trailing;
  final bool overlayTrailing;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final EdgeInsetsGeometry margin;
  final bool showMood;

  const CompactHistoriaCard({
    required this.historia,
    required this.localeName,
    this.trailing,
    this.overlayTrailing = false,
    this.onTap,
    this.onDoubleTap,
    this.margin = const EdgeInsets.only(bottom: 12),
    this.showMood = true,
    super.key,
  });

  @override
  State<CompactHistoriaCard> createState() => _CompactHistoriaCardState();
}

class _CompactHistoriaCardState extends State<CompactHistoriaCard> {
  List<Tag> _tags = const [];

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  @override
  void didUpdateWidget(CompactHistoriaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recarrega tags apenas se a história mudou
    if (oldWidget.historia.id != widget.historia.id) {
      _loadTags();
    }
  }

  Future<void> _loadTags() async {
    final id = widget.historia.id;
    if (id == null) return;
    final result = await TagHelper().getTagsByHistoria(id);
    if (mounted) setState(() => _tags = result);
  }

  String? _convertLegacyEmoticon(String emoticon) {
    switch (emoticon) {
      case 'Feliz':
        return '😊';
      case 'Tranquilo':
        return '😌';
      case 'Aliviado':
        return '😮‍💨';
      case 'Pensativo':
        return '🤔';
      case 'Sono':
        return '😴';
      case 'Preocupado':
        return '😟';
      case 'Assustado':
        return '😨';
      case 'Bravo':
        return '😠';
      case 'Triste':
        return '😢';
      case 'Muito Triste':
        return '😭';
      default:
        return null;
    }
  }

  Widget _buildTags(BuildContext context, ColorScheme colorScheme) {
    final historia = widget.historia;
    final legacyTag = historia.tag;
    final tagNames = _tags.isNotEmpty
        ? _tags.map((t) => t.nome).toList(growable: false)
        : (legacyTag != null && legacyTag.isNotEmpty
              ? <String>[legacyTag]
              : const <String>[]);

    if (tagNames.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: tagNames
          .map(
            (name) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? colorScheme.primaryContainer
                    : colorScheme.primaryContainer.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.primary,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historia = widget.historia;
    final localeName = widget.localeName;
    final trailing = widget.trailing;
    final onTap = widget.onTap;
    final onDoubleTap = widget.onDoubleTap;
    final overlayTrailing = widget.overlayTrailing;
    final margin = widget.margin;
    final showMood = widget.showMood;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: margin,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: const Color(0x00000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withValues(alpha: 0.025),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (overlayTrailing && trailing != null)
                Positioned(top: 8, right: 8, child: trailing),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  14,
                  12,
                  overlayTrailing && trailing != null ? 52 : 14,
                  12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Builder(
                          builder: (context) {
                            if (historia.emoticon != null &&
                                historia.emoticon!.isNotEmpty) {
                              final converted = _convertLegacyEmoticon(
                                historia.emoticon!,
                              );
                              final display = converted ?? historia.emoticon!;
                              return Opacity(
                                opacity: 0.62,
                                child: Text(
                                  display,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    height: 1,
                                  ),
                                ),
                              );
                            }
                            return Icon(
                              Icons.auto_stories_outlined,
                              color: Theme.of(context).iconTheme.color,
                              size: 24,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            historia.titulo,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.notoSerif(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              color: Theme.of(
                                context,
                              ).textTheme.titleMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                DateFormat(
                                  'dd/MM/yyyy',
                                  localeName,
                                ).format(historia.data),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                              ),
                              if (showMood) ...[
                                const SizedBox(width: 8),
                                _MoodDot(mood: historia.humor),
                              ],
                            ],
                          ),
                          if (historia.id != null) ...[
                            const SizedBox(height: 6),
                            _buildTags(context, colorScheme),
                          ],
                        ],
                      ),
                    ),
                    if (!overlayTrailing && trailing != null) ...[
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 48),
                        child: trailing,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bolinha colorida indicando o humor da história (escala 1-5).
class _MoodDot extends StatelessWidget {
  final int mood;
  const _MoodDot({required this.mood});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fraction = ((mood - 1) / 4).clamp(0.0, 1.0);

    final Color color;
    if (fraction < 0.33) {
      color = colorScheme.error;
    } else if (fraction < 0.66) {
      color = colorScheme.tertiary;
    } else {
      color = colorScheme.primary;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
