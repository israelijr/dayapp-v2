import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../db/capitulo_helper.dart';
import '../db/grupo_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/capitulo.dart';
import '../models/grupo.dart';
import '../providers/auth_provider.dart';
import 'chapters_screen.dart';
import 'group_stories_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final CapituloHelper _capituloHelper = CapituloHelper();

  List<Grupo> _grupos = [];
  Map<String, int> _grupoCounts = {};
  List<CapituloResumo> _capitulos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userId = auth.user?.id;
      if (userId != null) {
        final grupoHelper = GrupoHelper();

        final todosGrupos = await grupoHelper.getGruposByUser(userId);
        final capitulos = await _capituloHelper.getCapitulosResumoByUser(
          userId,
        );

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
        setState(() {
          _grupos = gruposComHistorias;
          _grupoCounts = counts;
          _capitulos = capitulos;
        });
      }
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateAndRefresh(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _loadCollections();
  }

  Widget _buildChapterCard(BuildContext context, CapituloResumo resumo) {
    final l10n = AppLocalizations.of(context)!;
    final capitulo = resumo.capitulo;
    final period =
        '${DateFormat('dd/MM/yy', l10n.localeName).format(capitulo.dataInicio)} - ${DateFormat('dd/MM/yy', l10n.localeName).format(capitulo.dataFim)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: InkWell(
        onTap: () => _navigateAndRefresh(const ChaptersScreen()),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.03),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                capitulo.titulo,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                period,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (capitulo.descricao != null &&
                  capitulo.descricao!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  capitulo.descricao!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.chapterEntriesCount(resumo.totalEntradas),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (resumo.topTags.isNotEmpty)
                    ...resumo.topTags.map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupsTab(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_grupos.isEmpty) {
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        children: [
          Center(
            child: Text(
              l10n.noGroupsFound,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.78,
      ),
      itemCount: _grupos.length,
      itemBuilder: (context, index) {
        final grupo = _grupos[index];
        final count = _grupoCounts[grupo.nome] ?? 0;

        return InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => _navigateAndRefresh(GroupStoriesScreen(grupo: grupo)),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    grupo.emoticon ?? '📁',
                    style: TextStyle(
                      fontSize: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: Text(
                    grupo.nome,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
                    child: Text(
                      l10n.collectionsSubtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TabBar(
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant,
                      labelStyle: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                      unselectedLabelStyle: Theme.of(
                        context,
                      ).textTheme.bodyMedium,
                      indicatorColor: Theme.of(context).colorScheme.primary,
                      indicatorWeight: 3,
                      tabs: [
                        Tab(text: l10n.chaptersTitle),
                        Tab(text: l10n.groupsTabLabel),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  Expanded(
                    child: TabBarView(
                      children: [
                        RefreshIndicator(
                          onRefresh: _loadCollections,
                          child: _capitulos.isEmpty
                              ? ListView(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                    horizontal: 16,
                                  ),
                                  children: [
                                    Center(child: Text(l10n.chapterNoItems)),
                                  ],
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    16,
                                    16,
                                    16,
                                  ),
                                  itemCount: _capitulos.length,
                                  itemBuilder: (context, index) =>
                                      _buildChapterCard(
                                        context,
                                        _capitulos[index],
                                      ),
                                ),
                        ),
                        RefreshIndicator(
                          onRefresh: _loadCollections,
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
