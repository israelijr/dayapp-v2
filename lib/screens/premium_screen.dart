import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../providers/premium_provider.dart';
import '../services/purchase_service.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final premium = context.watch<PremiumProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: colorScheme.primary,
            iconTheme: IconThemeData(
              color: colorScheme.onPrimary,
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                loc.premiumScreenTitle,
                style: GoogleFonts.plusJakartaSans(
                  color: colorScheme.onPrimary,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.tertiary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Image.asset(
                            'assets/image/LogoDayApp.png',
                            height: 70,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 48), // Espaço para o título que sobe ao fazer scroll
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    loc.premiumScreenSubtitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildFeatureSection(context, loc),
                  const SizedBox(height: 40),
                  if (!premium.isPremium) ...[
                    FilledButton(
                      onPressed: () => PurchaseService().buyPremium(),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        loc.premiumScreenPurchaseButton,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => PurchaseService().restorePurchases(),
                      child: Text(loc.premiumScreenRestore),
                    ),
                  ] else ...[
                    _buildSuccessBanner(context, loc),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSection(BuildContext context, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.premiumScreenFeaturesTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 20),
        _FeatureItem(
          icon: Icons.share_outlined,
          text: loc.premiumFeatureShareHistory,
        ),
        _FeatureItem(
          icon: Icons.article_outlined,
          text: loc.premiumFeatureShareChapter,
        ),
        _FeatureItem(
          icon: Icons.auto_awesome_outlined,
          text: loc.premiumFeatureAutoSuggestions,
        ),
        _FeatureItem(
          icon: Icons.insights_outlined,
          text: loc.premiumFeatureMonthlyInsights,
        ),
        _FeatureItem(
          icon: Icons.show_chart_outlined,
          text: loc.premiumFeatureWeeklyMood,
        ),
        _FeatureItem(
          icon: Icons.palette_outlined,
          text: loc.premiumFeatureCustomThemes,
        ),
      ],
    );
  }

  Widget _buildSuccessBanner(BuildContext context, AppLocalizations loc) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle, size: 48, color: colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            loc.premiumPlan,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            loc.enabled,
            style: TextStyle(color: colorScheme.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
