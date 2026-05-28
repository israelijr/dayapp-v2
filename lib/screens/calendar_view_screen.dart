import 'package:dayapp/helpers/route_transition_helper.dart';
import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../db/database_helper.dart';
import '../models/historia.dart';
import '../providers/auth_provider.dart';
import '../providers/refresh_provider.dart';
import '../theme/m3_expressive_theme.dart';
import '../widgets/historia_media_widgets.dart';
import '../widgets/rich_text_viewer_widget.dart';
import 'edit_historia_screen.dart';

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  late final ValueNotifier<List<Historia>> _selectedHistorias;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Historia>> _historiasMap = {};
  bool _isLoading = true;
  RefreshProvider? _refreshProvider; // Salvar referência

  // Converte nomes de humor antigos para emojis Unicode
  // Retorna o próprio valor se já for um emoji
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
        return emoticon; // Já é um emoji Unicode
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedHistorias = ValueNotifier([]);
    _loadHistorias();

    // Adicionar listener para atualizar quando houver mudanças
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshProvider = Provider.of<RefreshProvider>(context, listen: false);
      _refreshProvider?.addListener(_onRefresh);
    });
  }

  void _onRefresh() {
    if (mounted) {
      _loadHistorias();
    }
  }

  @override
  void dispose() {
    // Usar a referência salva em vez de acessar o context
    _refreshProvider?.removeListener(_onRefresh);
    _selectedHistorias.dispose();
    super.dispose();
  }

  Future<void> _loadHistorias() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;
      if (userId == null) return;

      final db = await DatabaseHelper().database;
      final result = await db.query(
        'historia',
        where: 'user_id = ? AND excluido IS NULL',
        whereArgs: [userId],
        orderBy: 'data DESC',
      );

      final historias = result.map((map) => Historia.fromMap(map)).toList();

      // Agrupar histórias por data (ignorando hora)
      final Map<DateTime, List<Historia>> map = {};
      for (var historia in historias) {
        final date = DateTime(
          historia.data.year,
          historia.data.month,
          historia.data.day,
        );
        if (!map.containsKey(date)) {
          map[date] = [];
        }
        map[date]!.add(historia);
      }

      setState(() {
        _historiasMap = map;
        _isLoading = false;
      });

      // Atualizar histórias do dia selecionado
      _updateSelectedHistorias(_selectedDay!);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _updateSelectedHistorias(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    _selectedHistorias.value = _historiasMap[date] ?? [];
  }

  List<Historia> _getHistoriasForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _historiasMap[date] ?? [];
  }

  Future<void> _deleteHistoria(Historia historia) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteStoryTitle),
        content: Text(AppLocalizations.of(context)!.deleteStoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context)!.deleteLabel,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final db = await DatabaseHelper().database;
        // Soft delete: marca como excluído ao invés de deletar
        await db.update(
          'historia',
          {
            'excluido': 'sim',
            'data_exclusao': DateTime.now().toIso8601String(),
            'data_update': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [historia.id],
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.movedToTrash)),
        );

        _loadHistorias();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorDeletingStory(e.toString()),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final localeName = Localizations.localeOf(context).toString();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.calendarTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Calendário
                Card(
                  margin: const EdgeInsets.all(8),
                  elevation: 2,
                  child: TableCalendar<Historia>(
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: _getHistoriasForDay,
                    locale: localeName,
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    availableCalendarFormats: {
                      CalendarFormat.month: loc.calendarFormatMonth,
                      CalendarFormat.twoWeeks: loc.calendarFormatTwoWeeks,
                      CalendarFormat.week: loc.calendarFormatWeek,
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
                      if (!isSameDay(_selectedDay, selectedDay)) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        _updateSelectedHistorias(selectedDay);
                      }
                    },
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                  ),
                ),

                // Divisor
                const Divider(height: 1),

                // Lista de histórias do dia selecionado
                Expanded(
                  child: ValueListenableBuilder<List<Historia>>(
                    valueListenable: _selectedHistorias,
                    builder: (context, historias, _) {
                      if (historias.isEmpty) {
                        return Center(
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
                                AppLocalizations.of(context)!.noRecordsThisDay,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: historias.length,
                        itemBuilder: (context, index) {
                          final historia = historias[index];
                          return _buildHistoriaCard(historia);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHistoriaCard(Historia historia) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: () {
          _showHistoriaDetails(historia);
        },
        onDoubleTap: () async {
          final result = await Navigator.push(
            context,
            RouteTransitionHelper.slideUpRotateTransition(
              EditHistoriaScreen(historia: historia),
            ),
          );
          if (result == true) {
            _loadHistorias();
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
                        final result = await Navigator.push(
                          context,
                          RouteTransitionHelper.slideUpRotateTransition(
                            EditHistoriaScreen(historia: historia),
                          ),
                        );
                        if (result == true) {
                          _loadHistorias();
                        }
                      } else if (value == 'delete') {
                        await _deleteHistoria(historia);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(AppLocalizations.of(context)!.edit),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(AppLocalizations.of(context)!.deleteLabel),
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
              // Grade de fotos com visualizador completo
              HistoriaFotosGrid(historiaId: historia.id ?? 0, height: 80),
            ],
          ),
        ),
      ),
    );
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
                // Handle do modal
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
                // Conteúdo
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
        // Cabeçalho com emoticon e título
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
                    DateFormat(
                      'dd/MM/yyyy HH:mm',
                      'pt_BR',
                    ).format(historia.data),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Descrição
        if (historia.descricao != null && historia.descricao!.isNotEmpty) ...[
          Text(
            'Descrição:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.labelColor(context),
            ),
          ),
          const SizedBox(height: 8),
          RichTextViewerWidget(jsonContent: historia.descricao),
          const SizedBox(height: 16),
        ],

        // Fotos com grade e visualizador completo
        HistoriaFotosGrid(historiaId: historia.id ?? 0, height: 200),
        const SizedBox(height: 8),
        // Áudios e vídeos
        HistoriaMediaRow(
          historiaId: historia.id ?? 0,
          emoticon: historia.emoticon,
        ),
      ],
    );
  }
}
