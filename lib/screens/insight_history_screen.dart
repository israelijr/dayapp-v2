import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/insight.dart';
import '../providers/auth_provider.dart';
import '../providers/insight_history_provider.dart';
import '../providers/premium_provider.dart';
import '../services/insight_history_service.dart';
import '../widgets/insight_card.dart';

/// Tela que exibe o histórico de insights gerados para o usuário.
class InsightHistoryScreen extends StatefulWidget {
  const InsightHistoryScreen({super.key});

  @override
  State<InsightHistoryScreen> createState() => _InsightHistoryScreenState();
}

class _InsightHistoryScreenState extends State<InsightHistoryScreen> {
  late final InsightHistoryProvider _provider;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _provider = InsightHistoryProvider(InsightHistoryService());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userId =
          Provider.of<AuthProvider>(context, listen: false).user?.id ?? '';
      if (userId.isNotEmpty) {
        _provider.load(userId);
      }
    });

    _searchController.addListener(() {
      _provider.searchQuery = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmClear(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final userId =
        Provider.of<AuthProvider>(context, listen: false).user?.id ?? '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.insightHistoryClearAll),
        content: Text(l10n.insightHistoryClearConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _provider.clearHistory(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isPremiumUser = context
        .watch<PremiumProvider>()
        .isPremium; // Movido para cá para melhor controle de reatividade

    final screenTheme = theme.copyWith(
      textTheme: GoogleFonts.plusJakartaSansTextTheme(theme.textTheme),
      primaryTextTheme: GoogleFonts.plusJakartaSansTextTheme(
        theme.primaryTextTheme,
      ),
    );
    final colorScheme = theme.colorScheme;

    return ChangeNotifierProvider.value(
      value: _provider,
      child: Theme(
        data: screenTheme,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              l10n.insightHistoryTitle,
              style: GoogleFonts.notoSerif(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            actions: [
              Consumer<InsightHistoryProvider>(
                builder: (_, provider, __) {
                  if (provider.entries.isEmpty && !provider.isLoading) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    tooltip: l10n.insightHistoryClearAll,
                    icon: const Icon(Icons.delete_sweep_outlined),
                    onPressed: () => _confirmClear(context),
                  );
                },
              ),
            ],
          ), // <-- PARÊNTESE CORRIGIDO AQUI
          body: Consumer<InsightHistoryProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  // Barra de busca + chips de filtro
                  _buildFilterBar(context, l10n, colorScheme, provider),

                  // Lista agrupada por mês
                  Expanded(
                    child: _buildContent(
                      context,
                      l10n,
                      theme,
                      provider,
                      isPremiumUser, // Passado explicitamente
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    InsightHistoryProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.insightHistorySearch,
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: provider.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _provider.searchQuery = '';
                      },
                    )
                  : null,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SegmentedButton<HistoryTierFilter>(
            style: SegmentedButton.styleFrom(
              textStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            segments: [
              ButtonSegment(
                value: HistoryTierFilter.all,
                label: Text(l10n.insightHistoryFilterAll),
              ),
              ButtonSegment(
                value: HistoryTierFilter.freeOnly,
                label: Text(l10n.insightHistoryFilterFree),
              ),
              ButtonSegment(
                value: HistoryTierFilter.premiumOnly,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.insightHistoryFilterPremium),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.workspace_premium,
                      size: 13,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
            selected: {provider.filter},
            onSelectionChanged: (selected) {
              provider.filter = selected.first;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    InsightHistoryProvider provider,
    bool isPremiumUser,
  ) {
    final groups = provider.groups;

    if (groups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history_outlined,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.insightHistoryEmpty,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final dateFormat = DateFormat.yMd(
      Localizations.localeOf(context).toString(),
    );

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: groups.fold<int>(0, (sum, g) => sum + 1 + g.entries.length),
      itemBuilder: (context, index) {
        int cursor = 0;
        for (final group in groups) {
          if (index == cursor) {
            return _buildGroupHeader(context, theme, group.label);
          }
          cursor++;
          if (index < cursor + group.entries.length) {
            final entry = group.entries[index - cursor];
            return _buildEntryCard(
              context,
              l10n,
              entry,
              isPremiumUser,
              dateFormat,
            );
          }
          cursor += group.entries.length;
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildGroupHeader(
    BuildContext context,
    ThemeData theme,
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEntryCard(
    BuildContext context,
    AppLocalizations l10n,
    InsightHistoryEntry entry,
    bool isPremiumUser,
    DateFormat dateFormat,
  ) {
    final insight = Insight(
      type: entry.type,
      title: entry.title,
      description: entry.description,
      icon: entry.icon,
      metadata: entry.metadata,
    );

    final dateLabel = l10n.insightHistorySeenOn(
      dateFormat.format(entry.seenAt),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InsightCard(insight: insight),
        Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 4),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              dateLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
