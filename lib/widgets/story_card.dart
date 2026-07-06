import 'package:dayapp/db/historia_foto_helper.dart';
import 'package:dayapp/db/pessoa_helper.dart';
import 'package:dayapp/db/tag_helper.dart';
import 'package:dayapp/l10n/app_localizations.dart';
import 'package:dayapp/models/historia.dart';
import 'package:dayapp/models/pessoa.dart';
import 'package:dayapp/models/tag.dart';
import 'package:dayapp/providers/premium_provider.dart';
import 'package:dayapp/sharing/service/story_share_service.dart';
import 'package:dayapp/widgets/historia_media_widgets.dart';
import 'package:dayapp/widgets/rich_text_viewer_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Ações possíveis retornadas pelo preview de história.
enum StoryPreviewAction {
  close,
  edit,
  delete,
  group,
  archive,
  ungroup,
  unarchive,
}

enum _StoryPreviewMenuAction {
  share,
  group,
  switchGroup,
  ungroup,
  archive,
  unarchive,
}

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

  Widget _buildLocationAndPeople(BuildContext context) {
    final location = historia.local?.trim();
    final hasLocation = location != null && location.isNotEmpty;

    return FutureBuilder<List<Pessoa>>(
      future: PessoaHelper().getPessoasByHistoria(historia.id ?? 0),
      builder: (context, snapshot) {
        final people = snapshot.data ?? const <Pessoa>[];
        final hasPeople = people.isNotEmpty;
        if (!hasLocation && !hasPeople) {
          return const SizedBox.shrink();
        }

        final color = Theme.of(
          context,
        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.72);
        final peopleText = people.map((p) => p.nome).join(', ');

        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              if (hasLocation) ...[
                Icon(Icons.place_outlined, size: 13, color: color),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                      color: color,
                    ),
                  ),
                ),
              ],
              if (hasLocation && hasPeople) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.circle,
                  size: 4,
                  color: color.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
              ],
              if (hasPeople) ...[
                Icon(Icons.people_alt_outlined, size: 13, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    peopleText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                      color: color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

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
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
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
                                      DateFormat.yMd(Localizations.localeOf(context).toString()).add_Hm().format(historia.data),
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
                        _buildLocationAndPeople(context),
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

  bool get _hasGroup => (historia.grupo?.trim().isNotEmpty ?? false);
  bool get _isArchived => historia.arquivado != null;

  PopupMenuItem<_StoryPreviewMenuAction> _menuItem({
    required _StoryPreviewMenuAction value,
    required IconData icon,
    required String label,
    required bool enabled,
  }) {
    return PopupMenuItem<_StoryPreviewMenuAction>(
      value: value,
      enabled: enabled,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }

  List<PopupMenuItem<_StoryPreviewMenuAction>> _buildMenuItems(
    AppLocalizations l10n,
  ) {
    const actions = <_StoryPreviewMenuAction>[
      _StoryPreviewMenuAction.share,
      _StoryPreviewMenuAction.group,
      _StoryPreviewMenuAction.switchGroup,
      _StoryPreviewMenuAction.ungroup,
      _StoryPreviewMenuAction.archive,
      _StoryPreviewMenuAction.unarchive,
    ];
    return actions
        .map((action) {
          switch (action) {
            case _StoryPreviewMenuAction.share:
              return _menuItem(
                value: action,
                icon: Icons.share,
                label: l10n.share,
                enabled: true,
              );
            case _StoryPreviewMenuAction.group:
              return _menuItem(
                value: action,
                icon: Icons.group,
                label: 'Agrupar',
                enabled: !_hasGroup,
              );
            case _StoryPreviewMenuAction.switchGroup:
              return _menuItem(
                value: action,
                icon: Icons.swap_horiz,
                label: 'Trocar Grupo',
                enabled: _hasGroup,
              );
            case _StoryPreviewMenuAction.archive:
              return _menuItem(
                value: action,
                icon: Icons.archive,
                label: l10n.archiveLabel,
                enabled: !_isArchived,
              );
            case _StoryPreviewMenuAction.ungroup:
              return _menuItem(
                value: action,
                icon: Icons.group_off,
                label: l10n.ungroup,
                enabled: _hasGroup,
              );
            case _StoryPreviewMenuAction.unarchive:
              return _menuItem(
                value: action,
                icon: Icons.unarchive,
                label: l10n.unarchive,
                enabled: _isArchived,
              );
          }
        })
        .toList(growable: false);
  }

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

  String _continuaNarrative(AppLocalizations l10n) {
    final cont = historia.continua;
    if (cont == 1) return '${l10n.continuaLabel}: ${l10n.continuaNo}';
    if (cont == 2) return '${l10n.continuaLabel}: ${l10n.continuaDontKnow}';
    if (cont == 3) return '${l10n.continuaLabel}: ${l10n.continuaMaybe}';
    return '${l10n.continuaLabel}: ${l10n.continuaYes}';
  }

  Widget _buildPreviewLocationAndPeople(ColorScheme colorScheme) {
    final location = historia.local?.trim();
    final hasLocation = location != null && location.isNotEmpty;

    return FutureBuilder<List<Pessoa>>(
      future: PessoaHelper().getPessoasByHistoria(historia.id ?? 0),
      builder: (context, snapshot) {
        final people = snapshot.data ?? const <Pessoa>[];
        final hasPeople = people.isNotEmpty;
        if (!hasLocation && !hasPeople) {
          return const SizedBox.shrink();
        }

        final color = colorScheme.onSurfaceVariant.withValues(alpha: 0.78);
        final peopleText = people.map((p) => p.nome).join(', ');

        return Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Row(
            children: [
              if (hasLocation) ...[
                Icon(Icons.place_outlined, size: 14, color: color),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
              ],
              if (hasLocation && hasPeople) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.circle,
                  size: 4,
                  color: color.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
              ],
              if (hasPeople) ...[
                Icon(Icons.people_alt_outlined, size: 14, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    peopleText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareStory(BuildContext context) async {
    final premium = context.read<PremiumProvider>();
    if (!premium.canShareStory) {
      final l10n = AppLocalizations.of(context)!;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.premiumFeature),
          content: Text(l10n.premiumFeatureInfo),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.close),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushNamed('/premium');
              },
              child: Text(l10n.insightPremiumCTA),
            ),
          ],
        ),
      );
      return;
    }
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
          PopupMenuButton<_StoryPreviewMenuAction>(
            icon: const Icon(Icons.settings),
            onSelected: (_StoryPreviewMenuAction value) {
              switch (value) {
                case _StoryPreviewMenuAction.share:
                  _shareStory(context);
                  return;
                case _StoryPreviewMenuAction.group:
                case _StoryPreviewMenuAction.switchGroup:
                  Navigator.of(context).pop(StoryPreviewAction.group);
                  return;
                case _StoryPreviewMenuAction.ungroup:
                  Navigator.of(context).pop(StoryPreviewAction.ungroup);
                  return;
                case _StoryPreviewMenuAction.archive:
                  Navigator.of(context).pop(StoryPreviewAction.archive);
                  return;
                case _StoryPreviewMenuAction.unarchive:
                  Navigator.of(context).pop(StoryPreviewAction.unarchive);
                  return;
              }
            },
            itemBuilder: (menuContext) => _buildMenuItems(l10n),
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
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
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
                            child: Builder(
                              builder: (context) {
                                final List<String> parts = [];
                                if (historia.grupo != null && historia.grupo!.trim().isNotEmpty) {
                                  parts.add(historia.grupo!.trim());
                                }
                                if (_isArchived) {
                                  parts.add(l10n.archivedStoryPrefixLabel);
                                }
                                final prefix = parts.isNotEmpty ? '${parts.join(' • ')} • ' : '';
                                return Text(
                                  '$prefix${DateFormat.yMd(localeName).add_Hm().format(historia.data)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                );
                              },
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
                              const SizedBox(height: 4),
                              Text(
                                _continuaNarrative(l10n),
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
                      _buildPreviewLocationAndPeople(colorScheme),
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
