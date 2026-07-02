import 'package:dayapp/db/historia_foto_helper.dart';
import 'package:dayapp/helpers/route_transition_helper.dart';
import 'package:dayapp/l10n/app_localizations.dart';
import 'package:dayapp/models/historia.dart';
import 'package:dayapp/providers/auth_provider.dart';
import 'package:dayapp/providers/calendar_stories_provider.dart';
import 'package:dayapp/providers/refresh_provider.dart';
import 'package:dayapp/repositories/historia_repository.dart';
import 'package:dayapp/services/thumbnail_service.dart';
import 'package:dayapp/theme/m3_expressive_theme.dart';
import 'package:dayapp/widgets/story_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'edit_historia_screen.dart';
import 'group_selection_screen.dart';

class CalendarViewScreen extends StatelessWidget {
  const CalendarViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CalendarStoriesProvider>(
      create: (context) => CalendarStoriesProvider(
        repository: HistoriaRepository(),
        authProvider: context.read<AuthProvider>(),
      )..loadHistorias(),
      child: const _CalendarViewContent(),
    );
  }
}

class _CalendarViewContent extends StatefulWidget {
  const _CalendarViewContent();

  @override
  State<_CalendarViewContent> createState() => _CalendarViewContentState();
}

class _CalendarViewContentState extends State<_CalendarViewContent> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RefreshProvider? _refreshProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshProvider = Provider.of<RefreshProvider>(context, listen: false);
      _refreshProvider?.addListener(_onRefresh);
    });
  }

  void _onRefresh() {
    if (!mounted) return;
    context.read<CalendarStoriesProvider>().loadHistorias();
  }

  @override
  void dispose() {
    _refreshProvider?.removeListener(_onRefresh);
    super.dispose();
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

  Future<void> _deleteHistoria(Historia historia) async {
    final localizations = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final storiesProvider = context.read<CalendarStoriesProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.deleteStoryTitle),
          content: Text(localizations.deleteStoryConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                localizations.deleteLabel,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await storiesProvider.deleteHistoria(historia);
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(content: Text(localizations.movedToTrash)),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(localizations.errorDeletingStory(e.toString()))),
      );
    }
  }

  Future<void> _archiveWithUndo(Historia historia) async {
    final previousGrupo = historia.grupo;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    await HistoriaRepository().archiveHistoria(historia);

    if (!mounted) return;

    await context.read<CalendarStoriesProvider>().loadHistorias();

    messenger.hideCurrentSnackBar();
    final controller = messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        content: Text(l10n.storyArchived),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () async {
            await HistoriaRepository().updateHistoria(
              historia,
              updates: {'arquivado': null, 'grupo': previousGrupo},
            );
            if (!mounted) return;
            await context.read<CalendarStoriesProvider>().loadHistorias();
          },
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 5), controller.close);
  }

  Future<void> _groupStory(Historia historia) async {
    final selectedGroup = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const GroupSelectionScreen()),
    );

    if (selectedGroup == null) {
      return;
    }

    await HistoriaRepository().updateHistoria(
      historia,
      updates: {'grupo': selectedGroup},
    );

    if (!mounted) return;
    await context.read<CalendarStoriesProvider>().loadHistorias();
  }

  Future<void> _ungroupStory(Historia historia) async {
    await HistoriaRepository().updateHistoria(
      historia,
      updates: {'grupo': null},
    );
    if (!mounted) return;
    await context.read<CalendarStoriesProvider>().loadHistorias();
  }

  Future<void> _unarchiveStory(Historia historia) async {
    await HistoriaRepository().updateHistoria(
      historia,
      updates: {'arquivado': null},
    );
    if (!mounted) return;
    await context.read<CalendarStoriesProvider>().loadHistorias();
  }

  Future<void> _openStoryPreview(Historia historia) async {
    try {
      await _warmupStoryPreviewMedia(
        historia,
      ).timeout(const Duration(milliseconds: 180));
    } catch (_) {
      // Ignora timeout/falha de prewarm para não bloquear a navegação.
    }

    if (!mounted) return;

    final heroTag = _storyHeroTag(historia);
    final navigator = Navigator.of(context);
    final action = await navigator.push<StoryPreviewAction>(
      MaterialPageRoute(
        builder: (_) => StoryPreviewScreen(
          historia: historia,
          localeName: AppLocalizations.of(context)!.localeName,
          convertLegacyEmoticon: _convertLegacyEmoticon,
          heroTag: heroTag,
          flightShuttleBuilder: _storyHeroFlightShuttleBuilder(historia),
          showEditDelete: true,
          showMoodNotes: true,
          showBottomActions: true,
        ),
      ),
    );

    if (!mounted || action == null || action == StoryPreviewAction.close) {
      return;
    }

    if (action == StoryPreviewAction.edit) {
      final navigator = Navigator.of(context);
      final updated = await navigator.push(
        RouteTransitionHelper.slideUpRotateTransition(
          EditHistoriaScreen(historia: historia),
        ),
      );
      if (!mounted) return;
      if (updated == true) {
        await context.read<CalendarStoriesProvider>().loadHistorias();
      }
      return;
    }

    if (action == StoryPreviewAction.delete) {
      await _deleteHistoria(historia);
      return;
    }

    if (action == StoryPreviewAction.group) {
      await _groupStory(historia);
      return;
    }

    if (action == StoryPreviewAction.ungroup) {
      await _ungroupStory(historia);
      return;
    }

    if (action == StoryPreviewAction.archive) {
      await _archiveWithUndo(historia);
      return;
    }

    if (action == StoryPreviewAction.unarchive) {
      await _unarchiveStory(historia);
    }
  }

  Future<void> _warmupStoryPreviewMedia(Historia historia) async {
    final historiaId = historia.id;
    if (historiaId == null || historiaId <= 0) return;

    try {
      final fotos = await HistoriaFotoHelper().getFotosComBytesByHistoria(
        historiaId,
      );
      if (fotos.isEmpty) return;

      final thumbnailsInput = fotos
          .map((foto) => MapEntry('foto_${foto.id}', foto.bytes))
          .toList(growable: false);

      await ThumbnailService().preloadThumbnails(thumbnailsInput);
    } catch (e) {
      debugPrint(
        'CalendarViewScreen: falha no prewarm de mídia da preview: $e',
      );
    }
  }

  String _storyHeroTag(Historia historia) {
    final id =
        historia.id?.toString() ??
        '${historia.titulo}_${historia.data.millisecondsSinceEpoch}';
    return 'calendar_story_card_$id';
  }

  Widget _buildHistoriaCard(Historia historia) {
    return StoryCard(
      historia: historia,
      heroTag: _storyHeroTag(historia),
      flightShuttleBuilder: _storyHeroFlightShuttleBuilder(historia),
      convertLegacyEmoticon: _convertLegacyEmoticon,
      stateLabel: historia.grupo?.isNotEmpty == true
          ? historia.grupo
          : historia.arquivado != null
          ? AppLocalizations.of(context)!.archivedStateLabel
          : null,
      onPreview: () => _openStoryPreview(historia),
      onDoubleTap: () => _openStoryPreview(historia),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<CalendarStoriesProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.calendarTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(8),
                  elevation: 2,
                  child: TableCalendar<Historia>(
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: provider.focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) =>
                        isSameDay(provider.selectedDay, day),
                    eventLoader: provider.getHistoriasForDay,
                    locale: Localizations.localeOf(context).toString(),
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    availableCalendarFormats: {
                      CalendarFormat.month: l10n.calendarFormatMonth,
                      CalendarFormat.twoWeeks: l10n.calendarFormatTwoWeeks,
                      CalendarFormat.week: l10n.calendarFormatWeek,
                    },
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      todayDecoration: BoxDecoration(
                        color: AppColors.purple700.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: AppColors.purple700,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: AppColors.purple300,
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 3,
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonShowsNext: false,
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!isSameDay(provider.selectedDay, selectedDay)) {
                        provider.setSelectedDay(selectedDay);
                      }
                      provider.setFocusedDay(focusedDay);
                    },
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      provider.setFocusedDay(focusedDay);
                    },
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: provider.selectedDayHistorias.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 64,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noRecordsThisDay,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: provider.selectedDayHistorias.length,
                          itemBuilder: (context, index) {
                            final historia =
                                provider.selectedDayHistorias[index];
                            return _buildHistoriaCard(historia);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

HeroFlightShuttleBuilder _storyHeroFlightShuttleBuilder(Historia historia) {
  return (
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final colorScheme = Theme.of(toHeroContext).colorScheme;
    final dateText = DateFormat(
      'dd/MM/yyyy HH:mm',
      'pt_BR',
    ).format(historia.data);
    final easedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return AnimatedBuilder(
      animation: easedAnimation,
      builder: (context, child) {
        final rawProgress = easedAnimation.value;
        final progress = flightDirection == HeroFlightDirection.push
            ? rawProgress
            : 1 - rawProgress;
        final compactOpacity = (1 - ((progress - 0.12) / 0.42)).clamp(0.0, 1.0);
        final expandedOpacity = ((progress - 0.32) / 0.48).clamp(0.0, 1.0);

        return Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Opacity(
                        opacity: compactOpacity,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.open_in_full_rounded,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.55),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    historia.titulo,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: expandedOpacity,
                        child: Center(
                          child: Text(
                            dateText,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  };
}
