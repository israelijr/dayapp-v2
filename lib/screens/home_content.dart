import 'dart:async';

import 'package:dayapp/helpers/route_transition_helper.dart';
import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/database_helper.dart';
import '../db/historia_foto_helper.dart';
import '../models/historia.dart';
import '../models/insight.dart';
import '../providers/auth_provider.dart';
import '../providers/insight_provider.dart';
import '../providers/premium_provider.dart';
import '../providers/refresh_provider.dart';
import '../providers/scroll_position_provider.dart';
import '../services/thumbnail_service.dart';
import '../theme/animation_durations.dart';
import '../theme/m3_expressive_theme.dart';
import '../widgets/compact_historia_card.dart';
import '../widgets/insight_card.dart';
import '../widgets/story_card.dart';
import 'chapters_entry_screen.dart';
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
                                    style: GoogleFonts.notoSerif(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
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
                                      style: GoogleFonts.notoSerif(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
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
  final bool showChapterShortcutCard;
  const HomeContent({
    required this.isCardView,
    required this.showChapterShortcutCard,
    super.key,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // Constantes e estado do componente home
  static const int _pageSize = 15; // Número de histórias por página

  bool _isCardView = true;

  // Controle de paginação
  final ScrollController _scrollController = ScrollController();
  final List<Historia> _historias = [];
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Detecta scroll perto do final para carregar mais dados
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  /// Carrega os dados iniciais (primeira página)
  Future<void> _loadInitialData() async {
    setState(() {
      _isInitialLoading = true;
      _historias.clear();
      _hasMoreData = true;
    });

    await _fetchHistoriasPaginated(offset: 0);

    if (mounted) {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  /// Carrega mais dados (próxima página)
  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    await _fetchHistoriasPaginated(offset: _historias.length);

    if (mounted) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  /// Busca histórias com paginação
  Future<void> _fetchHistoriasPaginated({required int offset}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id ?? '';
    final db = await DatabaseHelper().database;

    final result = await db.query(
      'historia',
      where:
          'user_id = ? AND grupo IS NULL AND arquivado IS NULL AND excluido IS NULL',
      whereArgs: [userId],
      orderBy: 'data DESC',
      limit: _pageSize,
      offset: offset,
    );

    final newHistorias = result.map((map) => Historia.fromMap(map)).toList();

    if (mounted) {
      setState(() {
        // Evita duplicatas verificando IDs existentes
        final existingIds = _historias.map((h) => h.id).toSet();
        final filteredHistorias = newHistorias
            .where((h) => !existingIds.contains(h.id))
            .toList();
        _historias.addAll(filteredHistorias);
        _hasMoreData = newHistorias.length == _pageSize;
      });
    }
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
    final db = await DatabaseHelper().database;
    final Map<String, dynamic> updateData = {
      'data_update': DateTime.now().toIso8601String(),
    };

    if (updates != null) updateData.addAll(updates);

    // Se a atualização não explicitar o estado de backup, marcar como não salvo
    // para que a história seja incluída no próximo backup.
    if (!updateData.containsKey('backed_up')) {
      updateData['backed_up'] = 0;
    }

    await db.update(
      'historia',
      updateData,
      where: 'id = ?',
      whereArgs: [historia.id],
    );
    if (!mounted) return;
    final refreshProvider = Provider.of<RefreshProvider>(
      context,
      listen: false,
    );
    refreshProvider.refresh();
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
      final db = await DatabaseHelper().database;
      // Soft delete: marca como excluído ao invés de deletar
      await db.update(
        'historia',
        {
          'excluido': 'sim',
          'data_exclusao': DateTime.now().toIso8601String(),
          'data_update': DateTime.now().toIso8601String(),
          'backed_up': 0,
        },
        where: 'id = ?',
        whereArgs: [historia.id],
      );
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

  Future<void> _archiveWithUndo(Historia historia) async {
    final previousGrupo = historia.grupo;

    // Atualiza o BD diretamente, sem disparar o refresh ainda,
    // para que o Consumer<RefreshProvider> não reconstrua antes do snackbar.
    final db = await DatabaseHelper().database;
    await db.update(
      'historia',
      {
        'arquivado': 'sim',
        'grupo': null,
        'data_update': DateTime.now().toIso8601String(),
        'backed_up': 0,
      },
      where: 'id = ?',
      whereArgs: [historia.id],
    );

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
            await _updateHistoria(
              historia,
              updates: {'arquivado': null, 'grupo': previousGrupo},
            );
          },
        ),
      ),
    );
    // Backup: fecha o snackbar após 5 s sem depender de mounted
    Future.delayed(const Duration(seconds: 5), controller.close);

    // Dispara o refresh no próximo frame, após o snackbar já estar na fila.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<RefreshProvider>(context, listen: false).refresh();
    });
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
          showBottomActions: true,
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
              final selectedGroup = await navigator.push<String>(
                MaterialPageRoute(builder: (_) => const GroupSelectionScreen()),
              );
              if (selectedGroup != null) {
                await _updateHistoria(
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
          final selectedGroup = await Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (_) => const GroupSelectionScreen()),
          );
          if (selectedGroup != null) {
            await _updateHistoria(historia, updates: {'grupo': selectedGroup});
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
          trailing: _buildExpandFab(historia),
          overlayTrailing: true,
          onDoubleTap: () => _openStoryPreview(historia),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _isCardView = widget.isCardView;
    return Consumer<RefreshProvider>(
      builder: (context, refreshProvider, child) {
        // Recarrega dados quando o RefreshProvider é atualizado
        // Usa o refreshCounter como chave para detectar mudanças
        return _PaginatedHomeContent(
          key: ValueKey(refreshProvider.refreshCounter),
          isCardView: _isCardView,
          showChapterShortcutCard: widget.showChapterShortcutCard,
          historias: _historias,
          isInitialLoading: _isInitialLoading,
          isLoadingMore: _isLoadingMore,
          hasMoreData: _hasMoreData,
          scrollController: _scrollController,
          onRefresh: _loadInitialData,
          buildCardView: _buildCardView,
          buildIconView: _buildIconView,
        );
      },
    );
  }
}

class _PaginatedHomeContent extends StatefulWidget {
  final bool isCardView;
  final bool showChapterShortcutCard;
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
    required this.showChapterShortcutCard,
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
  static const String _prefShowIntroOnOpen = 'chapters_show_intro_on_open';

  bool _showChapterIntroOnOpen = true;

  @override
  void initState() {
    super.initState();
    _loadChapterIntroPreference();
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
          // Usa refresh (força recálculo) para garantir dados atualizados
          // após qualquer mutação de histórias
          Provider.of<InsightProvider>(context, listen: false).refresh(userId);
        }
        // Restaura posição do scroll após dados serem carregados
        if (!mounted) return;
        _restoreScrollPositionAfterLoad();
      }
    });
  }

  Future<void> _loadChapterIntroPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getBool(_prefShowIntroOnOpen) ?? true;
      if (!mounted) return;
      setState(() {
        _showChapterIntroOnOpen = value;
      });
    } catch (e) {
      // Mantém o comportamento padrão caso a leitura de preferência falhe.
    }
  }

  Future<void> _openChapters({bool forceIntro = false}) async {
    if (forceIntro) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ChaptersEntryScreen(forceShowIntro: true),
        ),
      );
    } else {
      await Navigator.pushNamed(context, '/chapters');
    }
    if (!mounted) return;
    await _loadChapterIntroPreference();
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
        onRefresh: widget.onRefresh,
        child: Consumer<InsightProvider>(
          builder: (context, insightProvider, _) {
            final insights = insightProvider.insights;
            final storiesCount = widget.historias.length;
            final extraChapterCard = widget.showChapterShortcutCard ? 1 : 0;

            Widget chapterShortcutCard() {
              final l10n = AppLocalizations.of(context)!;
              final premium = context.watch<PremiumProvider>();
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 0,
                clipBehavior: Clip.antiAlias,
                color: const Color(0x00000000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.025),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Icon(
                      premium.canUseChapters
                          ? Icons.auto_stories_rounded
                          : Icons.workspace_premium,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      l10n.chaptersHomeCardTitle,
                      style: GoogleFonts.notoSerif(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_showChapterIntroOnOpen)
                          IconButton(
                            tooltip: l10n.help,
                            onPressed: () => _openChapters(forceIntro: true),
                            icon: const Icon(Icons.help_outline_rounded),
                          ),
                        FilledButton.tonal(
                          onPressed: _openChapters,
                          child: Text(l10n.chapterOpenLabel),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // userId necessário para o callback de dispensa
            final userId =
                Provider.of<AuthProvider>(context, listen: false).user?.id ??
                '';
            final devMode = insightProvider.devMode;
            final hasDevBanner = devMode && insights.isNotEmpty;
            final extraDevBanner = hasDevBanner ? 1 : 0;
            final headerCount =
                extraChapterCard + extraDevBanner + insights.length;

            Widget devModeBanner() {
              final colorScheme = Theme.of(context).colorScheme;
              final l10n = AppLocalizations.of(context)!;
              final currentFilter = insightProvider.tierFilter;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.tertiary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.tertiary.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.developer_mode,
                          size: 14,
                          color: colorScheme.tertiary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.insightDevModeActive,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.4,
                            color: colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Controle de filtro por tier (Free / Premium / Todos)
                    SegmentedButton<InsightTierFilter>(
                      style: SegmentedButton.styleFrom(
                        textStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      segments: InsightTierFilter.values
                          .map(
                            (f) => ButtonSegment<InsightTierFilter>(
                              value: f,
                              label: Text(f.label),
                            ),
                          )
                          .toList(),
                      selected: {currentFilter},
                      onSelectionChanged: (selected) {
                        insightProvider.tierFilter = selected.first;
                      },
                    ),
                    const SizedBox(height: 6),
                    // Botão de acesso rápido ao histórico
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.tertiary,
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.history, size: 14),
                        label: Text(l10n.insightHistoryTitle),
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/insight-history'),
                      ),
                    ),
                  ],
                ),
              );
            }

            /// Constrói um InsightCard com todos os callbacks configurados.
            Widget buildInsightCard(Insight insight) {
              return InsightCard(
                insight: insight,
                onDismiss: () =>
                    insightProvider.dismissInsight(userId, insight.type),
                onPremiumCTA: () =>
                    Navigator.of(context).pushNamed('/settings'),
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
              );
            }

            // Estado verdadeiramente vazio: sem histórias e sem insights.
            if (storiesCount == 0 && insights.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (widget.showChapterShortcutCard) chapterShortcutCard(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/image/home_vazia.png',
                            width: 250,
                            height: 250,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.noStoriesHere,
                            style: GoogleFonts.notoSerif(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.storiesGroupedOrArchived,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            // Lista unificada: capítulo + insights (topo) + histórias (corpo).
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
                // Card de capítulos
                if (widget.showChapterShortcutCard && index == 0) {
                  return chapterShortcutCard();
                }

                // Banner de modo desenvolvimento
                if (hasDevBanner && index == extraChapterCard) {
                  return devModeBanner();
                }

                // Cards de insights no topo (abaixo do card de capítulos)
                if (index < headerCount) {
                  final insightIndex =
                      index - extraChapterCard - extraDevBanner;
                  return buildInsightCard(insights[insightIndex]);
                }

                // Índice no corpo (histórias / mensagem vazia)
                final bodyIndex = index - headerCount;

                // Mensagem de lista vazia quando há insights mas não há histórias
                if (storiesCount == 0) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/image/home_vazia.png',
                            width: 180,
                            height: 180,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!.noStoriesHere,
                            style: GoogleFonts.notoSerif(
                              fontSize: 20,
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
