import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class BackgroundRestrictionsInfoScreen extends StatelessWidget {
  const BackgroundRestrictionsInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final parsedContent = _parseBackgroundWarningContent(
      l10n.backgroundRestrictionsWarningDesc,
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.tertiaryContainer.withValues(alpha: 0.35),
              colorScheme.surface,
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.backgroundRestrictionsWarningTitle,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.close,
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.notifications_active_rounded,
                          color: colorScheme.tertiary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (parsedContent.intro.isNotEmpty)
                      Text(
                        parsedContent.intro,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.entryNotificationsInfo,
                              style: textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : colorScheme.onSecondaryContainer,
                                fontWeight: Theme.of(context).brightness == Brightness.dark
                                    ? FontWeight.w600
                                    : null,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...parsedContent.steps.asMap().entries.map((entry) {
                      final index = entry.key;
                      final step = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == parsedContent.steps.length - 1
                              ? 0
                              : 12,
                        ),
                        child: _GuidanceCard(
                          icon: _iconForStep(index),
                          iconColor: colorScheme.primary,
                          iconBackground: colorScheme.primaryContainer,
                          text: step,
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.check_rounded),
                      label: Text(l10n.close),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconForStep(int index) {
    if (index == 0) return Icons.pause_circle_outline_rounded;
    if (index == 1) return Icons.battery_charging_full_rounded;
    return Icons.tune_rounded;
  }

  _WarningContent _parseBackgroundWarningContent(String content) {
    final lines = content.split('\n');
    final introBuffer = StringBuffer();
    final steps = <String>[];

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final isBullet =
          line.startsWith('•') || line.startsWith('-') || line.startsWith('*');

      if (isBullet) {
        steps.add(line.substring(1).trim());
      } else {
        if (introBuffer.isNotEmpty) {
          introBuffer.write(' ');
        }
        introBuffer.write(line);
      }
    }

    return _WarningContent(intro: introBuffer.toString(), steps: steps);
  }
}

class _GuidanceCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String text;

  const _GuidanceCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WarningContent {
  final String intro;
  final List<String> steps;

  const _WarningContent({required this.intro, required this.steps});
}
