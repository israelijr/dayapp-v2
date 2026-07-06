import 'package:dayapp/helpers/route_transition_helper.dart';
import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:dayapp/widgets/pulse_animation.dart';
import 'package:dayapp/widgets/story_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../db/historia_foto_helper.dart';
import '../models/historia.dart';
import '../providers/auth_provider.dart';
import '../providers/refresh_provider.dart';
import '../providers/scroll_position_provider.dart';
import '../repositories/historia_repository.dart';
import '../theme/animation_durations.dart';
import '../theme/m3_expressive_theme.dart';
import 'create_historia_screen.dart';
import 'edit_historia_screen.dart';
import 'group_selection_screen.dart';

class ArchivedStoriesScreen extends StatefulWidget {
  const ArchivedStoriesScreen({super.key});

  @override
  State<ArchivedStoriesScreen> createState() => _ArchivedStoriesScreenState();
}

class _ArchivedStoriesScreenState extends State<ArchivedStoriesScreen> {
  final HistoriaRepository _historiaRepository = HistoriaRepository();
  bool _isCardView = true; // true = modo blocos, false = modo ícones

  // Controle de scroll para manter posição da lista
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Restaura posição do scroll ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreScrollPosition();
    });
  }

  @override
  void dispose() {
    // Salva posição do scroll ao sair da tela
    _saveScrollPosition();
    _scrollController.dispose();
    super.dispose();
  }

  /// Restaura a posição do scroll para a posição anterior
  void _restoreScrollPosition() {
    final scrollProvider = Provider.of<ScrollPositionProvider>(
      context,
      listen: false,
    );
    const scrollKey = 'archived_list_scroll';
    final savedPosition = scrollProvider.getScrollPosition(scrollKey);
    if (_scrollController.hasClients && savedPosition > 0) {
      _scrollController.jumpTo(savedPosition);
    }
  }

  /// Salva a posição do scroll antes de sair da tela
  void _saveScrollPosition() {
    if (_scrollController.hasClients) {
      final scrollProvider = Provider.of<ScrollPositionProvider>(
        context,
        listen: false,
      );
      const scrollKey = 'archived_list_scroll';
      scrollProvider.saveScrollPosition(scrollKey, _scrollController.offset);
    }
  }

  @override
  void deactivate() {
    // Salva a posição quando o widget é removido da widget tree
    _saveScrollPosition();
    super.deactivate();
  }

  // Converte nomes de humor antigos para emojis Unicode
  // Retorna null se já for um emoji (default case)
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
        return null; // Já é um emoji Unicode
    }
  }

  Future<List<Historia>> _fetchHistoriasArquivadas() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id ?? '';
    return _historiaRepository.fetchArchivedStories(userId: userId);
  }

  Future<void> _deleteHistoria(Historia historia) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteStoryTitle),
        content: Text(AppLocalizations.of(context)!.deleteStoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppLocalizations.of(context)!.deleteLabel,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _historiaRepository.deleteHistoria(historia);
      if (!mounted) return;
      final refreshProvider = Provider.of<RefreshProvider>(
        context,
        listen: false,
      );
      refreshProvider.refresh();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.movedToTrash)),
      );
    }
  }

  Future<void> _updateHistoria(
    Historia historia, {
    Map<String, dynamic>? updates,
  }) async {
    await _historiaRepository.updateHistoria(historia, updates: updates);
    if (!mounted) return;
    final refreshProvider = Provider.of<RefreshProvider>(
      context,
      listen: false,
    );
    refreshProvider.refresh();
  }

  Future<void> _groupStory(Historia historia) async {
    final selectedGroup = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const GroupSelectionScreen()),
    );

    if (selectedGroup == null) {
      return;
    }

    await _updateHistoria(
      historia,
      updates: {'grupo': selectedGroup, 'arquivado': null, 'tag': null},
    );
  }

  Future<void> _unarchiveStory(Historia historia) async {
    await _updateHistoria(
      historia,
      updates: {'arquivado': null, 'tag': null, 'grupo': null},
    );
  }

  Future<void> _ungroupStory(Historia historia) async {
    await _updateHistoria(historia, updates: {'grupo': null});
  }

  Widget _buildCardView(Historia historia) {
    return StoryCard(
      historia: historia,
      convertLegacyEmoticon: _convertLegacyEmoticon,
      onPreview: () => _openStoryPreview(historia),
      onDoubleTap: () => _openStoryPreview(historia),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_horiz,
              color: Theme.of(context).iconTheme.color,
            ),
            onSelected: (value) async {
              if (value == 'edit') {
                final refreshProvider = Provider.of<RefreshProvider>(
                  context,
                  listen: false,
                );
                Navigator.push(
                  context,
                  RouteTransitionHelper.slideUpRotateTransition(
                    EditHistoriaScreen(historia: historia),
                  ),
                ).then((updated) {
                  if (!mounted) return;
                  if (updated == true) {
                    refreshProvider.refresh();
                  }
                });
              } else if (value == 'delete') {
                await _deleteHistoria(historia);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Text(AppLocalizations.of(context)!.editDoubleTapHint),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(AppLocalizations.of(context)!.deleteLabel),
              ),
            ],
          ),
        ],
      ),
      stateLabel: historia.grupo?.isNotEmpty == true
          ? historia.grupo
          : historia.arquivado != null
          ? AppLocalizations.of(context)!.archivedStateLabel
          : null,
    );
  }

  Future<void> _openStoryPreview(Historia historia) async {
    try {
      await _warmupStoryPreviewMedia(
        historia,
      ).timeout(const Duration(milliseconds: 180));
    } catch (_) {
      // Ignora timeout/falha de pré-carregamento.
    }

    if (!mounted) return;

    final action = await Navigator.of(context).push<StoryPreviewAction>(
      MaterialPageRoute(
        builder: (_) => StoryPreviewScreen(
          historia: historia,
          localeName: AppLocalizations.of(context)!.localeName,
          convertLegacyEmoticon: _convertLegacyEmoticon,
          heroTag: 'archived_story_${historia.id ?? historia.titulo.hashCode}',
          showEditDelete: true,
          showMoodNotes: true,
        ),
      ),
    );

    if (!mounted || action == null || action == StoryPreviewAction.close) {
      return;
    }

    if (action == StoryPreviewAction.edit) {
      final updated = await Navigator.of(context).push(
        RouteTransitionHelper.slideUpRotateTransition(
          EditHistoriaScreen(historia: historia),
        ),
      );
      if (!mounted) return;
      if (updated == true) {
        Provider.of<RefreshProvider>(context, listen: false).refresh();
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

    if (action == StoryPreviewAction.unarchive) {
      await _unarchiveStory(historia);
    }
  }

  Future<void> _warmupStoryPreviewMedia(Historia historia) async {
    final historiaId = historia.id;
    if (historiaId == null || historiaId <= 0) return;
    await HistoriaFotoHelper().getFotosComBytesByHistoria(historiaId);
  }

  Widget _buildIconView(Historia historia) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Builder(
              builder: (context) {
                if (historia.emoticon != null &&
                    historia.emoticon!.isNotEmpty) {
                  final converted = _convertLegacyEmoticon(historia.emoticon!);
                  final display = converted ?? historia.emoticon!;
                  return Text(
                    display,
                    style: const TextStyle(fontSize: 20, height: 1),
                  );
                }
                return Icon(
                  Icons.image,
                  color: Theme.of(context).iconTheme.color,
                  size: 26,
                );
              },
            ),
          ),
        ),
        title: Text(
          historia.titulo,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            color: Theme.of(context).textTheme.titleMedium?.color,
            height: 1.25,
          ),
        ),
        subtitle: Text(
          DateFormat.yMd(Localizations.localeOf(context).toString()).format(historia.data),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_horiz,
            color: Theme.of(context).iconTheme.color,
          ),
          onSelected: (value) async {
            if (value == 'edit') {
              Navigator.push(
                context,
                RouteTransitionHelper.slideUpRotateTransition(
                  EditHistoriaScreen(historia: historia),
                ),
              ).then((updated) {
                if (!mounted) return;
                if (updated == true) {
                  final refreshProvider = Provider.of<RefreshProvider>(
                    context,
                    listen: false,
                  );
                  refreshProvider.refresh();
                }
              });
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
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: SingleChildScrollView(child: _buildCardView(historia)),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(AppLocalizations.of(context)!.close),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.archivedTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(fontSize: 24, height: 1.3),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isCardView ? Icons.grid_view_rounded : Icons.view_agenda_rounded,
            ),
            onPressed: () {
              setState(() {
                _isCardView = !_isCardView;
              });
            },
            tooltip: _isCardView
                ? AppLocalizations.of(context)!.toggleToIcons
                : AppLocalizations.of(context)!.toggleToCards,
          ),
        ],
      ),
      body: Consumer<RefreshProvider>(
        builder: (context, refreshProvider, child) {
          return FutureBuilder<List<Historia>>(
            key: ValueKey<int>(refreshProvider.refreshCounter),
            future: _fetchHistoriasArquivadas(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final historias = snapshot.data ?? [];
              if (historias.isEmpty) {
                return Center(
                  child: Text(
                    AppLocalizations.of(context)!.noArchivedStories,
                    style: TextStyle(color: AppColors.labelColor(context)),
                  ),
                );
              }
              return AnimatedSwitcher(
                duration: AppDurations.listSwitch,
                child: ListView.builder(
                  key: ValueKey<bool>(_isCardView),
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  itemCount: historias.length,
                  itemBuilder: (context, index) {
                    final historia = historias[index];
                    return _isCardView
                        ? _buildCardView(historia)
                        : _buildIconView(historia);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 12, right: 12),
        child: PulseAnimation(
          scaleTarget: 1.06,
          child: FloatingActionButton.extended(
            onPressed: () {
              final refreshProvider = Provider.of<RefreshProvider>(
                context,
                listen: false,
              );
              Navigator.push(
                context,
                RouteTransitionHelper.slideUpRotateTransition(
                  const CreateHistoriaScreen(initialArchived: true),
                ),
              ).then((created) {
                if (!mounted) return;
                refreshProvider.refresh();
              });
            },
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.newStoryHere),
          ),
        ),
      ),
    );
  }
}
