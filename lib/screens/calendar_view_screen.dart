import 'package:dayapp/helpers/route_transition_helper.dart';
import 'package:dayapp/l10n/app_localizations.dart';
import 'package:dayapp/models/historia.dart';
import 'package:dayapp/providers/auth_provider.dart';
import 'package:dayapp/providers/calendar_stories_provider.dart';
import 'package:dayapp/providers/refresh_provider.dart';
import 'package:dayapp/repositories/historia_repository.dart';
import 'package:dayapp/theme/m3_expressive_theme.dart';
import 'package:dayapp/widgets/historia_media_widgets.dart';
import 'package:dayapp/widgets/rich_text_viewer_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'edit_historia_screen.dart';

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

  String _convertLegacyEmoticon(String emoticon) {
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
        return emoticon;
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

  void _showHistoriaDetails(Historia historia) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0x00000000),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    child: _buildDetailedHistoriaView(historia),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailedHistoriaView(Historia historia) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (historia.emoticon != null)
              Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.only(right: 16),
                alignment: Alignment.center,
                child: Text(
                  _convertLegacyEmoticon(historia.emoticon!),
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    historia.titulo,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.labelColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(historia.data),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (historia.descricao != null && historia.descricao!.isNotEmpty)
          RichTextViewerWidget(jsonContent: historia.descricao!),
        const SizedBox(height: 20),
        if (historia.fotoHistoria != null && historia.fotoHistoria!.isNotEmpty)
          HistoriaFotosGrid(historiaId: historia.id ?? 0, height: 220),
      ],
    );
  }

  Widget _buildHistoriaCard(Historia historia) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: () => _showHistoriaDetails(historia),
        onDoubleTap: () async {
          final result =
              await Navigator.push(
                    context,
                    RouteTransitionHelper.slideUpRotateTransition(
                      EditHistoriaScreen(historia: historia),
                    ),
                  )
                  as bool?;
          if (!mounted) return;
          if (result == true) {
            await context.read<CalendarStoriesProvider>().loadHistorias();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (historia.emoticon != null)
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 12),
                      alignment: Alignment.center,
                      child: Text(
                        _convertLegacyEmoticon(historia.emoticon!),
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          historia.titulo,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.labelColor(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('HH:mm').format(historia.data),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (historia.arquivado != null)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(Icons.archive_outlined, size: 16),
                    ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final result =
                            await Navigator.push(
                                  context,
                                  RouteTransitionHelper.slideUpRotateTransition(
                                    EditHistoriaScreen(historia: historia),
                                  ),
                                )
                                as bool?;
                        if (!mounted) return;
                        if (result == true) {
                          await context
                              .read<CalendarStoriesProvider>()
                              .loadHistorias();
                        }
                      } else if (value == 'delete') {
                        await _deleteHistoria(historia);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(l10n.deleteLabel),
                      ),
                    ],
                  ),
                ],
              ),
              if (historia.descricao != null &&
                  historia.descricao!.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: RichTextViewerWidget(jsonContent: historia.descricao),
                ),
              ],
              HistoriaFotosGrid(historiaId: historia.id ?? 0, height: 80),
            ],
          ),
        ),
      ),
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
