import 'package:dayapp/helpers/route_transition_helper.dart';
import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../db/historia_foto_helper.dart';
import '../models/historia.dart';
import '../providers/auth_provider.dart';
import '../providers/refresh_provider.dart';
import '../repositories/historia_repository.dart';
import '../services/emoji_service.dart';
import '../services/thumbnail_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/emoji_selection_modal.dart';
import '../widgets/story_card.dart';
import 'edit_historia_screen.dart';
import 'group_selection_screen.dart';

/// Enum para os tipos de pesquisa disponíveis
enum SearchType {
  text, // Pesquisa por texto no título ou descrição
  tag, // Pesquisa por tag
  emoticon, // Pesquisa por emoticon
  date, // Pesquisa por período de datas
}

/// Tela de pesquisa de histórias
class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final SearchType initialSearchType;
  final bool showAppBar;

  const SearchScreen({
    this.initialQuery,
    this.initialSearchType = SearchType.text,
    this.showAppBar = true,
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
  DateTime? _startDate; // Data de início do período
  DateTime? _endDate; // Data de fim do período
  List<Historia> _searchResults = [];
  final HistoriaRepository _historiaRepository = HistoriaRepository();
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
        widget.initialSearchType != SearchType.emoticon &&
        widget.initialSearchType != SearchType.date) {
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
    // Fechar o teclado ao clicar no botão pesquisar / disparar busca
    FocusScope.of(context).unfocus();

    final loc = AppLocalizations.of(context)!;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id ?? '';

    if (userId.isEmpty) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final List<Historia> results;

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
          results = await _historiaRepository.searchUserStoriesByText(
            userId: userId,
            query: query,
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
          results = await _historiaRepository.searchUserStoriesByTag(
            userId: userId,
            tag: tag,
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
          results = await _historiaRepository.searchUserStoriesByEmoticon(
            userId: userId,
            emoticon: _selectedEmoticon!,
          );
          break;

        case SearchType.date:
          if (_startDate == null || _endDate == null) {
            setState(() {
              _searchResults = [];
              _isSearching = false;
            });
            return;
          }
          results = await _historiaRepository.searchUserStoriesByDateRange(
            userId: userId,
            startDate: _startDate!,
            endDate: _endDate!,
          );
          break;
      }

      setState(() {
        _searchResults = results;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenTheme = theme.copyWith(
      textTheme: GoogleFonts.plusJakartaSansTextTheme(theme.textTheme),
      primaryTextTheme: GoogleFonts.plusJakartaSansTextTheme(
        theme.primaryTextTheme,
      ),
    );
    return Theme(
      data: screenTheme,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: widget.showAppBar
            ? AppBar(
                elevation: 0,
                scrolledUnderElevation: 0,
                title: Text(
                  l10n.search,
                  style: GoogleFonts.plusJakartaSans(fontSize: 20),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: _buildSearchTypeSelector(),
                    ),
                  ),
                ),
              )
            : null,
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final media = MediaQuery.of(context);
              final availableHeight = constraints.maxHeight > 0
                  ? constraints.maxHeight
                  : (media.size.height -
                        media.viewInsets.bottom -
                        kToolbarHeight -
                        media.padding.top);

              // Define os alvos teóricos
              double minHeightTarget = 80.0;
              final double maxHeightTarget = availableHeight * 0.7;

              // Mecanismo de segurança: Se a tela for muito baixa (como no modo paisagem),
              // garante que o mínimo se ajuste para não ultrapassar o máximo.
              if (minHeightTarget > maxHeightTarget) {
                minHeightTarget = maxHeightTarget;
              }

              final filterMaxHeight = (availableHeight * 0.45).clamp(
                minHeightTarget,
                maxHeightTarget,
              );
              return Column(
                children: [
                  if (!widget.showAppBar) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _buildSearchTypeSelector(),
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: filterMaxHeight),
                    child: SingleChildScrollView(
                      // Força a remoção de paddings automáticos do ListView/ScrollView
                      padding: EdgeInsets.zero,
                      child: _buildSearchFilters(),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(child: _buildResults()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo de pesquisa ou seleção de emoticon ou período
          if (_currentSearchType == SearchType.emoticon)
            _buildEmoticonSelector()
          else if (_currentSearchType == SearchType.date)
            _buildDateRangeSelector()
          else
            _buildTextSearchField(),
        ],
      ),
    );
  }

  void _clearSearchState() {
    _searchController.clear();
    _selectedEmoticon = null;
    _selectedEmojiTranslation = null;
    _startDate = null;
    _endDate = null;
    _searchResults = [];
    _hasSearched = false;
  }

  Widget _buildSearchTypeSelector() {
    final l10n = AppLocalizations.of(context)!;
    IconData icon;
    String label;
    switch (_currentSearchType) {
      case SearchType.text:
        icon = Icons.text_fields;
        label = l10n.filterText;
        break;
      case SearchType.tag:
        icon = Icons.label;
        label = l10n.filterTag;
        break;
      case SearchType.emoticon:
        icon = Icons.mood;
        label = l10n.filterEmoticon;
        break;
      case SearchType.date:
        icon = Icons.calendar_today;
        label = l10n.filterDate;
        break;
    }

    return PopupMenuButton<SearchType>(
      initialValue: _currentSearchType,
      onSelected: (SearchType type) {
        if (_currentSearchType != type) {
          setState(() {
            _currentSearchType = type;
            _clearSearchState();
          });
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: SearchType.text,
          child: Row(
            children: [
              const Icon(Icons.text_fields),
              const SizedBox(width: 8),
              Text(l10n.filterText),
            ],
          ),
        ),
        PopupMenuItem(
          value: SearchType.tag,
          child: Row(
            children: [
              const Icon(Icons.label),
              const SizedBox(width: 8),
              Text(l10n.filterTag),
            ],
          ),
        ),
        PopupMenuItem(
          value: SearchType.emoticon,
          child: Row(
            children: [
              const Icon(Icons.mood),
              const SizedBox(width: 8),
              Text(l10n.filterEmoticon),
            ],
          ),
        ),
        PopupMenuItem(
          value: SearchType.date,
          child: Row(
            children: [
              const Icon(Icons.calendar_today),
              const SizedBox(width: 8),
              Text(l10n.filterDate),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
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
            label: '',
            hintText: _currentSearchType == SearchType.tag
                ? l10n.searchHintTag
                : l10n.searchHintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchResults = [];
                        _hasSearched = false;
                      });
                    },
                  )
                : null,
            onChanged: (value) {
              if (value.trim().isEmpty) {
                setState(() {
                  _searchResults = [];
                  _hasSearched = false;
                });
              } else {
                setState(() {});
              }
            },
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

  Widget _buildEmoticonSelector() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.tapToSelectEmoji,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
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
                icon: const Icon(Icons.clear, size: 16),
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

  Widget _buildDateRangeSelector() {
    final l10n = AppLocalizations.of(context)!;
    final dateRangeSelected = _startDate != null && _endDate != null;

    String displayText = l10n.selectDateRange;
    if (dateRangeSelected) {
      final startStr = DateFormat('dd/MM/yyyy', 'pt_BR').format(_startDate!);
      final endStr = DateFormat('dd/MM/yyyy', 'pt_BR').format(_endDate!);
      displayText = '$startStr - $endStr';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.filterDate,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            if (dateRangeSelected)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                    _searchResults = [];
                    _hasSearched = false;
                  });
                },
                icon: const Icon(Icons.clear, size: 16),
                label: Text(l10n.clear),
              ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _openDateRangePicker,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: dateRangeSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).cardColor,
              border: Border.all(
                color: dateRangeSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
                width: dateRangeSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 32,
                  color: dateRangeSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: dateRangeSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: dateRangeSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (dateRangeSelected) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _performSearch,
              child: Text(l10n.searchButton),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _openDateRangePicker() async {
    final l10n = AppLocalizations.of(context)!;
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      saveText: l10n.searchButton,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      await _performSearch();
    }
  }

  // Constrói a área de resultados
  Widget _buildResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasSearched) {
      return _buildInitialSearchPlaceholder();
    }

    if (_searchResults.isEmpty) {
      return _buildNoResultsPlaceholder();
    }

    // Detecta se estamos em tablet para exibir grade.
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final isTablet = shortestSide >= 600;

    if (isTablet) {
      // Em tablets mostramos uma grade sem agrupamento por data.
      final sorted = List<Historia>.from(_searchResults)
        ..sort((a, b) => b.data.compareTo(a.data));

      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.sizeOf(context).width ~/ 360 == 0
              ? 2
              : (MediaQuery.sizeOf(context).width ~/ 360),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
        ),
        itemCount: sorted.length,
        itemBuilder: (context, index) {
          final historia = sorted[index];
          return _buildHistoriaCard(historia);
        },
      );
    }

    // Em celulares exibimos lista agrupada por data
    final groupedResults = _groupByDate(_searchResults);
    final sortedDates = groupedResults.keys.toList()
      ..sort((a, b) {
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
            _buildDateHeader(dateKey, historias.length),
            ...historias.map((historia) => _buildHistoriaCard(historia)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildInitialSearchPlaceholder() {
    final l10n = AppLocalizations.of(context)!;
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final imageSize = (shortestSide * 0.35).clamp(90.0, 140.0);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/image/pesquisa_historias.png',
                width: imageSize,
                height: imageSize,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.search,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.4),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                l10n.searchStoriesTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.searchStoriesSubtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoResultsPlaceholder() {
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final imageSize = (shortestSide * 0.35).clamp(90.0, 140.0);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Image.asset(
          'assets/image/nao_achou.png',
          width: imageSize,
          height: imageSize,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.search_off_outlined,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.4),
            );
          },
        ),
      ),
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

  /// Atualiza campos de uma história no banco
  Future<void> _updateHistoriaFields(
    Historia historia,
    Map<String, dynamic> updates,
  ) async {
    await _historiaRepository.updateHistoria(
      historia,
      updates: {'backed_up': 0, ...updates},
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

  Future<void> _archiveWithUndo(Historia historia) async {
    final previousGrupo = historia.grupo;
    await _historiaRepository.archiveHistoria(historia);

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
            await _updateHistoriaFields(historia, {
              'arquivado': null,
              'grupo': previousGrupo,
            });
            if (!mounted) return;
            await _performSearch();
          },
        ),
      ),
    );

    await _performSearch();
    Future.delayed(const Duration(seconds: 5), controller.close);
  }

  Future<void> _groupStory(Historia historia) async {
    final selectedGroup = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const GroupSelectionScreen()),
    );

    if (selectedGroup == null) {
      return;
    }

    await _updateHistoriaFields(historia, {'grupo': selectedGroup});

    if (!mounted) return;
    await _performSearch();
  }

  Future<void> _ungroupStory(Historia historia) async {
    await _updateHistoriaFields(historia, {'grupo': null});
    if (!mounted) return;
    await _performSearch();
  }

  Future<void> _unarchiveStory(Historia historia) async {
    await _updateHistoriaFields(historia, {'arquivado': null});
    if (!mounted) return;
    await _performSearch();
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
        _performSearch();
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
      debugPrint('SearchScreen: falha no prewarm de mídia da preview: $e');
    }
  }

  String _storyHeroTag(Historia historia) {
    final id =
        historia.id?.toString() ??
        '${historia.titulo}_${historia.data.millisecondsSinceEpoch}';
    return 'search_story_card_$id';
  }

  /// Card de uma história
  Widget _buildHistoriaCard(Historia historia) {
    return StoryCard(
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
    );
  }
}

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
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
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
                        child: Center(
                          child: Text(
                            dateText,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
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
