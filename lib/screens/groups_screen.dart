import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/capitulo_helper.dart';
import '../db/grupo_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/capitulo.dart';
import '../models/capitulo_sugestao.dart';
import '../models/grupo.dart';
import '../providers/auth_provider.dart';
import '../providers/chapter_filter_provider.dart';
import '../providers/premium_provider.dart';
import '../providers/refresh_provider.dart';
import '../services/capitulo_sugestao_service.dart';
import '../widgets/chapter_book_widget.dart';
import 'archived_stories_screen.dart';
import 'chapters_screen.dart';
import 'group_stories_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key, this.onTabChanged});

  final ValueChanged<int>? onTabChanged;

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen>
    with TickerProviderStateMixin {
  final CapituloHelper _capituloHelper = CapituloHelper();
  final CapituloSugestaoService _sugestaoService = CapituloSugestaoService();
  late final TabController _tabController;

  List<Grupo> _grupos = [];
  Map<String, int> _grupoCounts = {};
  List<CapituloResumo> _capitulos = [];
  List<CapituloSugestao> _sugestoes = const [];
  bool _isLoading = true;
  int _lastRefreshCounter = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onTabChanged?.call(_tabController.index);
    });
    _loadCollections();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final refreshCounter = Provider.of<RefreshProvider>(context).refreshCounter;
    if (_lastRefreshCounter != refreshCounter) {
      _lastRefreshCounter = refreshCounter;
      _loadCollections();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      widget.onTabChanged?.call(_tabController.index);
    }
  }

  Future<void> _loadCollections({bool forceRefresh = false}) async {
    final showSpinner = (_grupos.isEmpty && _capitulos.isEmpty) || forceRefresh;
    if (showSpinner) {
      setState(() => _isLoading = true);
    }
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userId = auth.user?.id;
      if (userId != null) {
        final grupoHelper = GrupoHelper();

        final premium = Provider.of<PremiumProvider>(context, listen: false);
        final todosGrupos = await grupoHelper.getGruposByUser(userId);
        final capitulos = await _capituloHelper.getCapitulosResumoByUser(
          userId,
        );
        final sugestoes = premium.isPremium
            ? await _sugestaoService.sugerirCapitulos(userId)
            : const <CapituloSugestao>[];

        final gruposComHistorias = <Grupo>[];
        final counts = <String, int>{};

        for (final grupo in todosGrupos) {
          final count = await grupoHelper.countHistoriasInGrupo(
            userId,
            grupo.nome,
          );
          if (count > 0) {
            gruposComHistorias.add(grupo);
            counts[grupo.nome] = count;
          }
        }

        if (!mounted) return;
        gruposComHistorias.sort(
          (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
        );
        setState(() {
          _grupos = gruposComHistorias;
          _grupoCounts = counts;
          _capitulos = capitulos;
          _sugestoes = sugestoes;
        });
      }
    } finally {
      if (mounted && showSpinner) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handlePullToRefresh() async {
    await _loadCollections(forceRefresh: true);
  }

  Future<void> _navigateAndRefresh(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _loadCollections();
  }

  Future<void> _openChapter(CapituloResumo resumo) async {
    await _navigateAndRefresh(ChapterDetailsScreen(resumo: resumo));
  }

  List<CapituloResumo> _getDisplayChapters(ChapterFilterProvider filter) {
    final List<CapituloResumo> sortedList = List.from(_capitulos);

    // Ordenação
    if (filter.sortOrder == 'date') {
      sortedList.sort((a, b) {
        final dateA = a.capitulo.dataUpdate ?? a.capitulo.dataInicio;
        final dateB = b.capitulo.dataUpdate ?? b.capitulo.dataInicio;
        return dateB.compareTo(dateA); // Mais recentes primeiro
      });
    } else {
      sortedList.sort(
        (a, b) => a.capitulo.titulo.toLowerCase().compareTo(
          b.capitulo.titulo.toLowerCase(),
        ),
      );
    }

    // Limite
    if (filter.itemLimit != null) {
      return sortedList.take(filter.itemLimit!).toList();
    }
    return sortedList;
  }

  Widget _buildSuggestionBanner(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final suggestion = _sugestoes.first;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.chapterSuggestions,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.chapterSuggestionMoreStories(
                        suggestion.entradas.length,
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () => _navigateAndRefresh(const ChaptersScreen()),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer,
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                ),
                child: Text(l10n.chapterViewSuggestions),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupsTab(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _grupos.length + 1,
      itemBuilder: (context, index) {
        if (index == _grupos.length) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ArchivedStoriesScreen(),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer.withValues(alpha: 0.24),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.18),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.archive,
                      size: 42,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.archivedTitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.archivedTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final grupo = _grupos[index];
        final count = _grupoCounts[grupo.nome] ?? 0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () => _navigateAndRefresh(GroupStoriesScreen(grupo: grupo)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.24),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.18),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    grupo.emoticon ?? '📁',
                    style: TextStyle(
                      fontSize: 42,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  grupo.nome,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color:
                        Theme.of(context).appBarTheme.foregroundColor ??
                        Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$count ${count == 1 ? l10n.record : l10n.records}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TabBar(
                      controller: _tabController,
                      // dividerColor: Colors.transparent,
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant,
                      labelStyle: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                      unselectedLabelStyle: Theme.of(
                        context,
                      ).textTheme.bodyMedium,
                      indicator: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3,
                          ),
                        ),
                      ),
                      indicatorPadding: EdgeInsets.zero,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: [
                        Tab(text: l10n.chaptersTitle),
                        Tab(text: l10n.groupsTabLabel),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        RefreshIndicator(
                          onRefresh: _handlePullToRefresh,
                          child: Consumer<ChapterFilterProvider>(
                            builder: (context, filter, child) {
                              final displayChapters = _getDisplayChapters(
                                filter,
                              );
                              return _capitulos.isEmpty
                                  ? ListView(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 24,
                                        horizontal: 16,
                                      ),
                                      children: [
                                        if (_sugestoes.isNotEmpty)
                                          _buildSuggestionBanner(context),
                                        Center(
                                          child: Text(l10n.chapterNoItems),
                                        ),
                                      ],
                                    )
                                  : GridView.builder(
                                      padding: const EdgeInsets.all(16),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 16,
                                            childAspectRatio: 0.85,
                                          ),
                                      itemCount:
                                          displayChapters.length +
                                          (_sugestoes.isNotEmpty ? 1 : 0),
                                      itemBuilder: (context, index) {
                                        if (_sugestoes.isNotEmpty &&
                                            index == 0) {
                                          return _buildSuggestionBanner(
                                            context,
                                          );
                                        }
                                        final chapterIndex =
                                            _sugestoes.isNotEmpty
                                            ? index - 1
                                            : index;

                                        if (chapterIndex >=
                                            displayChapters.length) {
                                          return const SizedBox.shrink();
                                        }

                                        final resumo =
                                            displayChapters[chapterIndex];
                                        final List<String> capas = [
                                          'assets/image/capa1.jpg',
                                          'assets/image/capa2.jpeg',
                                          'assets/image/capa3.jpeg',
                                          'assets/image/capa4.jpeg',
                                          'assets/image/capa5.jpg',
                                        ];
                                        final randomIdx =
                                            (resumo.capitulo.id ??
                                                    resumo
                                                        .capitulo
                                                        .titulo
                                                        .hashCode)
                                                .abs() %
                                            capas.length;

                                        return ChapterBookWidget(
                                          titulo: resumo.capitulo.titulo,
                                          dataUpdate:
                                              resumo.capitulo.dataUpdate ??
                                              resumo.capitulo.dataInicio,
                                          fotoPath: resumo.capitulo.fotoPath,
                                          coverAsset: capas[randomIdx],
                                          onTap: () => _openChapter(resumo),
                                        );
                                      },
                                    );
                            },
                          ),
                        ),
                        RefreshIndicator(
                          onRefresh: _handlePullToRefresh,
                          child: _grupos.isEmpty
                              ? ListView(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                    horizontal: 16,
                                  ),
                                  children: [
                                    Center(child: Text(l10n.noGroupsFound)),
                                  ],
                                )
                              : _buildGroupsTab(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
