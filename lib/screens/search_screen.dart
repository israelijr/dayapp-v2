import 'package:dayapp/helpers/route_transition_helper.dart';
import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../db/database_helper.dart';
import '../db/tag_helper.dart';
import '../models/historia.dart';
import '../models/tag.dart';
import '../providers/auth_provider.dart';
import '../providers/refresh_provider.dart';
import '../services/emoji_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/emoji_selection_modal.dart';
import '../widgets/historia_media_widgets.dart';
import '../widgets/rich_text_viewer_widget.dart';
import 'edit_historia_screen.dart';

/// Enum para os tipos de pesquisa disponíveis
enum SearchType {
  text, // Pesquisa por texto no título ou descrição
  tag, // Pesquisa por tag
  emoticon, // Pesquisa por emoticon
}

/// Tela de pesquisa de histórias
class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final SearchType initialSearchType;

  const SearchScreen({
    this.initialQuery,
    this.initialSearchType = SearchType.text,
    super.key,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final EmojiService _emojiService = EmojiService();
  SearchType _currentSearchType = SearchType.text;
  String? _selectedEmoticon; // Emoji caractere selecionado (ex: 😄)
  String? _selectedEmojiTranslation; // Tradução do emoji (ex: Sorrir)
  List<Historia> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  bool _isLoadingEmojis = true;

  @override
  void initState() {
    super.initState();
    _currentSearchType = widget.initialSearchType;
    final initialQuery = widget.initialQuery?.trim() ?? '';
    if (initialQuery.isNotEmpty) {
      _searchController.text = initialQuery;
    }
    _loadEmojis();
    if (initialQuery.isNotEmpty &&
        widget.initialSearchType != SearchType.emoticon) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _performSearch();
      });
    }
  }

  Future<void> _loadEmojis() async {
    await _emojiService.loadEmojis();
    if (mounted) {
      setState(() {
        _isLoadingEmojis = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Executa a pesquisa com base no tipo selecionado
  Future<void> _performSearch() async {
    final loc = AppLocalizations.of(context)!;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id ?? '';

    if (userId.isEmpty) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final db = await DatabaseHelper().database;
      List<Map<String, dynamic>> results;

      switch (_currentSearchType) {
        case SearchType.text:
          final query = _searchController.text.trim();
          if (query.isEmpty) {
            setState(() {
              _searchResults = [];
              _isSearching = false;
            });
            return;
          }
          // Pesquisa no título ou descrição (DISTINCT para evitar duplicatas)
          results = await db.query(
            'historia',
            distinct: true,
            where:
                'user_id = ? AND excluido IS NULL AND (titulo LIKE ? OR descricao LIKE ?)',
            whereArgs: [userId, '%$query%', '%$query%'],
            orderBy: 'data DESC',
          );
          break;

        case SearchType.tag:
          final tag = _searchController.text.trim();
          if (tag.isEmpty) {
            setState(() {
              _searchResults = [];
              _isSearching = false;
            });
            return;
          }
          // Pesquisa por tag usando a nova tabela de relações (busca por slug
          // normalizado para ignorar acentos/capitalização)
          final slug = Tag.generateSlug(tag);
          results = await db.rawQuery(
            '''
            SELECT DISTINCT h.*
            FROM historia h
            INNER JOIN historia_tags ht ON ht.historia_id = h.id
            INNER JOIN tags t ON t.id = ht.tag_id
            WHERE h.user_id = ? AND h.excluido IS NULL
              AND (t.slug LIKE ? OR t.nome LIKE ?)
            ORDER BY h.data DESC
            ''',
            [userId, '%$slug%', '%$tag%'],
          );
          break;

        case SearchType.emoticon:
          if (_selectedEmoticon == null) {
            setState(() {
              _searchResults = [];
              _isSearching = false;
            });
            return;
          }
          // Pesquisa por emoticon
          results = await db.query(
            'historia',
            where: 'user_id = ? AND excluido IS NULL AND emoticon = ?',
            whereArgs: [userId, _selectedEmoticon],
            orderBy: 'data DESC',
          );
          break;
      }

      setState(() {
        _searchResults = results.map((map) => Historia.fromMap(map)).toList();
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.errorSearch(e.toString()))));
      }
    }
  }

  /// Agrupa as histórias por data
  Map<String, List<Historia>> _groupByDate(List<Historia> historias) {
    final Map<String, List<Historia>> grouped = {};

    for (final historia in historias) {
      final dateKey = DateFormat('dd/MM/yyyy', 'pt_BR').format(historia.data);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(historia);
    }

    return grouped;
  }

  /// Limpa a pesquisa
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _selectedEmoticon = null;
      _searchResults = [];
      _hasSearched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.search),
        actions: [
          if (_hasSearched)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: l10n.clearSearchTooltip,
              onPressed: _clearSearch,
            ),
        ],
      ),
      body: Column(
        children: [
          // Área de filtros
          _buildSearchFilters(),
          const Divider(height: 1),
          // Área de resultados
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  /// Constrói a área de filtros de pesquisa
  Widget _buildSearchFilters() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chips para seleção do tipo de pesquisa
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.text_fields, size: 18),
                    const SizedBox(width: 4),
                    Text(l10n.filterText),
                  ],
                ),
                selected: _currentSearchType == SearchType.text,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _currentSearchType = SearchType.text;
                      _selectedEmoticon = null;
                    });
                  }
                },
              ),
              ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.label, size: 18),
                    const SizedBox(width: 4),
                    Text(l10n.filterTag),
                  ],
                ),
                selected: _currentSearchType == SearchType.tag,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _currentSearchType = SearchType.tag;
                      _selectedEmoticon = null;
                    });
                  }
                },
              ),
              ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.mood, size: 18),
                    const SizedBox(width: 4),
                    Text(l10n.filterEmoticon),
                  ],
                ),
                selected: _currentSearchType == SearchType.emoticon,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _currentSearchType = SearchType.emoticon;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Campo de pesquisa ou seleção de emoticon
          if (_currentSearchType == SearchType.emoticon)
            _buildEmoticonSelector()
          else
            _buildTextSearchField(),
        ],
      ),
    );
  }

  /// Campo de pesquisa por texto
  Widget _buildTextSearchField() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: _searchController,
            label: _currentSearchType == SearchType.tag
                ? l10n.searchHintTag
                : l10n.searchHintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _performSearch(),
            textInputAction: TextInputAction.search,
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: _searchController.text.trim().isNotEmpty
              ? _performSearch
              : null,
          child: Text(l10n.searchButton),
        ),
      ],
    );
  }

  /// Abre o modal de seleção de emoji
  Future<void> _openEmojiSelector() async {
    final result = await showModalBottomSheet<Emoji>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0x00000000),
      builder: (context) => const EmojiSelectionModal(),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedEmoticon = result.char;
        _selectedEmojiTranslation = result.translation;
      });
      await _performSearch();
    }
  }

  /// Seletor de emoticons
  Widget _buildEmoticonSelector() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.tapToSelectEmoji,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
            if (_selectedEmoticon != null)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedEmoticon = null;
                    _selectedEmojiTranslation = null;
                    _searchResults = [];
                    _hasSearched = false;
                  });
                },
                icon: const Icon(Icons.clear, size: 18),
                label: Text(l10n.clear),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Botão para abrir seletor de emoji
        InkWell(
          onTap: _isLoadingEmojis ? null : _openEmojiSelector,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _selectedEmoticon != null
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).cardColor,
              border: Border.all(
                color: _selectedEmoticon != null
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
                width: _selectedEmoticon != null ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoadingEmojis)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (_selectedEmoticon != null) ...[
                  Text(
                    _selectedEmoticon!,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedEmojiTranslation ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        l10n.tapToChangeEmoji,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Icon(
                    Icons.add_reaction_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    l10n.selectEmoji,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Constrói a área de resultados
  Widget _buildResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasSearched) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // Calcula o tamanho máximo da imagem baseado em parte da altura disponível
          // Menor fator evita estouro quando também exibimos textos abaixo.
          final maxSize = constraints.maxHeight * 0.5;
          final imageSize = maxSize.clamp(150.0, 400.0);

          return Center(
            // Scroll se, mesmo assim, o conteúdo ultrapassar (ex: teclado em tela pequena)
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: Image.asset(
                      'assets/image/pesquisa_historias.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // mesmos tamanhos e cores usados em home_screen para mensagem vazia
                  Text(
                    AppLocalizations.of(context)!.searchStoriesTitle,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.searchStoriesSubtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    if (_searchResults.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // Calcula o tamanho máximo da imagem baseado no espaço disponível
          final maxSize = constraints.maxHeight * 0.85;
          final imageSize = maxSize.clamp(150.0, 400.0);

          return Center(
            child: Image.asset(
              'assets/image/nao_achou.png',
              width: imageSize,
              height: imageSize,
              fit: BoxFit.contain,
            ),
          );
        },
      );
    }

    // Agrupa resultados por data
    final groupedResults = _groupByDate(_searchResults);
    final sortedDates = groupedResults.keys.toList()
      ..sort((a, b) {
        // Ordena por data decrescente
        final dateA = DateFormat('dd/MM/yyyy', 'pt_BR').parse(a);
        final dateB = DateFormat('dd/MM/yyyy', 'pt_BR').parse(b);
        return dateB.compareTo(dateA);
      });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final historias = groupedResults[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho da data
            _buildDateHeader(dateKey, historias.length),
            // Cards das histórias
            ...historias.map((historia) => _buildHistoriaCard(historia)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  /// Cabeçalho da data (agrupador)
  Widget _buildDateHeader(String dateKey, int count) {
    // Formata a data de forma amigável
    final date = DateFormat('dd/MM/yyyy', 'pt_BR').parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final parsedDate = DateTime(date.year, date.month, date.day);

    final l10n = AppLocalizations.of(context)!;
    String displayDate;
    if (parsedDate == today) {
      displayDate = l10n.today;
    } else if (parsedDate == yesterday) {
      displayDate = l10n.yesterday;
    } else {
      displayDate = DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(date);
      // Capitaliza primeira letra
      displayDate = displayDate[0].toUpperCase() + displayDate.substring(1);
    }

    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 18,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayDate,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Navega para a tela de edição de uma história
  void _editHistoria(Historia historia) {
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
      if (updated == true) {
        _performSearch();
        if (mounted) {
          refreshProvider.refresh();
        }
      }
    });
  }

  /// Atualiza campos de uma história no banco
  Future<void> _updateHistoriaFields(
    Historia historia,
    Map<String, dynamic> updates,
  ) async {
    final db = await DatabaseHelper().database;
    await db.update(
      'historia',
      {
        'data_update': DateTime.now().toIso8601String(),
        'backed_up': 0,
        ...updates,
      },
      where: 'id = ?',
      whereArgs: [historia.id],
    );
  }

  /// Soft delete de uma história (move para lixeira)
  Future<void> _deleteHistoria(Historia historia) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
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
            child: Text(
              l10n.deleteLabel,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _updateHistoriaFields(historia, {
      'excluido': 'sim',
      'data_exclusao': DateTime.now().toIso8601String(),
    });
    if (!mounted) return;
    _performSearch();
    Provider.of<RefreshProvider>(context, listen: false).refresh();
  }

  /// Desagrupa uma história (remove do grupo)
  Future<void> _desagruparHistoria(Historia historia) async {
    final l10n = AppLocalizations.of(context)!;
    await _updateHistoriaFields(historia, {
      'grupo': null,
      'tag': null,
      'arquivado': null,
    });
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.storyUngrouped)));
    _performSearch();
    Provider.of<RefreshProvider>(context, listen: false).refresh();
  }

  /// Desarquiva uma história
  Future<void> _desarquivarHistoria(Historia historia) async {
    final l10n = AppLocalizations.of(context)!;
    await _updateHistoriaFields(historia, {'arquivado': null});
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.unarchive)));
    _performSearch();
    Provider.of<RefreshProvider>(context, listen: false).refresh();
  }

  /// Card de uma história
  Widget _buildHistoriaCard(Historia historia) {
    final l10n = AppLocalizations.of(context)!;
    final temGrupo = historia.grupo != null && historia.grupo!.isNotEmpty;
    final estaArquivado = historia.arquivado != null;

    return GestureDetector(
      onTap: () => _editHistoria(historia),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho: badges de grupo/arquivado + menu de 3 pontos
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges de grupo e arquivado
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (temGrupo)
                          _buildBadge(
                            icon: Icons.folder_outlined,
                            label: historia.grupo!,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.tertiaryContainer,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onTertiaryContainer,
                          ),
                        if (estaArquivado)
                          _buildBadge(
                            icon: Icons.archive_outlined,
                            label: l10n.archivedStateLabel,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                      ],
                    ),
                  ),
                  // Menu de 3 pontos
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.more_vert,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onSelected: (value) async {
                      switch (value) {
                        case 'editar':
                          _editHistoria(historia);
                        case 'desagrupar':
                          await _desagruparHistoria(historia);
                        case 'desarquivar':
                          await _desarquivarHistoria(historia);
                        case 'excluir':
                          await _deleteHistoria(historia);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'editar',
                        child: Row(
                          children: [
                            const Icon(Icons.edit_outlined, size: 20),
                            const SizedBox(width: 12),
                            Text(l10n.edit),
                          ],
                        ),
                      ),
                      if (temGrupo)
                        PopupMenuItem(
                          value: 'desagrupar',
                          child: Row(
                            children: [
                              const Icon(Icons.folder_off_outlined, size: 20),
                              const SizedBox(width: 12),
                              Text(l10n.ungroup),
                            ],
                          ),
                        ),
                      if (estaArquivado)
                        PopupMenuItem(
                          value: 'desarquivar',
                          child: Row(
                            children: [
                              const Icon(Icons.unarchive_outlined, size: 20),
                              const SizedBox(width: 12),
                              Text(l10n.unarchive),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'excluir',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.deleteLabel,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Visualização das fotos com grade e visualizador completo
              HistoriaFotosGrid(historiaId: historia.id ?? 0, height: 120),
              // Áudios e vídeos
              HistoriaMediaRow(
                historiaId: historia.id ?? 0,
                emoticon: historia.emoticon,
              ),

              // Título e emoticon
              Row(
                children: [
                  Expanded(
                    child: Text(
                      historia.titulo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (historia.emoticon != null &&
                      historia.emoticon!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _buildEmoticonWidget(historia.emoticon!),
                  ],
                ],
              ),

              // Tags (novo sistema + legado)
              FutureBuilder<List<Tag>>(
                future: TagHelper().getTagsByHistoria(historia.id ?? 0),
                builder: (context, tagSnapshot) {
                  final newTags = tagSnapshot.data ?? [];
                  final legacyTag = historia.tag;
                  final tagNames = newTags.isNotEmpty
                      ? newTags.map((t) => t.nome).toList()
                      : (legacyTag != null && legacyTag.isNotEmpty
                            ? [legacyTag]
                            : <String>[]);
                  if (tagNames.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: tagNames
                            .map(
                              (name) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  );
                },
              ),

              // Descrição (resumo)
              if (historia.descricao != null &&
                  historia.descricao!.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 48,
                  child: RichTextViewerWidget(jsonContent: historia.descricao),
                ),
              ],

              // Hora
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('HH:mm', 'pt_BR').format(historia.data),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
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

  /// Widget auxiliar para badges de grupo e arquivado
  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foregroundColor),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: foregroundColor)),
        ],
      ),
    );
  }

  /// Widget do emoticon - exibe o emoji Unicode diretamente
  Widget _buildEmoticonWidget(String emoticon) {
    // O emoticon é armazenado como caractere Unicode (ex: 😄)
    return Text(emoticon, style: const TextStyle(fontSize: 28));
  }
}
