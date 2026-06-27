import 'dart:async';

import 'package:dayapp/helpers/route_transition_helper.dart';
import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../db/historia_foto_helper.dart';
import '../models/historia.dart';
import '../models/insight.dart';
import '../providers/auth_provider.dart';
import '../providers/home_stories_provider.dart';
import '../providers/insight_provider.dart';
import '../providers/refresh_provider.dart';
import '../providers/scroll_position_provider.dart';
import '../services/thumbnail_service.dart';
import '../theme/animation_durations.dart';
import '../theme/m3_expressive_theme.dart';
import '../widgets/compact_historia_card.dart';
import '../widgets/insight_card.dart';
import '../widgets/story_card.dart';
import 'edit_historia_screen.dart';
import 'group_selection_screen.dart';
import 'search_screen.dart';

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
                                    const SizedBox(height: 2),
                                    Text(
                                      dateText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.2,
                                        color: colorScheme.onSurfaceVariant
                                            .withValues(alpha: 0.72),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.open_in_full_rounded,
                                size: 16,
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.55,
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

class HomeContent extends StatefulWidget {
  final bool isCardView;
  const HomeContent({required this.isCardView, super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _isCardView = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Detecta scroll perto do final para carregar mais dados
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<HomeStoriesProvider>().loadMoreStories();
    }
  }

  @override
  Widget build(BuildContext context) {
    _isCardView = widget.isCardView;
    return Consumer<RefreshProvider>(
      builder: (context, refreshProvider, child) {
        return Consumer<HomeStoriesProvider>(
          builder: (context, storiesProvider, _) {
            return _PaginatedHomeContent(
              key: ValueKey(
                '${refreshProvider.refreshCounter}_${storiesProvider.showAllStories}',
              ),
              isCardView: _isCardView,
              showAllStories: storiesProvider.showAllStories,
              onToggleShowAllStories: storiesProvider.toggleShowAllStories,
              historias: storiesProvider.historias,
              isInitialLoading: storiesProvider.isInitialLoading,
              isLoadingMore: storiesProvider.isLoadingMore,
              hasMoreData: storiesProvider.hasMoreData,
              scrollController: _scrollController,
              onRefresh: storiesProvider.refreshStories,
              buildCardView: _buildCardView,
              buildIconView: _buildIconView,
            );
          },
        );
      },
    );
  }

  Future<void> _deleteHistoria(Historia historia) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final localizations = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(localizations.deleteStoryTitle),
          content: Text(localizations.deleteStoryConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                localizations.deleteLabel,
                style: TextStyle(color: Theme.of(ctx).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      if (!mounted) return;
      final storiesProvider = context.read<HomeStoriesProvider>();
      await storiesProvider.deleteStory(historia);
      if (!mounted) return;

      final localizations = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(localizations.movedToTrash)));
    }
  }

  Future<void> _archiveWithUndo(Historia historia) async {
    final previousGrupo = historia.grupo;
    final storiesProvider = context.read<HomeStoriesProvider>();
    await storiesProvider.archiveStory(historia);

    if (!mounted) return;
    final localizations = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final controller = messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        content: Text(localizations.storyArchived),
        action: SnackBarAction(
          label: localizations.undo,
          onPressed: () async {
            await storiesProvider.updateStory(
              historia,
              updates: {'arquivado': null, 'grupo': previousGrupo},
            );
          },
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 5), controller.close);
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
        Provider.of<RefreshProvider>(context, listen: false).refresh();
      }
      return;
    }

    if (action == StoryPreviewAction.delete) {
      await _deleteHistoria(historia);
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
      // Evita interromper a abertura da preview se o prewarm falhar.
      debugPrint('HomeContent: falha no prewarm de mídia da preview: $e');
    }
  }

  String _storyHeroTag(Historia historia) {
    final id =
        historia.id?.toString() ??
        '${historia.titulo}_${historia.data.millisecondsSinceEpoch}';
    return 'home_story_card_$id';
  }

  Widget _buildExpandFab(Historia historia) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: 34,
      height: 34,
      child: FloatingActionButton.small(
        heroTag: null,
        elevation: 1,
        tooltip: l10n.preview,
        backgroundColor: colorScheme.surfaceContainerLow,
        foregroundColor: colorScheme.onSurfaceVariant,
        onPressed: () => _openStoryPreview(historia),
        child: const Icon(Icons.open_in_full_rounded, size: 16),
      ),
    );
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
            label: AppLocalizations.of(context)!.archiveLabel,
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              final navigator = Navigator.of(context);
              final storiesProvider = context.read<HomeStoriesProvider>();
              final selectedGroup = await navigator.push<String>(
                MaterialPageRoute(builder: (_) => const GroupSelectionScreen()),
              );
              if (selectedGroup != null) {
                await storiesProvider.updateStory(
                  historia,
                  updates: {'grupo': selectedGroup},
                );
              }
            },
            backgroundColor: AppColors.emoticonGreen,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            icon: Icons.group,
            label: AppLocalizations.of(context)!.group,
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
          AppLocalizations.of(context)!.archiveLabel,
          style: GoogleFonts.plusJakartaSans(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.emoticonGreen,
        child: Text(
          AppLocalizations.of(context)!.group,
          style: GoogleFonts.plusJakartaSans(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _archiveWithUndo(historia);
          return true;
        } else if (direction == DismissDirection.endToStart) {
          final navigator = Navigator.of(context);
          final storiesProvider = context.read<HomeStoriesProvider>();
          final selectedGroup = await navigator.push<String>(
            MaterialPageRoute(builder: (_) => const GroupSelectionScreen()),
          );
          if (selectedGroup != null) {
            await storiesProvider.updateStory(
              historia,
              updates: {'grupo': selectedGroup},
            );
          }
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
        flightShuttleBuilder: _storyHeroFlightShuttleBuilder(historia),
        placeholderBuilder: (context, size, child) =>
            SizedBox(width: size.width, height: size.height),
        child: CompactHistoriaCard(
          historia: historia,
          localeName: AppLocalizations.of(context)!.localeName,
          stateLabel: historia.grupo?.isNotEmpty == true
              ? historia.grupo
              : historia.arquivado != null
              ? AppLocalizations.of(context)!.archivedStateLabel
              : null,
          trailing: _buildExpandFab(historia),
          overlayTrailing: true,
          onDoubleTap: () => _openStoryPreview(historia),
        ),
      ),
    );
  }
}

