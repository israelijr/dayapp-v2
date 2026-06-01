import 'dart:io';

import 'package:animations/animations.dart';
import 'package:dayapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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
import '../services/capitulo_sugestao_service.dart';
import '../widgets/compact_historia_card.dart';
import '../widgets/historia_media_widgets.dart';
import '../widgets/rich_text_viewer_widget.dart';

Future<void> openCreateChapterScreen(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final auth = Provider.of<AuthProvider>(context, listen: false);
  final userId = auth.user?.id;
  if (userId == null) return;

  final capituloRepository = CapituloRepository();
  final entradasComTags = await capituloRepository.listEntradasElegiveisComTags(
    userId,
  );
  if (!context.mounted) return;

  final entradas = entradasComTags.map((e) => e.historia).toList();
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

  if (selectedEntries.length < 3) {
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

  @override
  void initState() {
    super.initState();
    _loadData();
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
    final sugestoes = premium.isPremium
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
    );

    if (!mounted) return;
    await _loadData();
  }

  Future<void> _criarCapituloManual() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId == null) return;

    final entradasComTags = await _capituloRepository
        .listEntradasElegiveisComTags(userId);
    if (!mounted) return;

    final entradas = entradasComTags.map((e) => e.historia).toList();
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

    if (selectedEntries.length < 3) {
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
                        style: GoogleFonts.notoSerif(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
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
    final descricao = capitulo.descricao?.trim();
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
                        style: GoogleFonts.notoSerif(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
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
                    Card(
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
                            Expanded(child: Text(l10n.chaptersPremiumRequired)),
                          ],
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
  late final TextEditingController descriptionController;
  final Set<int> selected = <int>{};
  String? _fotoPath;

  bool get _hasDraftToConfirmExit =>
      titleController.text.trim().isNotEmpty &&
      descriptionController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
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

  void _save(AppLocalizations l10n) {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.chapterTitleRequired)));
      return;
    }
    if (selected.length < 3) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.chapterMinimumEntries)));
      return;
    }
    Navigator.of(context).pop(
      _CreateCapituloResult(
        titulo: titleController.text.trim(),
        descricao: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
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
            onPressed: () => Navigator.of(context).pop('save'),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (dialogResult == 'save') {
      _save(l10n);
    } else if (dialogResult == 'discard') {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
          title: Text(l10n.chapterCreateTitle),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_fotoPath != null) ...[
                  SizedBox(
                    width: 92,
                    height: 72,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 92,
                            height: 72,
                            child: Image.file(
                              File(_fotoPath!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                WidgetsBinding.instance.addPostFrameCallback(
                                  (_) => setState(() => _fotoPath = null),
                                );
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: IconButton.filled(
                            onPressed: () => setState(() => _fotoPath = null),
                            icon: const Icon(Icons.close, size: 14),
                            tooltip: l10n.chapterRemovePhoto,
                            style: IconButton.styleFrom(
                              minimumSize: const Size(24, 24),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  l10n.chapterTitle,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: titleController,
                  textCapitalization: TextCapitalization.sentences,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: l10n.chapterTitleHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.chapterDescription,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 2,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: l10n.chapterDescriptionHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.chapterSelectEntries,
                  style: Theme.of(context).textTheme.titleSmall,
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
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showPhotoOptions(context, l10n),
                    child: Text(l10n.chapterPhotoActionLabel),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: selected.length >= 3 ? () => _save(l10n) : null,
                    child: Text(l10n.save),
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
  late TextEditingController descController;
  late final Set<int> selectedIds;
  late final String _initialTitle;
  late final String _initialDescription;
  late final Set<int> _initialSelectedIds;
  String? _initialFotoPath;
  String? _fotoPath;

  bool get _hasUnsavedChanges {
    final hasSelectionChanged =
        selectedIds.length != _initialSelectedIds.length ||
        !selectedIds.containsAll(_initialSelectedIds);
    return titleController.text.trim() != _initialTitle.trim() ||
        descController.text.trim() != _initialDescription.trim() ||
        hasSelectionChanged ||
        _fotoPath != _initialFotoPath;
  }

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.capitulo.titulo);
    descController = TextEditingController(
      text: widget.capitulo.descricao ?? '',
    );
    selectedIds = {...widget.initialEntradaIds};
    _initialTitle = widget.capitulo.titulo;
    _initialDescription = widget.capitulo.descricao ?? '';
    _initialSelectedIds = {...widget.initialEntradaIds};
    // Valida se o arquivo ainda existe antes de usar
    final path = widget.capitulo.fotoPath;
    _fotoPath = (path != null && File(path).existsSync()) ? path : null;
    _initialFotoPath = _fotoPath;
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
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

  void _save(AppLocalizations l10n) {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.chapterTitleRequired)));
      return;
    }
    if (selectedIds.length < 3) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.chapterMinimumEntries)));
      return;
    }
    Navigator.of(context).pop(
      _EditCapituloResult(
        titulo: titleController.text.trim(),
        descricao: descController.text.trim().isEmpty
            ? null
            : descController.text.trim(),
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
            onPressed: () => Navigator.of(context).pop('save'),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (dialogResult == 'save') {
      _save(l10n);
    } else if (dialogResult == 'discard') {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
          title: Text(l10n.chapterEditTitle),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_fotoPath != null) ...[
                  SizedBox(
                    width: 92,
                    height: 72,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 92,
                            height: 72,
                            child: Image.file(
                              File(_fotoPath!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                WidgetsBinding.instance.addPostFrameCallback(
                                  (_) => setState(() => _fotoPath = null),
                                );
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: IconButton.filled(
                            onPressed: () => setState(() => _fotoPath = null),
                            icon: const Icon(Icons.close, size: 14),
                            tooltip: l10n.chapterRemovePhoto,
                            style: IconButton.styleFrom(
                              minimumSize: const Size(24, 24),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  l10n.chapterTitle,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: l10n.chapterTitleHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.chapterDescription,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: descController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 2,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: l10n.chapterDescriptionHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.chapterSelectEntries,
                  style: Theme.of(context).textTheme.titleSmall,
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
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showPhotoOptions(context, l10n),
                    child: Text(l10n.chapterPhotoActionLabel),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: selectedIds.length >= 3
                        ? () => _save(l10n)
                        : null,
                    child: Text(l10n.save),
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

    final entradasComTags = await widget.capituloRepository
        .listEntradasElegiveisComTags(userId);
    if (!mounted) return;

    final todasEntradas = entradasComTags.map((e) => e.historia).toList();
    final tagNomesPorId = {
      for (final e in entradasComTags)
        if (e.historia.id != null) e.historia.id!: e.tagNomes,
    };

    final draftEntradaIds = <int>{
      for (final e in _entradas)
        if (e.id != null) e.id!,
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

    if (selectedEntries.length < 3) {
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.chapterDeleted)),
    );
    Navigator.of(context).pop(true);
  }

  void _voltar() {
    Navigator.of(context).pop(_didChange);
  }

  void _abrirHistoria(Historia historia) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (ctx, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle do modal
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Conteúdo da história
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fotos
                      HistoriaFotosGrid(
                        historiaId: historia.id ?? 0,
                        height: 200,
                      ),
                      // Mídia (áudios e vídeos)
                      HistoriaMediaRow(
                        historiaId: historia.id ?? 0,
                        emoticon: historia.emoticon,
                      ),
                      const SizedBox(height: 8),
                      // Título
                      Text(
                        historia.titulo,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Data
                      Text(
                        DateFormat(
                          'dd/MM/yyyy',
                          AppLocalizations.of(context)!.localeName,
                        ).format(historia.data),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      // Descrição (Rich Text)
                      if (historia.descricao != null &&
                          historia.descricao!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        RichTextViewerWidget(jsonContent: historia.descricao),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                                  style: GoogleFonts.notoSerif(
                                    textStyle: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                    fontWeight: FontWeight.w600,
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
                                  Text(
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
                      style: GoogleFonts.notoSerif(
                        textStyle: Theme.of(context).textTheme.titleMedium,
                        fontWeight: FontWeight.w600,
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
                style: GoogleFonts.notoSerif(
                  textStyle: Theme.of(context).textTheme.titleSmall,
                  fontWeight: FontWeight.w600,
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
