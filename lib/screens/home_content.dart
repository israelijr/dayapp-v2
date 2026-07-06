import 'dart:async';
import 'dart:ui' as ui;

import 'package:dayapp/helpers/route_transition_helper.dart';
import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
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
import '../widgets/compact_historia_card.dart';
import '../widgets/insight_card.dart';
import '../widgets/story_card.dart';
import '../widgets/user_profile_avatar.dart';
import 'create_historia_screen.dart';
import 'edit_historia_screen.dart';
import 'edit_profile_screen.dart';
import 'group_selection_screen.dart';
import 'search_screen.dart';


HeroFlightShuttleBuilder _storyHeroFlightShuttleBuilder(Historia historia, String localeName) {
  return (
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final colorScheme = Theme.of(toHeroContext).colorScheme;
    final dateText = DateFormat.yMd(localeName).add_Hm().format(historia.data);
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
          flightShuttleBuilder: _storyHeroFlightShuttleBuilder(historia, Localizations.localeOf(context).toString()),
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

  Future<void> _groupStory(Historia historia) async {
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

  Future<void> _ungroupStory(Historia historia) async {
    final storiesProvider = context.read<HomeStoriesProvider>();
    await storiesProvider.updateStory(historia, updates: {'grupo': null});
  }

  Future<void> _unarchiveStory(Historia historia) async {
    final storiesProvider = context.read<HomeStoriesProvider>();
    await storiesProvider.updateStory(historia, updates: {'arquivado': null});
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
    return StoryCard(
      historia: historia,
      heroTag: _storyHeroTag(historia),
      flightShuttleBuilder: _storyHeroFlightShuttleBuilder(historia, Localizations.localeOf(context).toString()),
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

  Widget _buildIconView(Historia historia) {
    return Hero(
      tag: _storyHeroTag(historia),
      createRectTween: (begin, end) =>
          MaterialRectArcTween(begin: begin, end: end),
      flightShuttleBuilder: _storyHeroFlightShuttleBuilder(historia, Localizations.localeOf(context).toString()),
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
          Provider.of<InsightProvider>(
            context,
            listen: false,
          ).loadInsights(userId);
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

              final name = userName.isNotEmpty ? userName.split(' ').first : '';
              final greetingText = name.isNotEmpty
                  ? l10n.homeGreetingPhrase(name, greeting)
                  : l10n.homeGreetingPhraseNoName(greeting);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(34),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
                            Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(34),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              UserProfileAvatar(
                                fotoPerfil: user?.fotoPerfil,
                                radius: 20,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  greetingText,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            l10n.homeGreetingSubtitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(height: 18),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                RouteTransitionHelper.slideUpRotateTransition(
                                  const CreateHistoriaScreen(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    '✏️',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      l10n.startNewStoryPlaceholder,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.viewAllStoriesLabel,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                              Transform.scale(
                                scale: 0.9,
                                child: Switch.adaptive(
                                  value: widget.showAllStories,
                                  onChanged: widget.onToggleShowAllStories,
                                  activeThumbColor: Theme.of(context).colorScheme.primary,
                                  activeTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.28),
                                  inactiveTrackColor: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.3),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
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
                onPremiumCTA: () => Navigator.of(context).pushNamed('/premium'),
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
            // Quando `showAllStories` for true, agrupamos por data e
            // construímos uma lista plana `bodyItems` contendo cabeçalhos
            // de data e histórias para renderização consistente (igual à tela de busca).
            final List<Object> bodyItems = [];
            if (widget.showAllStories && storiesCount > 0) {
              // Agrupar por data (yyyy-MM-dd)
              final Map<String, List<Historia>> grouped = {};
              for (final h in widget.historias) {
                final key = DateFormat('yyyy-MM-dd').format(h.data);
                grouped.putIfAbsent(key, () => []).add(h);
              }

              final sortedDates = grouped.keys.toList()
                ..sort((a, b) {
                  final dateA = DateFormat('yyyy-MM-dd').parse(a);
                  final dateB = DateFormat('yyyy-MM-dd').parse(b);
                  return dateB.compareTo(dateA);
                });

              for (final dateKey in sortedDates) {
                final list = grouped[dateKey]!;
                bodyItems.add({
                  'type': 'header',
                  'date': dateKey,
                  'count': list.length,
                });
                for (final h in list) {
                  bodyItems.add(h);
                }
              }
              if (widget.hasMoreData) bodyItems.add({'type': 'loading'});
            }

            final bool showEmptyPlaceholder = widget.showAllStories && storiesCount == 0;
            final totalBodyItems = showEmptyPlaceholder ? 1 : bodyItems.length;
            final totalItems = headerCount + totalBodyItems;

            return LayoutBuilder(
              builder: (context, constraints) {
                return ListView.builder(
                  key: ValueKey<bool>(widget.isCardView),
                  controller: storiesCount > 0 ? widget.scrollController : null,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
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
                    if (showEmptyPlaceholder) {
                      final shortestSide = MediaQuery.sizeOf(
                        context,
                      ).shortestSide;
                      final imageSize =
                          (shortestSide * 0.35).clamp(90.0, 140.0) * 1.3;

                      // Calculate remaining height to center it vertically in the remaining space
                      final double estimatedHeaderHeight =
                          140.0 + (insights.length * 150.0);
                      final double remainingHeight =
                          (constraints.maxHeight - estimatedHeaderHeight - 32.0)
                              .clamp(280.0, 800.0);

                      return SizedBox(
                        height: remainingHeight,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/image/home_vazia.png',
                                width: imageSize,
                                height: imageSize,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.auto_stories_outlined,
                                    size: 64,
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.4),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context)!.noStoriesHere,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Histórias / headers quando showAllStories == true
                    if (bodyIndex < bodyItems.length) {
                      final item = bodyItems[bodyIndex];
                      if (item is Map && item['type'] == 'header') {
                        final dateKey = item['date'] as String;
                        final count = item['count'] as int;
                        // Reuse header style from SearchScreen
                        final l10n = AppLocalizations.of(context)!;
                        final date = DateFormat(
                          'yyyy-MM-dd',
                        ).parse(dateKey);
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final yesterday = today.subtract(
                          const Duration(days: 1),
                        );
                        final parsedDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                        );

                        String displayDate;
                        if (parsedDate == today) {
                          displayDate = l10n.today;
                        } else if (parsedDate == yesterday) {
                          displayDate = l10n.yesterday;
                        } else {
                          displayDate = DateFormat.MMMMEEEEd(
                            Localizations.localeOf(context).toString(),
                          ).format(date);
                          displayDate =
                              displayDate[0].toUpperCase() +
                              displayDate.substring(1);
                        }

                        return Container(
                          margin: const EdgeInsets.only(top: 16, bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  displayDate,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$count',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (item is Map && item['type'] == 'loading') {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: widget.isLoadingMore
                                ? const CircularProgressIndicator()
                                : const SizedBox.shrink(),
                          ),
                        );
                      }

                      final historia = item as Historia;
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
            );
          },
        ),
      ),
    );
  }
}
