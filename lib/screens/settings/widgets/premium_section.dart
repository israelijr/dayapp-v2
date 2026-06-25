import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/premium_provider.dart';

class PremiumSection extends StatelessWidget {
  const PremiumSection({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final premium = context.watch<PremiumProvider>();

    return ListTile(
      leading: const Icon(Icons.workspace_premium, color: Colors.amber),
      title: Text(loc.premiumVersion),
      subtitle: Text(premium.isPremium ? loc.premiumPlan : loc.freePlan),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).pushNamed('/premium');
      },
    );
  }
}