class _PaginatedHomeContent extends StatefulWidget {
  final bool isCardView;
  final bool showAllStories;
  final ValueChanged<bool> onToggleShowAllStories;
  final List<Historia> historias;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasMoreData;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final Widget Function(Historia) buildCardView;
  final Widget Function(Historia) buildIconView;

  const _PaginatedHomeContent({
    required this.isCardView,
    required this.showAllStories,
    required this.onToggleShowAllStories,
    required this.historias,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.hasMoreData,
    required this.scrollController,
    required this.onRefresh,
    required this.buildCardView,
    required this.buildIconView,
    super.key,
  });

  @override
  State<_PaginatedHomeContent> createState() => _PaginatedHomeContentState();
}

class _PaginatedHomeContentState extends State<_PaginatedHomeContent> {
  bool _hasRefreshed = false;
  // Chave para identificar a posição do scroll desta tela
  static const String _scrollPositionKey = 'home_list_scroll';

  @override
  void initState() {
    super.initState();
    // Recarrega dados quando a key muda (RefreshProvider foi atualizado)
    // Usa addPostFrameCallback para evitar setState durante build
    // Só executa uma vez por instância do widget
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_hasRefreshed) {
        _hasRefreshed = true;
        await widget.onRefresh();
        // Carrega insights ao abrir a Home
        if (!mounted) return;
        final userId =
            Provider.of<AuthProvider>(context, listen: false).user?.id ?? '';
        if (userId.isNotEmpty) {
          // Usa loadInsights (que respeita o cache de 24h) em vez de refresh
          // para evitar queries pesadas no banco a todo momento e a piscada
          Provider.of<InsightProvider>(context, listen: false).loadInsights(userId);
        }
        // Restaura posição do scroll após dados serem carregados
        if (!mounted) return;
        _restoreScrollPositionAfterLoad();
      }
    });
  }

  /// Restaura a posição do scroll após os dados serem carregados
  /// Aguarda um frame para garantir que o ListView tem clientes
  void _restoreScrollPositionAfterLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final scrollProvider = Provider.of<ScrollPositionProvider>(
        context,
        listen: false,
      );
      final savedPosition = scrollProvider.getScrollPosition(
        _scrollPositionKey,
      );
      if (widget.scrollController.hasClients && savedPosition > 0) {
        widget.scrollController.jumpTo(savedPosition);
      }
    });
  }

  /// Salva a posição do scroll antes de sair da tela
  void _saveScrollPosition() {
    if (widget.scrollController.hasClients) {
      final scrollProvider = Provider.of<ScrollPositionProvider>(
        context,
        listen: false,
      );
      scrollProvider.saveScrollPosition(
        _scrollPositionKey,
        widget.scrollController.offset,
      );
    }
  }

  @override
  void deactivate() {
    // Salva a posição quando o widget é removido da widget tree
    _saveScrollPosition();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    // Mostra loading inicial
    if (widget.isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Lista com paginação
    return AnimatedSwitcher(
      duration: AppDurations.listSwitch,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
      child: RefreshIndicator(
        onRefresh: () async {
          // Resolve referências antes do gap assíncrono para evitar avisos de use_build_context_synchronously
          final storiesProvider = context.read<HomeStoriesProvider>();
          final authProvider = context.read<AuthProvider>();
          final insightProvider = context.read<InsightProvider>();

          await storiesProvider.refreshStories(forceRefresh: true);
          
          final userId = authProvider.user?.id ?? '';
          if (userId.isNotEmpty) {
            await insightProvider.refresh(userId);
          }
        },
        child: Consumer<InsightProvider>(
          builder: (context, insightProvider, _) {
            final insights = insightProvider.insights;
            final storiesCount = widget.historias.length;

            Widget greetingBanner() {
              final l10n = AppLocalizations.of(context)!;
              final user = Provider.of<AuthProvider>(
                context,
                listen: false,
              ).user;
              final userName = user?.nome ?? '';
              final now = DateTime.now();
              final greeting = now.hour < 12
                  ? l10n.homeGreetingMorning
                  : now.hour < 18
                  ? l10n.homeGreetingAfternoon
                  : l10n.homeGreetingEvening;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.18),
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // PRIMEIRA LINHA: Texto (com quebra automática) e Logo alinhados ao centro vertical
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            '$greeting${userName.isNotEmpty ? ',\n$userName' : ''}.', // Adicionado \n para forçar a quebra após a vírgula se preferir, ou deixe sem para quebrar apenas se faltar espaço
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              height: 1.2,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/image/LogoDayApp.png',
                                width: 74,
                                height: 74,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // SEGUNDA LINHA: Texto e Elementos do Switch alinhados horizontalmente e verticalmente ao centro
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Empurra o texto para um lado e o switch para o outro
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // Alinha verticalmente ao centro da linha
                      children: [
                        Expanded(
                          child: Text(
                            l10n.homeStoriesSubtitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Agrupamento do label do switch + switch
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.homeShowAllStoriesLabel,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Transform.scale(
                              scale: 0.9,
                              child: Switch.adaptive(
                                value: widget.showAllStories,
                                onChanged: widget.onToggleShowAllStories,
                                activeThumbColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                activeTrackColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.28),
                                inactiveTrackColor: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                    .withValues(alpha: 0.3),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            // userId necessário para o callback de dispensa
            final userId =
                Provider.of<AuthProvider>(context, listen: false).user?.id ??
                '';
            final headerCount = 1 + insights.length;

            /// Constrói um InsightCard com todos os callbacks configurados.
            Widget buildInsightCard(Insight insight) {
              return InsightCard(
                insight: insight,
                onDismiss: () =>
                    insightProvider.dismissInsight(userId, insight.type),
                onPremiumCTA: () =>
                    Navigator.of(context).pushNamed('/premium'),
                onSeeStories: (query) {
                  final searchType = insight.type == InsightType.positiveTag
                      ? SearchType.tag
                      : SearchType.text;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SearchScreen(
                        initialQuery: query,
                        initialSearchType: searchType,
                      ),
                    ),
                  );
                },
                onDoubleTap: insight.type == InsightType.energyChart
                    ? () => insightProvider.refresh(userId)
                    : null,
              );
            }

            // Lista unificada: saudação + insights (topo) + histórias (corpo).
            final totalBodyItems = storiesCount == 0
                ? 1 // placeholder de lista vazia
                : storiesCount + (widget.hasMoreData ? 1 : 0);
            final totalItems = headerCount + totalBodyItems;

            return ListView.builder(
              key: ValueKey<bool>(widget.isCardView),
              controller: storiesCount > 0 ? widget.scrollController : null,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: totalItems,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return greetingBanner();
                }

                if (index < headerCount) {
                  final insightIndex = index - 1;
                  return buildInsightCard(insights[insightIndex]);
                }

                // Índice no corpo (histórias / mensagem vazia)
                final bodyIndex = index - headerCount;

                // Mensagem de lista vazia quando há insights mas não há histórias
                if (storiesCount == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/image/home_vazia.png',
                            width: 120,
                            height: 120,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.auto_stories_outlined,
                                size: 64,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.4),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!.noStoriesHere,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Histórias
                if (bodyIndex < storiesCount) {
                  final historia = widget.historias[bodyIndex];
                  return widget.isCardView
                      ? widget.buildCardView(historia)
                      : widget.buildIconView(historia);
                }

                // Indicador de carregamento de mais dados
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: widget.isLoadingMore
                        ? const CircularProgressIndicator()
                        : const SizedBox.shrink(),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
