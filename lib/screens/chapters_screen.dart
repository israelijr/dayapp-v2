import 'dart:io';

import 'package:animations/animations.dart';
import 'package:dayapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../helpers/chapter_filter_helper.dart';
import '../helpers/rich_text_helper.dart';
import '../models/capitulo.dart';
import '../models/capitulo_sugestao.dart';
import '../models/historia.dart';
import '../providers/auth_provider.dart';
import '../providers/premium_provider.dart';
import '../providers/refresh_provider.dart';
import '../repositories/capitulo_repository.dart';
import '../repositories/historia_repository.dart';
import '../screens/chapter_reader_screen.dart';
import '../screens/edit_historia_screen.dart';
import '../screens/group_selection_screen.dart';
import '../services/capitulo_sugestao_service.dart';
import '../widgets/compact_historia_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/expandable_rich_text_editor.dart';
import '../widgets/rich_text_viewer_widget.dart';
import '../widgets/story_card.dart';

Future<void> openCreateChapterScreen(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final auth = Provider.of<AuthProvider>(context, listen: false);
  final userId = auth.user?.id;
  if (userId == null) return;

  final capituloRepository = CapituloRepository();
  final entradasJaVinculadas = await capituloRepository.getEntradasJaVinculadas(
    userId,
  );
  final entradasComTags = await capituloRepository.listEntradasElegiveisComTags(
    userId,
  );
  if (!context.mounted) return;

  final entradas = entradasComTags
      .map((e) => e.historia)
      .where((h) => h.id != null && !entradasJaVinculadas.contains(h.id))
      .toList();
  final tagNomesPorId = {
    for (final e in entradasComTags)
      if (e.historia.id != null) e.historia.id!: e.tagNomes,
  };

  final resultado = await Navigator.of(context).push<_CreateCapituloResult?>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) =>
          _CreateCapituloPage(entradas: entradas, tagNomesPorId: tagNomesPorId),
    ),
  );

  if (resultado == null) return;

  final selectedEntries =
      entradas
          .where(
            (entry) =>
                entry.id != null && resultado.entradaIds.contains(entry.id),
          )
          .toList()
        ..sort((a, b) => a.data.compareTo(b.data));

  if (selectedEntries.isEmpty) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.chapterMinimumEntries)));
    return;
  }

  final capitulo = Capitulo(
    userId: userId,
    titulo: resultado.titulo,
    descricao: resultado.descricao,
    dataInicio: selectedEntries.first.data,
    dataFim: selectedEntries.last.data,
    criadoAutomaticamente: false,
    fotoPath: resultado.fotoPath,
  );

  await capituloRepository.insertCapituloWithEntradas(
    capitulo,
    selectedEntries.map((entry) => entry.id!).toList(growable: false),
  );

  if (!context.mounted) return;
  Provider.of<RefreshProvider>(context, listen: false).refresh();
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(l10n.chapterCreated)));
}

// ---------------------------------------------------------------------------
// Helpers visuais compartilhados entre as telas de capítulos
// ---------------------------------------------------------------------------

Widget _buildMetaChip({
  required BuildContext context,
  required IconData icon,
  required String label,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSecondaryContainer),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            textStyle: Theme.of(context).textTheme.labelMedium,
            color: colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

Widget _buildMoodBar(BuildContext context, double mood) {
  final colorScheme = Theme.of(context).colorScheme;
  final fraction = ((mood - 1) / 4).clamp(0.0, 1.0);

  final Color barColor;
  if (fraction < 0.33) {
    barColor = colorScheme.error;
  } else if (fraction < 0.66) {
    barColor = colorScheme.tertiary;
  } else {
    barColor = colorScheme.primary;
  }

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        Icons.favorite_border,
        size: 14,
        color: colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: 6),
      SizedBox(
        width: 56,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 7,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ),
    ],
  );
}

class ChaptersScreen extends StatefulWidget {
  const ChaptersScreen({super.key});

  @override
  State<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  final CapituloRepository _capituloRepository = CapituloRepository();
  final CapituloSugestaoService _sugestaoService = CapituloSugestaoService();

  bool _isLoading = true;
  List<CapituloResumo> _capitulos = const [];
  List<CapituloSugestao> _sugestoes = const [];
  String _chapterSearchQuery = '';
  ChapterOriginFilter _chapterOriginFilter = ChapterOriginFilter.all;
  ChapterSortOption _chapterSortOption = ChapterSortOption.newestPeriod;

  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  int _lastRefreshCounter = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final refreshCounter = Provider.of<RefreshProvider>(context).refreshCounter;
    if (_lastRefreshCounter != refreshCounter) {
      _lastRefreshCounter = refreshCounter;
      _loadData();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final premium = Provider.of<PremiumProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId == null || userId.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final capitulos = await _capituloRepository.fetchCapitulosResumoByUser(
      userId,
    );
    final sugestoes = premium.canUseAutoChapterSuggestion
        ? await _sugestaoService.sugerirCapitulos(userId)
        : const <CapituloSugestao>[];

    if (!mounted) return;
    setState(() {
      _capitulos = capitulos;
      _sugestoes = sugestoes;
      _isLoading = false;
    });
  }

