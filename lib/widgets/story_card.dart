import 'package:dayapp/db/historia_foto_helper.dart';
import 'package:dayapp/db/tag_helper.dart';
import 'package:dayapp/l10n/app_localizations.dart';
import 'package:dayapp/models/historia.dart';
import 'package:dayapp/models/tag.dart';
import 'package:dayapp/sharing/service/story_share_service.dart';
import 'package:dayapp/widgets/historia_media_widgets.dart';
import 'package:dayapp/widgets/rich_text_viewer_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Ações possíveis retornadas pelo preview de história.
enum StoryPreviewAction { close, edit, delete }

typedef LegacyEmoticonConverter = String? Function(String emoticon);

typedef StoryPreviewWidgetBuilder =
    Widget Function(BuildContext context, Historia historia);

/// Shared story card used by Home and Groups screens.
class StoryCard extends StatelessWidget {
  final Historia historia;
  final String? heroTag;
  final HeroFlightShuttleBuilder? flightShuttleBuilder;
  final LegacyEmoticonConverter convertLegacyEmoticon;
  final VoidCallback onPreview;
  final VoidCallback? onDoubleTap;
  final Widget? footer;
  final int descriptionMaxLength;
  final TextStyle? descriptionTextStyle;
  final String? stateLabel;

  const StoryCard({
    required this.historia,
    required this.convertLegacyEmoticon,
    required this.onPreview,
    this.heroTag,
    this.flightShuttleBuilder,
    this.onDoubleTap,
    this.footer,
    this.descriptionMaxLength = 155,
    this.descriptionTextStyle,
    this.stateLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = FutureBuilder<List<FotoComBytes>>(
      future: HistoriaFotoHelper().getFotosComBytesByHistoria(historia.id ?? 0),
      builder: (context, snapshot) {
        final hasImages = snapshot.hasData && snapshot.data!.isNotEmpty;
        return GestureDetector(
          onDoubleTap: onDoubleTap,
          child: Card(
            margin: const EdgeInsets.only(bottom: 24),
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            color: const Color(0x00000000),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: SizedBox(
                      width: 34,
                      height: 34,
                      child: FloatingActionButton.small(
                        heroTag: null,
                        elevation: 1,
                        tooltip:
                            AppLocalizations.of(context)?.preview ?? 'Preview',
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLow,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant,
                        onPressed: onPreview,
                        child: const Icon(Icons.open_in_full_rounded, size: 16),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 52, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasImages) ...[
                          HistoriaFotosGrid(
                            historiaId: historia.id ?? 0,
                            height: 100,
                          ),
                          const SizedBox(height: 12),
                        ],
                        HistoriaMediaRow(
                          historiaId: historia.id ?? 0,
                          emoticon: historia.emoticon,
                          convertLegacyEmoticon: convertLegacyEmoticon,
                        ),
                        const SizedBox(height: 12),
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
                            ).textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 80,
                          child: RichTextViewerCompactWidget(
                            jsonContent: historia.descricao,
                            maxLength: descriptionMaxLength,
                            textStyle:
                                descriptionTextStyle ??
                                GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withValues(alpha: 0.82),
                                ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (historia.emoticon != null &&
                                      historia.emoticon!.isNotEmpty)
                                    Builder(
                                      builder: (context) {
                                        final convertedEmoji =
                                            convertLegacyEmoticon(
                                              historia.emoticon!,
                                            );
                                        final displayEmoji =
                                            convertedEmoji ??
                                            historia.emoticon!;
                                        return Opacity(
                                          opacity: 0.62,
                                          child: Text(
                                            displayEmoji,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              height: 1,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  if (historia.emoticon != null &&
                                      historia.emoticon!.isNotEmpty)
                                    const SizedBox(width: 6),
                                  if (stateLabel != null &&
                                      stateLabel!.isNotEmpty) ...[
                                    Flexible(
                                      child: Text(
                                        stateLabel!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.3,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant
                                              .withValues(alpha: 0.72),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Expanded(
                                    child: Text(
                                      DateFormat(
                                        'dd/MM/yyyy HH:mm',
                                        'pt_BR',
                                      ).format(historia.data),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.3,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant
                                            .withValues(alpha: 0.72),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<List<Tag>>(
                          future: TagHelper().getTagsByHistoria(
                            historia.id ?? 0,
                          ),
                          builder: (context, tagSnapshot) {
                            final newTags = tagSnapshot.data ?? [];
                            final legacyTag = historia.tag;
                            final tagNames = newTags.isNotEmpty
                                ? newTags.map((t) => t.nome).toList()
                                : (legacyTag != null && legacyTag.isNotEmpty
                                      ? [legacyTag]
                                      : <String>[]);
                            if (tagNames.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: tagNames
                                      .map(
                                        (name) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primaryContainer
                                                : Theme.of(context)
                                                      .colorScheme
                                                      .primaryContainer
                                                      .withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            name,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.3,
                                              color:
                                                  Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                  ? Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryContainer
                                                  : Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            );
                          },
                        ),
                        if (footer != null) ...[
                          const SizedBox(height: 12),
                          footer!,
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (heroTag == null) {
      return cardContent;
    }

    return Hero(
      tag: heroTag!,
      createRectTween: (begin, end) =>
          MaterialRectArcTween(begin: begin, end: end),
      flightShuttleBuilder: flightShuttleBuilder,
      placeholderBuilder: (context, size, child) =>
          SizedBox(width: size.width, height: size.height),
      child: cardContent,
    );
  }
}

/// Shared story preview screen used in both Home and Groups.
class StoryPreviewScreen extends StatelessWidget {
  final Historia historia;
  final String localeName;
  final LegacyEmoticonConverter convertLegacyEmoticon;
  final String heroTag;
  final bool showEditDelete;
  final bool showMoodNotes;
  final bool showBottomActions;
  final HeroFlightShuttleBuilder? flightShuttleBuilder;

  const StoryPreviewScreen({
    required this.historia,
    required this.localeName,
    required this.convertLegacyEmoticon,
    required this.heroTag,
    this.flightShuttleBuilder,
    this.showEditDelete = true,
    this.showMoodNotes = true,
    this.showBottomActions = true,
    super.key,
  });

  String _moodNarrative(AppLocalizations l10n) {
    final mood = historia.humor;
    if (mood <= 1) return l10n.storyPreviewMoodVeryDifficultNarrative;
    if (mood == 2) return l10n.storyPreviewMoodDifficultNarrative;
    if (mood == 3) return l10n.storyPreviewMoodNeutralNarrative;
    if (mood == 4) return l10n.storyPreviewMoodGoodNarrative;
    return l10n.storyPreviewMoodVeryGoodNarrative;
  }

  String _energyNarrative(AppLocalizations l10n) {
    final energy = historia.energia;
    if (energy <= 1) return l10n.storyPreviewEnergyLowNarrative;
    if (energy == 2) return l10n.storyPreviewEnergyNormalNarrative;
    return l10n.storyPreviewEnergyHighNarrative;
  }

  Future<void> _shareStory(BuildContext context) async {
    await StoryShareService.shareHistoria(context, historia, localeName);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: l10n.share,
            icon: const Icon(Icons.share),
            onPressed: () => _shareStory(context),
          ),
          IconButton(
            tooltip: l10n.close,
            icon: const Icon(Icons.close),
            onPressed: () =>
                Navigator.of(context).pop(StoryPreviewAction.close),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Hero(
            tag: heroTag,
            createRectTween: (begin, end) =>
                MaterialRectArcTween(begin: begin, end: end),
            flightShuttleBuilder: flightShuttleBuilder,
            placeholderBuilder: (context, size, child) =>
                SizedBox(width: size.width, height: size.height),
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.onSurface.withValues(alpha: 0.10),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.onSurface.withValues(alpha: 0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HistoriaFotosGrid(
                        historiaId: historia.id ?? 0,
                        height: 180,
                      ),
                      const SizedBox(height: 12),
                      HistoriaMediaRow(
                        historiaId: historia.id ?? 0,
                        emoticon: historia.emoticon,
                        convertLegacyEmoticon: convertLegacyEmoticon,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        historia.titulo,
                        style: GoogleFonts.notoSerif(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (historia.emoticon != null &&
                              historia.emoticon!.isNotEmpty)
                            Opacity(
                              opacity: 0.62,
                              child: Text(
                                convertLegacyEmoticon(historia.emoticon!) ??
                                    historia.emoticon!,
                                style: const TextStyle(fontSize: 18, height: 1),
                              ),
                            ),
                          if (historia.emoticon != null &&
                              historia.emoticon!.isNotEmpty)
                            const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              DateFormat(
                                'dd/MM/yyyy HH:mm',
                                localeName,
                              ).format(historia.data),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      RichTextViewerWidget(jsonContent: historia.descricao),
                      if (showMoodNotes) ...[
                        const SizedBox(height: 14),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: colorScheme.onSurface.withValues(alpha: 0.08),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.10,
                                ),
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _moodNarrative(l10n),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.78),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _energyNarrative(l10n),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.78),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: showBottomActions
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).pop(StoryPreviewAction.close),
                      child: Text(l10n.close),
                    ),
                  ),
                  if (showEditDelete) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () =>
                            Navigator.of(context).pop(StoryPreviewAction.edit),
                        child: Text(l10n.edit),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          foregroundColor: colorScheme.onError,
                        ),
                        onPressed: () => Navigator.of(
                          context,
                        ).pop(StoryPreviewAction.delete),
                        child: Text(l10n.deleteLabel),
                      ),
                    ),
                  ],
                ],
              ),
            )
          : null,
    );
  }
}
