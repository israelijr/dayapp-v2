import 'package:dayapp/helpers/route_transition_helper.dart';
import 'package:dayapp/l10n/app_localizations.dart';
import 'package:dayapp/widgets/compact_historia_card.dart';
import 'package:dayapp/widgets/pulse_animation.dart';
import 'package:dayapp/widgets/story_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../db/historia_foto_helper.dart';
import '../models/grupo.dart';
import '../models/historia.dart';
import '../providers/auth_provider.dart';
import '../providers/group_stories_provider.dart';
import '../providers/scroll_position_provider.dart';
import '../repositories/group_repository.dart';
import '../theme/animation_durations.dart';
import '../theme/m3_expressive_theme.dart';
import 'create_historia_screen.dart';
import 'edit_historia_screen.dart';
import 'group_selection_screen.dart';

HeroFlightShuttleBuilder _storyHeroFlightShuttleBuilder(Historia historia) {
  return (
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final colorScheme = Theme.of(toHeroContext).colorScheme;
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
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.85,
                                      ),
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.auto_stories_outlined,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.72),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      historia.titulo,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        color: colorScheme.onSurface.withValues(
                                          alpha: 0.88,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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

class GroupStoriesScreen extends StatefulWidget {
  final Grupo grupo;
  final bool isUngroupedGroup;

  const GroupStoriesScreen({
    required this.grupo,
    this.isUngroupedGroup = false,
    super.key,
  });

  @override
  State<GroupStoriesScreen> createState() => _GroupStoriesScreenState();
}

class _GroupStoriesScreenState extends State<GroupStoriesScreen> {
  // Constantes para melhor organização
  // Key para ScaffoldMessenger local — snackbars ficam escopados a esta tela
  // e são descartados automaticamente quando o usuário navega para outra rota.
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  bool _isCardView = true; // true = modo blocos, false = modo ícones

  // Controle de scroll para manter posição da lista
  final ScrollController _scrollController = ScrollController();
  late final GroupStoriesProvider _storiesProvider;

  String get _scrollPositionKey => 'group_list_scroll_${widget.grupo.nome}';

  @override
  void initState() {
    super.initState();
    _storiesProvider = GroupStoriesProvider(
      repository: GroupRepository(),
      authProvider: context.read<AuthProvider>(),
      grupoId: widget.grupo.id ?? 0,
      groupName: widget.grupo.nome,
      isUngroupedGroup: widget.isUngroupedGroup,
    )..loadStories();

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
    // _storiesProvider is provided to the widget tree via ChangeNotifierProvider
    // and will be disposed by the provider. Avoid double-dispose here.
    super.dispose();
  }

  /// Restaura a posição do scroll para a posição anterior
  void _restoreScrollPosition() {
    final scrollProvider = Provider.of<ScrollPositionProvider>(
      context,
      listen: false,
    );
    final savedPosition = scrollProvider.getScrollPosition(_scrollPositionKey);
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
      scrollProvider.saveScrollPosition(
        _scrollPositionKey,
        _scrollController.offset,
      );
    }
  }

  void _restoreScrollPositionAfterPreview() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _restoreScrollPosition();
    });
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

  Future<void> _updateHistoria(
    Historia historia, {
    Map<String, dynamic>? updates,
  }) async {
    await _storiesProvider.updateHistoria(historia, updates: updates);
  }

  Future<void> _archiveWithUndo(Historia historia) async {
    final previousTag = historia.tag;
    final previousGrupo = historia.grupo;
    await _updateHistoria(
      historia,
      updates: {'arquivado': 'sim', 'grupo': null},
    );
    if (!mounted) return;

    final localizations = AppLocalizations.of(context);
    final messenger = _messengerKey.currentState!;
    messenger.hideCurrentSnackBar();
    final controller = messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        content: Text(localizations!.storyArchived),
        action: SnackBarAction(
          label: localizations.undo,
          onPressed: () async {
            await _updateHistoria(
              historia,
              updates: {
                'arquivado': null,
                'tag': previousTag,
                'grupo': previousGrupo,
              },
            );
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

    await _updateHistoria(historia, updates: {'grupo': selectedGroup});
  }

  Future<void> _ungroupStory(Historia historia) async {
    final ungroupedMsg = AppLocalizations.of(context)!.storyUngrouped;
    await _storiesProvider.ungroupHistoria(historia);
    if (!mounted) return;
    _messengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(ungroupedMsg)),
    );
  }

  Future<bool> _confirmDeleteHistoria() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteStoryTitle),
        content: Text(l10n.deleteStoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: Text(l10n.deleteLabel),
          ),
        ],
      ),
    );

    return confirm == true;
  }

  Widget _buildCardView(Historia historia) {
    return Slidable(
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              await _archiveWithUndo(historia);
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            icon: Icons.archive,
            label: AppLocalizations.of(context)?.archiveLabel ?? 'Arquivar',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (slidableContext) async {
              final ungroupedMsg = AppLocalizations.of(
                slidableContext,
              )!.storyUngrouped;
              await slidableContext
                  .read<GroupStoriesProvider>()
                  .ungroupHistoria(historia);
              if (!mounted) return;
              _messengerKey.currentState?.showSnackBar(
                SnackBar(content: Text(ungroupedMsg)),
              );
            },
            backgroundColor: AppColors.emoticonGreen,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            icon: Icons.group_off,
            label: AppLocalizations.of(context)?.ungroup ?? 'Desagrupar',
          ),
        ],
      ),
      child: StoryCard(
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
      ),
    );
  }

  Widget _buildIconView(Historia historia) {
    return Dismissible(
      key: Key('icon_${historia.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Theme.of(context).colorScheme.primary,
        child: Text(
          AppLocalizations.of(context)?.archiveLabel ?? 'Arquivar',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.emoticonGreen,
        child: Text(
          AppLocalizations.of(context)?.ungroup ?? 'Desagrupar',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _archiveWithUndo(historia);
          return true;
        } else if (direction == DismissDirection.endToStart) {
          final ungroupedMsg = AppLocalizations.of(context)!.storyUngrouped;
          await context.read<GroupStoriesProvider>().ungroupHistoria(historia);
          if (!mounted) return false;
          _messengerKey.currentState?.showSnackBar(
            SnackBar(content: Text(ungroupedMsg)),
          );
          return true;
        }
        return false;
      },
      onDismissed: (direction) {
        // Já tratado no confirmDismiss
      },
      child: Hero(
        tag: _storyHeroTag(historia),
        createRectTween: (begin, end) =>
            MaterialRectArcTween(begin: begin, end: end),
        placeholderBuilder: (context, size, child) =>
            SizedBox(width: size.width, height: size.height),
        child: Material(
          color: Colors.transparent,
          child: CompactHistoriaCard(
            historia: historia,
            localeName:
                AppLocalizations.of(context)?.localeName ??
                Localizations.localeOf(context).toString(),
            stateLabel: historia.grupo?.isNotEmpty == true
                ? historia.grupo
                : historia.arquivado != null
                ? AppLocalizations.of(context)!.archivedStateLabel
                : null,
            overlayTrailing: true,
            trailing: Material(
              shape: const CircleBorder(),
              color: Theme.of(context).colorScheme.primary,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _openStoryPreview(historia),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.open_in_full,
                    size: 18,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            onDoubleTap: () => _openStoryPreview(historia),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupStoriesProvider>(
      create: (_) => _storiesProvider,
      child: ScaffoldMessenger(
        key: _messengerKey,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Row(
              children: [
                if (widget.grupo.emoticon != null &&
                    widget.grupo.emoticon!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      widget.grupo.emoticon!,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                Expanded(
                  child: Text(
                    widget.grupo.nome,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isCardView
                      ? Icons.grid_view_rounded
                      : Icons.view_agenda_rounded,
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
          body: Consumer<GroupStoriesProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final historias = provider.historias;
              if (historias.isEmpty) {
                return Center(
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.noStoriesInGroup(widget.grupo.nome),
                    style: TextStyle(color: AppColors.labelColor(context)),
                  ),
                );
              }

              return AnimatedSwitcher(
                duration: AppDurations.listSwitch,
                child: ListView.builder(
                  key: PageStorageKey<String>(
                    '${_scrollPositionKey}_${_isCardView ? 'cards' : 'icons'}',
                  ),
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
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PulseAnimation(
              scaleTarget: 1.06,
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    RouteTransitionHelper.slideUpRotateTransition(
                      CreateHistoriaScreen(initialGroup: widget.grupo.nome),
                    ),
                  ).then((created) async {
                    if (!mounted) return;
                    if (created == true) {
                      await _storiesProvider.loadStories();
                    }
                  });
                },
                icon: const Icon(Icons.add),
                label: Text(AppLocalizations.of(context)!.newStory),
              ),
            ),
          ),
        ), // Scaffold
      ), // ScaffoldMessenger
    ); // ChangeNotifierProvider
  }

  String _storyHeroTag(Historia historia) =>
      'group_story_${historia.id ?? historia.titulo.hashCode}';

  Future<void> _openStoryPreview(Historia historia) async {
    _saveScrollPosition();

    try {
      await _warmupStoryPreviewMedia(
        historia,
      ).timeout(const Duration(milliseconds: 180));
    } catch (_) {
      // Ignora timeout/falha de pré-carregamento.
    }

    if (!mounted) return;

    final heroTag = _storyHeroTag(historia);
    final action = await Navigator.of(context).push<StoryPreviewAction>(
      MaterialPageRoute(
        builder: (_) => StoryPreviewScreen(
          historia: historia,
          localeName: AppLocalizations.of(context)!.localeName,
          convertLegacyEmoticon: _convertLegacyEmoticon,
          heroTag: heroTag,
          flightShuttleBuilder: _storyHeroFlightShuttleBuilder(historia),
          showEditDelete: true,
          showMoodNotes: true,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    _restoreScrollPositionAfterPreview();

    if (action == null || action == StoryPreviewAction.close) {
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
        await _storiesProvider.loadStories();
      }
      return;
    }

    if (action == StoryPreviewAction.delete) {
      final confirmed = await _confirmDeleteHistoria();
      if (!confirmed || !mounted) {
        return;
      }

      await _storiesProvider.deleteHistoria(historia);
      if (!mounted) return;

      // Mantém o usuário na tela atual de grupo após exclusão via preview.
      _messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.movedToTrash)),
      );
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
      await _updateHistoria(historia, updates: {'arquivado': null});
      return;
    }
  }

  Future<void> _warmupStoryPreviewMedia(Historia historia) async {
    final historiaId = historia.id;
    if (historiaId == null || historiaId <= 0) return;
    await HistoriaFotoHelper().getFotosComBytesByHistoria(historiaId);
  }
}
