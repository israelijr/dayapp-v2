import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class BackupInfoScreen extends StatelessWidget {
  const BackupInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final sections = _parseSections(l10n.backupInfoDialogContent);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.28),
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
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.backupInfoDialogTitle,
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
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.backup_rounded,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.backupZipExplanation,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...sections.map(
                      (section) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _BackupInfoCard(
                          icon: _iconForSection(section),
                          iconColor: _iconColorForSection(section, colorScheme),
                          iconBackground: _iconBgForSection(
                            section,
                            colorScheme,
                          ),
                          title: section.title,
                          content: section.content,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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

  List<_BackupInfoSection> _parseSections(String content) {
    final normalized = content.replaceAll('\r\n', '\n');
    final chunks = normalized.split('\n\n');
    final sections = <_BackupInfoSection>[];

    for (final chunk in chunks) {
      final lines = chunk
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      if (lines.isEmpty) continue;

      final title = lines.first;
      final bodyLines = lines.skip(1).toList();
      final body = bodyLines.join('\n');

      if (_shouldHideSection(title, body)) {
        continue;
      }

      sections.add(_BackupInfoSection(title: title, content: body));
    }

    return sections;
  }

  bool _shouldHideSection(String title, String content) {
    final normalized = '$title\n$content'.toLowerCase();

    return normalized.contains('senha') ||
        normalized.contains('password') ||
        normalized.contains('encrypt') ||
        normalized.contains('criptograf') ||
        normalized.contains('encript');
  }

  IconData _iconForSection(_BackupInfoSection section) {
    final title = section.title.toLowerCase();

    if (title.contains('backup') && title.contains('inclu')) {
      return Icons.inventory_2_rounded;
    }
    if (title.contains('armazen') || title.contains('store')) {
      return Icons.folder_special_rounded;
    }
    if (title.contains('important') ||
        title.contains('⚠') ||
        title.contains('aten')) {
      return Icons.warning_amber_rounded;
    }
    return Icons.info_outline_rounded;
  }

  Color _iconColorForSection(
    _BackupInfoSection section,
    ColorScheme colorScheme,
  ) {
    final title = section.title.toLowerCase();
    if (title.contains('important') ||
        title.contains('⚠') ||
        title.contains('aten')) {
      return colorScheme.tertiary;
    }
    return colorScheme.primary;
  }

  Color _iconBgForSection(_BackupInfoSection section, ColorScheme colorScheme) {
    final title = section.title.toLowerCase();
    if (title.contains('important') ||
        title.contains('⚠') ||
        title.contains('aten')) {
      return colorScheme.tertiaryContainer;
    }
    return colorScheme.primaryContainer;
  }
}

class _BackupInfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String content;

  const _BackupInfoCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.content,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (content.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      content,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackupInfoSection {
  final String title;
  final String content;

  const _BackupInfoSection({required this.title, required this.content});
}
