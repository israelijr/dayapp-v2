import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../providers/premium_provider.dart';
import '../theme/m3_expressive_theme.dart';

/// Tela oculta para simular Free/Premium durante o desenvolvimento.
///
/// **Acesso:** toque 7 vezes na versão nas Configurações (easter egg).
class PremiumDebugScreen extends StatelessWidget {
  const PremiumDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.premiumDebugTitle),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PremiumProvider>(
        builder: (context, premium, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ------------------------------------------------------------------
              // Aviso de ambiente
              // ------------------------------------------------------------------
              Card(
                color: Colors.amber.shade100,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.premiumDebugWarning,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.labelColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ------------------------------------------------------------------
              // Status atual do plano
              // ------------------------------------------------------------------
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.currentPlan,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _PlanBadge(isPremium: premium.isPremium),
                      const SizedBox(height: 8),
                      Text(
                        l10n.premiumDebugStatus(
                          premium.isPremium ? l10n.premiumPlan : l10n.freePlan,
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.labelColor(context),
                        ),
                      ),
                      Text(
                        l10n.premiumDebugSource(
                          premium.premiumSource ?? l10n.premiumDebugNoSource,
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ------------------------------------------------------------------
              // Botão de toggle
              // ------------------------------------------------------------------
              FilledButton.icon(
                onPressed: () => premium.debugToggle(),
                icon: Icon(
                  premium.isPremium ? Icons.lock_open : Icons.workspace_premium,
                ),
                label: Text(
                  premium.isPremium
                      ? l10n.premiumDebugDeactivate
                      : l10n.premiumDebugActivate,
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  backgroundColor: premium.isPremium
                      ? Colors.red.shade700
                      : Colors.deepPurple,
                ),
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------------------------
              // Lista de features por plano
              // ------------------------------------------------------------------
              Text(
                l10n.premiumDebugFeatures,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _FeatureRow(
                label: l10n.automaticBackup,
                enabled: premium.canUseAutomaticBackup,
                plan: l10n.premiumPlan,
              ),
              _FeatureRow(
                label: l10n.insightMonthlySummary,
                enabled: premium.canViewAdvancedInsights,
                plan: l10n.premiumPlan,
              ),
              _FeatureRow(
                label: l10n.theme,
                enabled: premium.canUsePremiumThemes,
                plan: l10n.premiumPlan,
              ),
              _FeatureRow(
                label: l10n.share,
                enabled: premium.canShareStory,
                plan: l10n.premiumPlan,
              ),
              _FeatureRow(
                label: l10n.exportPdf,
                enabled: premium.canShareChapter,
                plan: l10n.premiumPlan,
              ),
              _FeatureRow(
                label: l10n.chapterSuggestions,
                enabled: premium.canUseAutoChapterSuggestion,
                plan: l10n.premiumPlan,
              ),
              _FeatureRow(
                label: l10n.insightMonthlySummary,
                enabled: premium.canViewMonthlyInsight,
                plan: l10n.premiumPlan,
              ),
              _FeatureRow(
                label: 'Mood 7 Days Chart',
                enabled: premium.canView7DayMoodInsight,
                plan: l10n.premiumPlan,
              ),
              // Adicione novas features aqui conforme forem sendo criadas.
              // Exemplo futuro:
              // _FeatureRow(
              //   label: l10n.someFutureFeature,
              //   enabled: premium.canUseCloudSync,
              //   plan: l10n.premiumPlan,
              // ),
            ],
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Widgets auxiliares internos
// -----------------------------------------------------------------------------

class _PlanBadge extends StatelessWidget {
  final bool isPremium;
  const _PlanBadge({required this.isPremium});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isPremium ? Colors.deepPurple : Colors.grey.shade300,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPremium ? Icons.workspace_premium : Icons.person_outline,
            size: 16,
            color: isPremium ? Colors.white : Colors.black54,
          ),
          const SizedBox(width: 4),
          Text(
            isPremium ? l10n.premiumPlan : l10n.freePlan,
            style: TextStyle(
              color: isPremium ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String label;
  final bool enabled;
  final String plan;

  const _FeatureRow({
    required this.label,
    required this.enabled,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel_outlined,
            size: 20,
            color: enabled ? Colors.green : colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.labelColor(context),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: colorScheme.primary.withValues(alpha: 0.12),
            ),
            child: Text(
              plan,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