  Future<void> _aceitarSugestao(CapituloSugestao sugestao) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId == null) return;

    final capitulo = Capitulo(
      userId: userId,
      titulo: sugestao.tituloSugerido,
      descricao: null,
      dataInicio: sugestao.dataInicio,
      dataFim: sugestao.dataFim,
      scoreConfianca: sugestao.scoreConfianca,
      criadoAutomaticamente: true,
    );

    await _capituloRepository.insertCapituloWithEntradas(
      capitulo,
      sugestao.entradaIds,
    );
    if (!mounted) return;

    setState(() {
      _chapterSearchQuery = '';
      _searchController.clear();
      _showSearch = false;
      _chapterOriginFilter = ChapterOriginFilter.all;
    });

    Provider.of<RefreshProvider>(context, listen: false).refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.chapterCreated)),
    );

    await _loadData();
  }

  Future<void> _ignorarSugestao(CapituloSugestao sugestao) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId == null) return;

    await _capituloRepository.ignoreSuggestion(
      userId: userId,
      fingerprint: sugestao.fingerprint,
      entradaIds: sugestao.entradaIds,
    );

    if (!mounted) return;
    await _loadData();
  }

  Future<void> _criarCapituloManual() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId == null) return;

    final entradasJaVinculadas = await _capituloRepository
        .getEntradasJaVinculadas(userId);
    final entradasComTags = await _capituloRepository
        .listEntradasElegiveisComTags(userId);
    if (!mounted) return;

    final entradas = entradasComTags
        .map((e) => e.historia)
        .where((h) => h.id != null && !entradasJaVinculadas.contains(h.id))
        .toList();
    final tagNomesPorId = {
      for (final e in entradasComTags)
        if (e.historia.id != null) e.historia.id!: e.tagNomes,
    };

    final resultado = await Navigator.of(context).push<_CreateCapituloResult?>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _CreateCapituloPage(
          entradas: entradas,
          tagNomesPorId: tagNomesPorId,
        ),
      ),
    );

    if (resultado == null) return;

    final selectedEntries =
        entradas
            .where(
              (entry) =>
                  entry.id != null && resultado.entradaIds.contains(entry.id),
            )
            .toList()
          ..sort((a, b) => a.data.compareTo(b.data));

    if (selectedEntries.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.chapterMinimumEntries),
        ),
      );
      return;
    }

    final capitulo = Capitulo(
      userId: userId,
      titulo: resultado.titulo,
      descricao: resultado.descricao,
      dataInicio: selectedEntries.first.data,
      dataFim: selectedEntries.last.data,
      criadoAutomaticamente: false,
      fotoPath: resultado.fotoPath,
    );

    await _capituloRepository.insertCapituloWithEntradas(
      capitulo,
      selectedEntries.map((entry) => entry.id!).toList(growable: false),
    );

    if (!mounted) return;
    setState(() {
      _chapterSearchQuery = '';
      _searchController.clear();
      _showSearch = false;
      _chapterOriginFilter = ChapterOriginFilter.all;
    });

    Provider.of<RefreshProvider>(context, listen: false).refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.chapterCreated)),
    );

    await _loadData();
  }

  Widget _buildTagChip(BuildContext context, String tag) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '#$tag',
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildSuggestionWordChip(BuildContext context, String word) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        word,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildSuggestionCard(BuildContext context, CapituloSugestao sugestao) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final periodo = l10n.chapterPeriod(
      DateFormat('dd/MM', l10n.localeName).format(sugestao.dataInicio),
      DateFormat('dd/MM', l10n.localeName).format(sugestao.dataFim),
    );
    final confidenceLabel = '${(sugestao.scoreConfianca * 100).round()}%';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: colorScheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sugestao.tituloSugerido,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          height: 1.25,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        periodo,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildMetaChip(
                  context: context,
                  icon: Icons.menu_book_outlined,
                  label: l10n.chapterEntriesCount(sugestao.entradas.length),
                ),
                _buildMetaChip(
                  context: context,
                  icon: Icons.verified_outlined,
                  label: confidenceLabel,
                ),
                _buildMetaChip(
                  context: context,
                  icon: Icons.bolt_outlined,
                  label: l10n.chapterCreateFromSuggestion,
                ),
              ],
            ),
            if (sugestao.topTags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sugestao.topTags
                    .map((tag) => _buildTagChip(context, tag))
                    .toList(growable: false),
              ),
            ],
            if (sugestao.topPalavras.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sugestao.topPalavras
                    .take(4)
                    .map((word) => _buildSuggestionWordChip(context, word))
                    .toList(growable: false),
              ),
            ],
            if (sugestao.entradas.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ...sugestao.entradas
                        .take(3)
                        .map(
                          (entrada) => CompactHistoriaCard(
                            historia: entrada,
                            localeName: l10n.localeName,
                            stateLabel: entrada.grupo?.isNotEmpty == true
                                ? entrada.grupo
                                : entrada.arquivado != null
                                ? l10n.archivedStateLabel
                                : null,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            showMood: false,
                          ),
                        ),
                    if (sugestao.entradas.length > 3)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                        child: Text(
                          l10n.chapterSuggestionMoreStories(
                            sugestao.entradas.length - 3,
                          ),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: () => _aceitarSugestao(sugestao),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(l10n.chapterCreateFromSuggestion),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _ignorarSugestao(sugestao),
                  icon: const Icon(Icons.close),
                  label: Text(l10n.chapterIgnoreLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapituloCard(BuildContext context, CapituloResumo resumo) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final capitulo = resumo.capitulo;
    final rawDesc = capitulo.descricao?.trim();
    final descricao =
        (rawDesc != null && RichTextHelper.isValidQuillJson(rawDesc))
        ? RichTextHelper.jsonToPlainText(rawDesc).trim()
        : rawDesc;
    final periodo = l10n.chapterPeriod(
      DateFormat('dd/MM/yy', l10n.localeName).format(capitulo.dataInicio),
      DateFormat('dd/MM/yy', l10n.localeName).format(capitulo.dataFim),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: OpenContainer<bool>(
        transitionType: ContainerTransitionType.fadeThrough,
        transitionDuration: const Duration(milliseconds: 400),
        closedElevation: 0,
        closedColor: colorScheme.surface,
        openColor: colorScheme.surface,
        openElevation: 0,
        closedBuilder: (ctx, openContainer) => InkWell(
          onTap: openContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        capitulo.titulo,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          height: 1.25,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Datas
                Text(
                  periodo,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (capitulo.fotoPath != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(capitulo.fotoPath!),
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                      cacheHeight: 480,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 160,
                        color: colorScheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.broken_image,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
                if (descricao != null && descricao.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    descricao,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildMetaChip(
                      context: context,
                      icon: Icons.menu_book_outlined,
                      label: l10n.chapterEntriesCount(resumo.totalEntradas),
                    ),
                    const SizedBox(width: 8),
                    _buildMoodBar(context, resumo.humorMedio),
                  ],
                ),
              ],
            ),
          ),
        ),
        openBuilder: (ctx, _) => _ChapterDetailsScreen(
          resumoInicial: resumo,
          capituloRepository: _capituloRepository,
        ),
        onClosed: (changed) {
          if (changed == true) _loadData();
        },
      ),
    );
  }

  bool _matchesChapterFilter(CapituloResumo resumo) {
    return matchesChapterFilter(
      resumo,
      _chapterSearchQuery,
      _chapterOriginFilter,
    );
  }

  // Menu compacto de ordenação e filtro por origem no AppBar
  Widget _buildSortMenu(BuildContext context, AppLocalizations l10n) {
    String sortLabel(ChapterSortOption opt) => switch (opt) {
      ChapterSortOption.newestPeriod => l10n.chapterSortNewest,
      ChapterSortOption.oldestPeriod => l10n.chapterSortOldest,
      ChapterSortOption.title => l10n.chapterSortTitle,
      ChapterSortOption.stories => l10n.chapterSortStories,
    };

    String filterLabel(ChapterOriginFilter f) => switch (f) {
      ChapterOriginFilter.all => l10n.chapterFilterAll,
      ChapterOriginFilter.automatic => l10n.chapterFilterAutomatic,
      ChapterOriginFilter.manual => l10n.chapterFilterManual,
    };

    final colorScheme = Theme.of(context).colorScheme;
    final hasActiveFilter = _chapterOriginFilter != ChapterOriginFilter.all;

    return PopupMenuButton<Object>(
      tooltip: l10n.chapterSortLabel,
      icon: Badge(
        isLabelVisible: hasActiveFilter,
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.sort),
      ),
      onSelected: (value) {
        if (value is ChapterSortOption) {
          setState(() => _chapterSortOption = value);
        } else if (value is ChapterOriginFilter) {
          setState(() => _chapterOriginFilter = value);
        }
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          enabled: false,
          child: Text(
            l10n.chapterSortLabel,
            style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...ChapterSortOption.values.map(
          (opt) => CheckedPopupMenuItem<Object>(
            value: opt,
            checked: _chapterSortOption == opt,
            child: Text(sortLabel(opt)),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          enabled: false,
          child: Text(
            l10n.chapterFilterAll,
            style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...ChapterOriginFilter.values.map(
          (f) => CheckedPopupMenuItem<Object>(
            value: f,
            checked: _chapterOriginFilter == f,
            child: Text(filterLabel(f)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final premium = context.watch<PremiumProvider>();
    final capitulosFiltrados = sortCapitulos(
      _capitulos.where(_matchesChapterFilter).toList(growable: false),
      _chapterSortOption,
    );

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchHintText,
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _chapterSearchQuery = v),
              )
            : Text(l10n.chaptersTitle),
        actions: [
          if (_showSearch)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: l10n.cancel,
              onPressed: () {
                setState(() {
                  _showSearch = false;
                  _chapterSearchQuery = '';
                  _searchController.clear();
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: l10n.search,
              onPressed: () => setState(() => _showSearch = true),
            ),
          _buildSortMenu(context, l10n),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _criarCapituloManual,
        icon: const Icon(Icons.add),
        label: Text(l10n.chapterCreateManual),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (!premium.isPremium)
                    InkWell(
                      onTap: () => Navigator.of(context).pushNamed('/premium'),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.workspace_premium,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(l10n.chaptersPremiumRequired),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    )
                  else ...[
                    if (_sugestoes.isNotEmpty) ...[
                      Text(
                        l10n.chapterSuggestions,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ..._sugestoes.map(
                        (sugestao) => _buildSuggestionCard(context, sugestao),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                  if (_capitulos.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        l10n.chapterNoItems,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else if (capitulosFiltrados.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        l10n.chapterNoSearchResults,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    ...capitulosFiltrados.map(
                      (resumo) => _buildCapituloCard(context, resumo),
                    ),
                ],
              ),
            ),
    );
  }
}

// Classe auxiliar para retornar dados editados do dialog
class _EditCapituloResult {
  final String titulo;
  final String? descricao;
  final Set<int> entradaIds;
  final String? fotoPath;

  _EditCapituloResult({
    required this.titulo,
    required this.descricao,
    required this.entradaIds,
    this.fotoPath,
  });
}

class _CreateCapituloResult {
  final String titulo;
  final String? descricao;
  final Set<int> entradaIds;
  final String? fotoPath;

  _CreateCapituloResult({
    required this.titulo,
    required this.descricao,
    required this.entradaIds,
    this.fotoPath,
  });
}

class SentenceCapitalizationTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (oldValue.text == newValue.text) {
      return newValue;
    }

    if (newValue.composing.isValid) {
      return newValue;
    }

    String capitalizeText(String text) {
      if (text.isEmpty) return text;

      String result = text;
      if (result.isNotEmpty) {
        result = result[0].toUpperCase() + result.substring(1);
      }

      result = result.replaceAllMapped(
        RegExp(r'([.!?]\s+)([a-z])'),
        (match) => match.group(1)! + match.group(2)!.toUpperCase(),
      );

      result = result.replaceAllMapped(
        RegExp(r'(\n)([a-z])'),
        (match) => match.group(1)! + match.group(2)!.toUpperCase(),
      );

      return result;
    }

    final capitalized = capitalizeText(newValue.text);
    if (capitalized == newValue.text) {
      return newValue;
    }

    return newValue.copyWith(text: capitalized, selection: newValue.selection);
  }
}

// Tela de criação de capítulo (substitui o AlertDialog para evitar
// rebuild de TextField causado por viewInsets no Android)
class _CreateCapituloPage extends StatefulWidget {
  final List<Historia> entradas;
  final Map<int, String> tagNomesPorId;

  const _CreateCapituloPage({
    required this.entradas,
    required this.tagNomesPorId,
  });

  @override
  State<_CreateCapituloPage> createState() => _CreateCapituloPageState();
}

class _CreateCapituloPageState extends State<_CreateCapituloPage> {
  late final TextEditingController titleController;
  late final QuillController richTextController;
  final Set<int> selected = <int>{};
  String? _fotoPath;
  bool _lastFormValid = false;
  bool _lastDraftToConfirmExit = false;

  bool get _isFormValid {
    return titleController.text.trim().isNotEmpty && selected.isNotEmpty;
  }

  bool get _hasDraftToConfirmExit {
    final plainText = richTextController.document.toPlainText().trim();
    return titleController.text.isNotEmpty ||
        plainText.isNotEmpty ||
        selected.isNotEmpty ||
        _fotoPath != null;
  }

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    richTextController = QuillController.basic();
    _lastFormValid = _isFormValid;
    _lastDraftToConfirmExit = _hasDraftToConfirmExit;
    titleController.addListener(_onTextChanged);
    richTextController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final isValid = _isFormValid;
    final hasDraft = _hasDraftToConfirmExit;
    if (isValid != _lastFormValid || hasDraft != _lastDraftToConfirmExit) {
      setState(() {
        _lastFormValid = isValid;
        _lastDraftToConfirmExit = hasDraft;
      });
    }
  }

  @override
  void dispose() {
    titleController.removeListener(_onTextChanged);
    richTextController.removeListener(_onTextChanged);
    titleController.dispose();
    richTextController.dispose();
    super.dispose();
  }

  String _getPeriodo(AppLocalizations l10n) {
    if (selected.isEmpty) return '';
    final selectedEntries =
        widget.entradas
            .where((entry) => entry.id != null && selected.contains(entry.id))
            .toList()
          ..sort((a, b) => a.data.compareTo(b.data));
    if (selectedEntries.isEmpty) return '';
    return l10n.chapterPeriod(
      DateFormat(
        'dd/MM/yy',
        l10n.localeName,
      ).format(selectedEntries.first.data),
      DateFormat('dd/MM/yy', l10n.localeName).format(selectedEntries.last.data),
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (xFile == null) return;

    // Comprime e salva no diretório de documentos
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(appDir.path, 'chapter_photos'));
    if (!await photosDir.exists()) await photosDir.create(recursive: true);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final destPath = p.join(photosDir.path, 'chapter_$timestamp.jpg');

    final compressed = await FlutterImageCompress.compressAndGetFile(
      xFile.path,
      destPath,
      quality: 80,
      minWidth: 800,
      minHeight: 600,
    );

    if (compressed != null && mounted) {
      setState(() => _fotoPath = compressed.path);
    }
  }

  void _showPhotoOptions(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.imagePickerTakePhoto),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.imagePickerGallerySingle),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickPhoto(ImageSource.gallery);
              },
            ),
            if (_fotoPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.chapterRemovePhoto),
                onTap: () {
                  Navigator.of(ctx).pop();
                  setState(() => _fotoPath = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(AppLocalizations l10n) async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.chapterTitleRequired)));
      return;
    }
    if (selected.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.chapterMinimumEntries)));
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId != null) {
      final exists = await CapituloRepository().doesChapterTitleExist(
        userId,
        title,
      );
      if (exists && mounted) {
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.chapterTitleDuplicateTitle),
            content: Text(l10n.chapterTitleDuplicateMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.confirm),
              ),
            ],
          ),
        );
        return;
      }
    }

    final richTextJson = RichTextHelper.controllerToJson(richTextController);
    final plainText = richTextController.document.toPlainText().trim();

    if (!mounted) return;
    Navigator.of(context).pop(
      _CreateCapituloResult(
        titulo: title,
        descricao: plainText.isEmpty ? null : richTextJson,
        entradaIds: {...selected},
        fotoPath: _fotoPath,
      ),
    );
  }

  Future<void> _confirmDiscardChanges(AppLocalizations l10n) async {
    if (!_hasDraftToConfirmExit) {
      Navigator.of(context).pop();
      return;
    }

    final dialogResult = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.discardChangesTitle),
        content: Text(l10n.discardChangesPrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('discard'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.discard),
          ),
          TextButton(
            onPressed: !_isFormValid
                ? null
                : () => Navigator.of(context).pop('save'),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (dialogResult == 'save') {
      await _save(l10n);
    } else if (dialogResult == 'discard') {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final labelColor = isDark
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant;

    final periodoStr = _getPeriodo(l10n);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _confirmDiscardChanges(l10n);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _confirmDiscardChanges(l10n),
          ),
          title: Text(
            l10n.chapterCreateTitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              color: labelColor,
              height: 1.3,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Datas
                      if (periodoStr.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: labelColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              periodoStr,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: labelColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Título
                      CustomTextField(
                        controller: titleController,
                        label: '* ${l10n.chapterTitle}',
                        hintText: l10n.chapterTitleHint,
                        maxLength: 60,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          height: 1.4,
                        ),
                        inputFormatters: [
                          SentenceCapitalizationTextInputFormatter(),
                        ],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Descrição ExpandableRichTextEditor
                      ExpandableRichTextEditor(
                        controller: richTextController,
                        label: l10n.chapterDescription,
                        hintText: l10n.chapterDescriptionHint,
                        expandTooltip: l10n.expandTooltip,
                        onChanged: () {
                          // Chamado a cada digitação para controle de alterações se necessário
                        },
                      ),
                      const SizedBox(height: 16),

                      // Foto selecionada (preview no estilo de fotos de histórias)
                      if (_fotoPath != null) ...[
                        Text(
                          l10n.chapterPhoto,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: labelColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(_fotoPath!),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  cacheWidth: 300,
                                  cacheHeight: 300,
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: IconButton.filled(
                                  onPressed: () =>
                                      setState(() => _fotoPath = null),
                                  icon: const Icon(Icons.close, size: 14),
                                  style: IconButton.styleFrom(
                                    minimumSize: const Size(24, 24),
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Checklist de Entradas
                      Text(
                        l10n.chapterSelectEntries,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: labelColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _EntradasChecklist(
                        entradas: widget.entradas,
                        tagNomesPorId: widget.tagNomesPorId,
                        selected: selected,
                        onSelectionChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                // Toolbar de foto inferior
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton.filledTonal(
                          onPressed: () => _showPhotoOptions(context, l10n),
                          icon: const Icon(Icons.camera_alt_outlined),
                          tooltip: l10n.chapterPhotoActionLabel,
                        ),
                      ],
                    ),
                  ),
                ),

                // Botões inferiores Cancelar/Salvar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _confirmDiscardChanges(l10n),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _isFormValid ? () => _save(l10n) : null,
                          child: Text(l10n.save),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Tela de edição de capítulo (substitui o AlertDialog para evitar
// rebuild de TextField causado por viewInsets no Android)
class _EditCapituloPage extends StatefulWidget {
  final Capitulo capitulo;
  final List<Historia> todasEntradas;
  final Map<int, String> tagNomesPorId;
  final Set<int> initialEntradaIds;

  const _EditCapituloPage({
    required this.capitulo,
    required this.todasEntradas,
    required this.tagNomesPorId,
    required this.initialEntradaIds,
  });

  @override
  State<_EditCapituloPage> createState() => _EditCapituloPageState();
}

class _EditCapituloPageState extends State<_EditCapituloPage> {
  late TextEditingController titleController;
  late QuillController richTextController;
  late final Set<int> selectedIds;
  late final String _initialTitle;
  late final String _initialDescription;
  late final Set<int> _initialSelectedIds;
  String? _initialFotoPath;
  String? _fotoPath;
  bool _lastFormValid = false;
  bool _lastHasUnsavedChanges = false;

  bool get _isFormValid {
    return titleController.text.trim().isNotEmpty && selectedIds.isNotEmpty;
  }

  bool get _hasUnsavedChanges {
    final hasSelectionChanged =
        selectedIds.length != _initialSelectedIds.length ||
        !selectedIds.containsAll(_initialSelectedIds);
    final currentDescription = richTextController.document.toPlainText();
    return titleController.text.trim() != _initialTitle.trim() ||
        currentDescription != _initialDescription ||
        hasSelectionChanged ||
        _fotoPath != _initialFotoPath;
  }

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.capitulo.titulo);
    richTextController = RichTextHelper.smartController(
      widget.capitulo.descricao,
    );
    selectedIds = {...widget.initialEntradaIds};
    _initialTitle = widget.capitulo.titulo;
    _initialDescription = richTextController.document.toPlainText();
    _initialSelectedIds = {...widget.initialEntradaIds};
    final path = widget.capitulo.fotoPath;
    _fotoPath = (path != null && File(path).existsSync()) ? path : null;
    _initialFotoPath = _fotoPath;
    _lastFormValid = _isFormValid;
    _lastHasUnsavedChanges = _hasUnsavedChanges;

    titleController.addListener(_onTextChanged);
    richTextController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final isValid = _isFormValid;
    final hasChanges = _hasUnsavedChanges;
    if (isValid != _lastFormValid || hasChanges != _lastHasUnsavedChanges) {
      setState(() {
        _lastFormValid = isValid;
        _lastHasUnsavedChanges = hasChanges;
      });
    }
  }

  @override
  void dispose() {
    titleController.removeListener(_onTextChanged);
    richTextController.removeListener(_onTextChanged);
    titleController.dispose();
    richTextController.dispose();
    super.dispose();
  }

  String _getPeriodo(AppLocalizations l10n) {
    if (selectedIds.isEmpty) return '';
    final selectedEntries =
        widget.todasEntradas
            .where(
              (entry) => entry.id != null && selectedIds.contains(entry.id),
            )
            .toList()
          ..sort((a, b) => a.data.compareTo(b.data));
    if (selectedEntries.isEmpty) return '';
    return l10n.chapterPeriod(
      DateFormat(
        'dd/MM/yy',
        l10n.localeName,
      ).format(selectedEntries.first.data),
      DateFormat('dd/MM/yy', l10n.localeName).format(selectedEntries.last.data),
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (xFile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(appDir.path, 'chapter_photos'));
    if (!await photosDir.exists()) await photosDir.create(recursive: true);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final destPath = p.join(photosDir.path, 'chapter_$timestamp.jpg');

    final compressed = await FlutterImageCompress.compressAndGetFile(
      xFile.path,
      destPath,
      quality: 80,
      minWidth: 800,
      minHeight: 600,
    );

    if (compressed != null && mounted) {
      setState(() => _fotoPath = compressed.path);
    }
  }

  void _showPhotoOptions(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.imagePickerTakePhoto),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.imagePickerGallerySingle),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickPhoto(ImageSource.gallery);
              },
            ),
            if (_fotoPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.chapterRemovePhoto),
                onTap: () {
                  Navigator.of(ctx).pop();
                  setState(() => _fotoPath = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(AppLocalizations l10n) async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.chapterTitleRequired)));
      return;
    }
    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.chapterMinimumEntries)));
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId != null) {
      final exists = await CapituloRepository().doesChapterTitleExist(
        userId,
        title,
        excludeId: widget.capitulo.id,
      );
      if (exists && mounted) {
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.chapterTitleDuplicateTitle),
            content: Text(l10n.chapterTitleDuplicateMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.confirm),
              ),
            ],
          ),
        );
        return;
      }
    }

    final richTextJson = RichTextHelper.controllerToJson(richTextController);
    final plainText = richTextController.document.toPlainText().trim();

    if (!mounted) return;
    Navigator.of(context).pop(
      _EditCapituloResult(
        titulo: title,
        descricao: plainText.isEmpty ? null : richTextJson,
        entradaIds: {...selectedIds},
        fotoPath: _fotoPath,
      ),
    );
  }

  Future<void> _confirmDiscardChanges(AppLocalizations l10n) async {
    if (!_hasUnsavedChanges) {
      Navigator.of(context).pop();
      return;
    }

    final dialogResult = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.discardChangesTitle),
        content: Text(l10n.discardChangesPrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('discard'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.discard),
          ),
          TextButton(
            onPressed: !_isFormValid
                ? null
                : () => Navigator.of(context).pop('save'),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (dialogResult == 'save') {
      await _save(l10n);
    } else if (dialogResult == 'discard') {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final labelColor = isDark
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant;

    final periodoStr = _getPeriodo(l10n);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _confirmDiscardChanges(l10n);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _confirmDiscardChanges(l10n),
          ),
          title: Text(
            l10n.chapterEditTitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              color: labelColor,
              height: 1.3,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Datas
                      if (periodoStr.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: labelColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              periodoStr,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: labelColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Título
                      CustomTextField(
                        controller: titleController,
                        label: '* ${l10n.chapterTitle}',
                        hintText: l10n.chapterTitleHint,
                        maxLength: 60,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          height: 1.4,
                        ),
                        inputFormatters: [
                          SentenceCapitalizationTextInputFormatter(),
                        ],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Descrição ExpandableRichTextEditor
                      ExpandableRichTextEditor(
                        controller: richTextController,
                        label: l10n.chapterDescription,
                        hintText: l10n.chapterDescriptionHint,
                        expandTooltip: l10n.expandTooltip,
                        onChanged: () {
                          // Chamado a cada digitação para controle de alterações se necessário
                        },
                      ),
                      const SizedBox(height: 16),

                      // Foto selecionada (preview no estilo de fotos de histórias)
                      if (_fotoPath != null) ...[
                        Text(
                          l10n.chapterPhoto,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: labelColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(_fotoPath!),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  cacheWidth: 300,
                                  cacheHeight: 300,
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: IconButton.filled(
                                  onPressed: () =>
                                      setState(() => _fotoPath = null),
                                  icon: const Icon(Icons.close, size: 14),
                                  style: IconButton.styleFrom(
                                    minimumSize: const Size(24, 24),
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Checklist de Entradas
                      Text(
                        l10n.chapterSelectEntries,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: labelColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _EntradasChecklist(
                        entradas: widget.todasEntradas,
                        tagNomesPorId: widget.tagNomesPorId,
                        selected: selectedIds,
                        onSelectionChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                // Toolbar de foto inferior
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton.filledTonal(
                          onPressed: () => _showPhotoOptions(context, l10n),
                          icon: const Icon(Icons.camera_alt_outlined),
                          tooltip: l10n.chapterPhotoActionLabel,
                        ),
                      ],
                    ),
                  ),
                ),

                // Botões inferiores Cancelar/Salvar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _confirmDiscardChanges(l10n),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _isFormValid ? () => _save(l10n) : null,
                          child: Text(l10n.save),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showChapterValidationMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

// Widget isolado para busca + checkboxes de entradas.
// Ao marcar um checkbox ou digitar na busca, apenas este widget é reconstruído,
// evitando que os TextFields de título/descrição percam o foco no Android.
class _EntradasChecklist extends StatefulWidget {
  final List<Historia> entradas;
  final Map<int, String> tagNomesPorId;

  /// Set mutável compartilhado — o pai lê as seleções na hora de salvar.
  final Set<int> selected;
  final ValueChanged<int>? onSelectionChanged;

  const _EntradasChecklist({
    required this.entradas,
    required this.tagNomesPorId,
    required this.selected,
    this.onSelectionChanged,
  });

  @override
  State<_EntradasChecklist> createState() => _EntradasChecklistState();
}

class _EntradasChecklistState extends State<_EntradasChecklist> {
  final TextEditingController _searchController = TextEditingController();
  var _busca = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final buscaNorm = _busca.trim().toLowerCase();
    final filtradas = widget.entradas
        .where((entrada) {
          if (buscaNorm.isEmpty) return true;
          final titulo = entrada.titulo.toLowerCase();
          final data = DateFormat(
            'dd/MM/yyyy',
            l10n.localeName,
          ).format(entrada.data).toLowerCase();
          final assunto = (entrada.assunto ?? '').toLowerCase();
          final tagLegada = (entrada.tag ?? '').toLowerCase();
          final tagNomes = entrada.id != null
              ? (widget.tagNomesPorId[entrada.id!] ?? '').toLowerCase()
              : '';
          return titulo.contains(buscaNorm) ||
              data.contains(buscaNorm) ||
              assunto.contains(buscaNorm) ||
              tagLegada.contains(buscaNorm) ||
              tagNomes.contains(buscaNorm);
        })
        .toList(growable: false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: l10n.search,
            hintText: l10n.searchHintText,
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
          ),
          onChanged: (v) => setState(() => _busca = v),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 250),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: filtradas.length,
            itemBuilder: (context, index) {
              final entry = filtradas[index];
              final id = entry.id;
              if (id == null) return const SizedBox.shrink();
              return CheckboxListTile(
                value: widget.selected.contains(id),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      widget.selected.add(id);
                    } else {
                      widget.selected.remove(id);
                    }
                  });
                  widget.onSelectionChanged?.call(widget.selected.length);
                },
                title: Text(entry.titulo),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy', l10n.localeName).format(entry.data),
                ),
              );
            },
          ),
        ),
        if (filtradas.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            l10n.noStoriesHere,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          l10n.chapterMinimumEntries,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class ChapterDetailsScreen extends StatelessWidget {
  final CapituloResumo resumo;

  const ChapterDetailsScreen({required this.resumo, super.key});

  @override
  Widget build(BuildContext context) {
    return _ChapterDetailsScreen(
      resumoInicial: resumo,
      capituloRepository: CapituloRepository(),
    );
  }
}

class _ChapterDetailsScreen extends StatefulWidget {
  final CapituloResumo resumoInicial;
  final CapituloRepository capituloRepository;

  const _ChapterDetailsScreen({
    required this.resumoInicial,
    required this.capituloRepository,
  });

  @override
  State<_ChapterDetailsScreen> createState() => _ChapterDetailsScreenState();
}

class _ChapterDetailsScreenState extends State<_ChapterDetailsScreen> {
  late CapituloResumo _resumo;
  List<Historia> _entradas = const [];
  bool _isLoading = true;
  bool _didChange = false;
  final HistoriaRepository _historiaRepository = HistoriaRepository();

  @override
  void initState() {
    super.initState();
    _resumo = widget.resumoInicial;
    _loadChapterData();
  }

  Future<void> _loadChapterData() async {
    setState(() {
      _isLoading = true;
    });

    final entradas = await widget.capituloRepository.getEntradasByCapitulo(
      _resumo.capitulo.id!,
    );
    final resumos = await widget.capituloRepository.fetchCapitulosResumoByUser(
      _resumo.capitulo.userId,
    );
    final resumoAtualizado = resumos
        .where((item) => item.capitulo.id == _resumo.capitulo.id)
        .cast<CapituloResumo?>()
        .firstWhere((item) => item != null, orElse: () => null);

    if (!mounted) return;
    setState(() {
      if (resumoAtualizado != null) {
        _resumo = resumoAtualizado;
      }
      _entradas = entradas;
      _isLoading = false;
    });
  }

  Future<void> _editarCapitulo() async {
    final userId = _resumo.capitulo.userId;
    if (userId.isEmpty) return;

    final entradasJaVinculadas = await widget.capituloRepository
        .getEntradasJaVinculadas(userId);
    final entradasComTags = await widget.capituloRepository
        .listEntradasElegiveisComTags(userId);
    if (!mounted) return;

    final draftEntradaIds = <int>{
      for (final e in _entradas)
        if (e.id != null) e.id!,
    };

    final entradasDeOutrosCapitulos = entradasJaVinculadas.difference(
      draftEntradaIds,
    );

    final todasEntradas = entradasComTags
        .map((e) => e.historia)
        .where((h) => h.id != null && !entradasDeOutrosCapitulos.contains(h.id))
        .toList();

    final tagNomesPorId = {
      for (final e in entradasComTags)
        if (e.historia.id != null) e.historia.id!: e.tagNomes,
    };

    final resultado = await Navigator.of(context).push<_EditCapituloResult?>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _EditCapituloPage(
          capitulo: _resumo.capitulo,
          todasEntradas: todasEntradas,
          tagNomesPorId: tagNomesPorId,
          initialEntradaIds: draftEntradaIds,
        ),
      ),
    );

    if (resultado == null) return;

    final selectedEntries =
        todasEntradas
            .where(
              (entry) =>
                  entry.id != null && resultado.entradaIds.contains(entry.id),
            )
            .toList()
          ..sort((a, b) => a.data.compareTo(b.data));

    if (selectedEntries.isEmpty) {
      if (!mounted) return;
      _showChapterValidationMessage(
        context,
        AppLocalizations.of(context)!.chapterMinimumEntries,
      );
      return;
    }

    final capituloAtualizado = Capitulo(
      id: _resumo.capitulo.id,
      userId: userId,
      titulo: resultado.titulo,
      descricao: resultado.descricao,
      dataInicio: selectedEntries.first.data,
      dataFim: selectedEntries.last.data,
      criadoAutomaticamente: _resumo.capitulo.criadoAutomaticamente,
      fotoPath: resultado.fotoPath,
    );

    await widget.capituloRepository.updateCapituloWithEntradas(
      capituloAtualizado,
      selectedEntries.map((entry) => entry.id!).toList(growable: false),
    );

    if (!mounted) return;
    _didChange = true;
    Provider.of<RefreshProvider>(context, listen: false).refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.chapterUpdated)),
    );
    await _loadChapterData();
  }

  Future<void> _excluirCapitulo() async {
    final capituloId = _resumo.capitulo.id;
    if (capituloId == null) return;

    final l10n = AppLocalizations.of(context)!;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.chapterDeleteConfirmTitle),
        content: Text(
          l10n.chapterDeleteConfirmMessage(_resumo.capitulo.titulo),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteLabel),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    await widget.capituloRepository.deleteCapitulo(capituloId);

    if (!mounted) return;
    _didChange = true;
    Provider.of<RefreshProvider>(context, listen: false).refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.chapterDeleted)),
    );
    Navigator.of(context).pop(true);
  }

  void _voltar() {
    Navigator.of(context).pop(_didChange);
  }

  Future<void> _abrirModoLeitura() async {
    final capituloId = _resumo.capitulo.id;
    if (capituloId == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChapterReaderScreen(chapterId: capituloId),
      ),
    );
  }

  Future<void> _reordenarEntradas() async {
    final capituloId = _resumo.capitulo.id;
    if (capituloId == null || _entradas.length < 2) return;

    final orderedEntryIds = await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ChapterEntryReorderSheet(
        entries: _entradas,
        localeName: AppLocalizations.of(context)!.localeName,
      ),
    );

    if (orderedEntryIds == null || orderedEntryIds.isEmpty) {
      return;
    }

    await widget.capituloRepository.updateChapterEntriesOrder(
      capituloId: capituloId,
      orderedEntryIds: orderedEntryIds,
    );

    if (!mounted) return;
    _didChange = true;
    Provider.of<RefreshProvider>(context, listen: false).refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.chapterUpdated)),
    );
    await _loadChapterData();
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
    await _historiaRepository.deleteHistoria(historia);
    if (!mounted) return;
    _didChange = true;
    Provider.of<RefreshProvider>(context, listen: false).refresh();
    await _loadChapterData();
  }

  Future<void> _groupStory(Historia historia) async {
    final selectedGroup = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const GroupSelectionScreen()),
    );

    if (selectedGroup == null) {
      return;
    }

    await _historiaRepository.updateHistoria(
      historia,
      updates: {'grupo': selectedGroup},
    );

    if (!mounted) return;
    _didChange = true;
    Provider.of<RefreshProvider>(context, listen: false).refresh();
    await _loadChapterData();
  }

  Future<void> _archiveWithUndo(Historia historia) async {
    final previousGrupo = historia.grupo;

    await _historiaRepository.archiveHistoria(historia);
    if (!mounted) return;

    _didChange = true;
    Provider.of<RefreshProvider>(context, listen: false).refresh();
    await _loadChapterData();

    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final controller = messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        content: Text(l10n.storyArchived),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () async {
            await _historiaRepository.updateHistoria(
              historia,
              updates: {'arquivado': null, 'grupo': previousGrupo},
            );
            if (!mounted) return;
            _didChange = true;
            Provider.of<RefreshProvider>(context, listen: false).refresh();
            await _loadChapterData();
          },
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 5), controller.close);
  }

  Future<void> _ungroupStory(Historia historia) async {
    await _historiaRepository.updateHistoria(
      historia,
      updates: {'grupo': null},
    );
    if (!mounted) return;
    _didChange = true;
    Provider.of<RefreshProvider>(context, listen: false).refresh();
    await _loadChapterData();
  }

  Future<void> _unarchiveStory(Historia historia) async {
    await _historiaRepository.updateHistoria(
      historia,
      updates: {'arquivado': null},
    );
    if (!mounted) return;
    _didChange = true;
    Provider.of<RefreshProvider>(context, listen: false).refresh();
    await _loadChapterData();
  }

  Future<void> _abrirHistoria(Historia historia) async {
    final action = await Navigator.of(context).push<StoryPreviewAction>(
      MaterialPageRoute(
        builder: (_) => StoryPreviewScreen(
          historia: historia,
          localeName: AppLocalizations.of(context)!.localeName,
          convertLegacyEmoticon: _convertLegacyEmoticon,
          heroTag: 'chapter_story_${historia.id ?? historia.titulo.hashCode}',
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
        MaterialPageRoute(
          builder: (_) => EditHistoriaScreen(historia: historia),
        ),
      );
      if (!mounted) return;
      if (updated == true) {
        _didChange = true;
        Provider.of<RefreshProvider>(context, listen: false).refresh();
        await _loadChapterData();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final capitulo = _resumo.capitulo;
    final periodo = l10n.chapterPeriod(
      DateFormat('dd/MM/yy', l10n.localeName).format(capitulo.dataInicio),
      DateFormat('dd/MM/yy', l10n.localeName).format(capitulo.dataFim),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _voltar();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(capitulo.titulo),
          actions: [
            IconButton(
              tooltip: l10n.chapterSortLabel,
              onPressed: _reordenarEntradas,
              icon: const Icon(Icons.reorder_rounded),
            ),
            IconButton(
              tooltip: l10n.chapterOpenLabel,
              onPressed: _abrirModoLeitura,
              icon: const Icon(Icons.auto_stories_outlined),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  // ---------- Card do cabeçalho ----------
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Imagem ou placeholder colorido
                          if (capitulo.fotoPath != null)
                            Image.file(
                              File(capitulo.fotoPath!),
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              cacheHeight: 600,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: double.infinity,
                                    height: 200,
                                    color: colorScheme.surfaceContainerHighest,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.broken_image,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                            )
                          else
                            Container(
                              width: double.infinity,
                              height: 140,
                              color: capitulo.criadoAutomaticamente
                                  ? colorScheme.tertiaryContainer
                                  : colorScheme.primaryContainer,
                              child: Center(
                                child: Icon(
                                  capitulo.criadoAutomaticamente
                                      ? Icons.auto_awesome
                                      : Icons.bookmark_outline,
                                  size: 56,
                                  color: capitulo.criadoAutomaticamente
                                      ? colorScheme.onTertiaryContainer
                                      : colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  capitulo.titulo,
                                  style: GoogleFonts.plusJakartaSans(
                                    textStyle: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  periodo,
                                  style: GoogleFonts.plusJakartaSans(
                                    textStyle: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildMetaChip(
                                      context: context,
                                      icon: Icons.menu_book_outlined,
                                      label: l10n.chapterEntriesCount(
                                        _resumo.totalEntradas,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildMoodBar(context, _resumo.humorMedio),
                                  ],
                                ),
                                if (capitulo.descricao != null &&
                                    capitulo.descricao!.trim().isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  RichTextHelper.isValidQuillJson(
                                        capitulo.descricao,
                                      )
                                      ? RichTextViewerWidget(
                                          jsonContent: capitulo.descricao,
                                        )
                                      : Text(
                                          capitulo.descricao!.trim(),
                                          style: GoogleFonts.plusJakartaSans(
                                            textStyle: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ---------- Histórias em scroll horizontal ----------
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.chapterEntriesCount(_entradas.length),
                      style: GoogleFonts.plusJakartaSans(
                        textStyle: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_entradas.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.noStoriesHere,
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: Theme.of(context).textTheme.bodyMedium,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 260,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _entradas.length,
                        itemBuilder: (context, index) => _StoryHorizontalCard(
                          historia: _entradas[index],
                          localeName: l10n.localeName,
                          onTap: () => _abrirHistoria(_entradas[index]),
                        ),
                      ),
                    ),
                ],
              ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _voltar,
                  child: Text(l10n.close),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: _editarCapitulo,
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
                  onPressed: _excluirCapitulo,
                  child: Text(l10n.deleteLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Card horizontal para exibição das histórias de um capítulo.
// Carrega tags e contagem de anexos de forma assíncrona.
class _StoryHorizontalCard extends StatefulWidget {
  final Historia historia;
  final String localeName;
  final VoidCallback? onTap;

  const _StoryHorizontalCard({
    required this.historia,
    required this.localeName,
    this.onTap,
  });

  @override
  State<_StoryHorizontalCard> createState() => _StoryHorizontalCardState();
}

class _StoryHorizontalCardState extends State<_StoryHorizontalCard> {
  final HistoriaRepository _historiaRepository = HistoriaRepository();
  List<String> _tagNames = const [];
  int _fotos = 0;
  int _audios = 0;
  int _videos = 0;

  @override
  void initState() {
    super.initState();
    _loadExtras();
  }

  Future<void> _loadExtras() async {
    final id = widget.historia.id;
    if (id == null) return;

    final tags = await _historiaRepository.fetchTagNamesForStory(id);
    final attachmentCounts = await _historiaRepository.fetchAttachmentCounts(
      id,
    );

    final legacyTag = widget.historia.tag;
    final effectiveTags = tags.isNotEmpty ? tags : <String>[];
    if (effectiveTags.isEmpty && legacyTag != null && legacyTag.isNotEmpty) {
      effectiveTags.add(legacyTag);
    }

    if (mounted) {
      setState(() {
        _tagNames = effectiveTags;
        _fotos = attachmentCounts.fotos;
        _audios = attachmentCounts.audios;
        _videos = attachmentCounts.videos;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final historia = widget.historia;
    final colorScheme = Theme.of(context).colorScheme;
    final descricao = RichTextHelper.jsonToPlainText(historia.descricao).trim();
    final hasAttachments = _fotos > 0 || _audios > 0 || _videos > 0;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Data
              Text(
                DateFormat(
                  'dd/MM/yyyy',
                  widget.localeName,
                ).format(historia.data),
                style: GoogleFonts.plusJakartaSans(
                  textStyle: Theme.of(context).textTheme.labelSmall,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              // Título
              Text(
                historia.titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  textStyle: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (descricao.isNotEmpty) ...[
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    descricao,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      textStyle: Theme.of(context).textTheme.bodySmall,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ] else
                const Spacer(),
              // Tags
              if (_tagNames.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: _tagNames
                      .take(3)
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#$tag',
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: Theme.of(context).textTheme.labelSmall,
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
              // Anexos
              if (hasAttachments) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (_fotos > 0) ...[
                      Icon(
                        Icons.image_outlined,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$_fotos',
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: Theme.of(context).textTheme.labelSmall,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (_audios > 0) ...[
                      Icon(
                        Icons.mic_outlined,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$_audios',
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: Theme.of(context).textTheme.labelSmall,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (_videos > 0) ...[
                      Icon(
                        Icons.videocam_outlined,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$_videos',
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: Theme.of(context).textTheme.labelSmall,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ChapterEntryReorderSheet extends StatefulWidget {
  final List<Historia> entries;
  final String localeName;

  const _ChapterEntryReorderSheet({
    required this.entries,
    required this.localeName,
  });

  @override
  State<_ChapterEntryReorderSheet> createState() =>
      _ChapterEntryReorderSheetState();
}

class _ChapterEntryReorderSheetState extends State<_ChapterEntryReorderSheet> {
  late final List<Historia> _draftEntries;

  @override
  void initState() {
    super.initState();
    _draftEntries = List<Historia>.from(widget.entries);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.chapterSortLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.close),
                  ),
                  FilledButton.tonal(
                    onPressed: _save,
                    child: Text(l10n.confirm),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                itemCount: _draftEntries.length,
                onReorder: _onReorder,
                itemBuilder: (context, index) {
                  final historia = _draftEntries[index];
                  final id = historia.id ?? index;

                  return Card(
                    key: ValueKey(id),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(
                        historia.titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        DateFormat(
                          'dd/MM/yyyy',
                          widget.localeName,
                        ).format(historia.data),
                      ),
                      trailing: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_handle_rounded),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final item = _draftEntries.removeAt(oldIndex);
      _draftEntries.insert(newIndex, item);
    });
  }

  void _save() {
    final orderedIds = _draftEntries
        .map((entry) => entry.id)
        .whereType<int>()
        .toList(growable: false);

    Navigator.of(context).pop(orderedIds);
  }
}
