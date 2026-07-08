import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class ContinuityHookInfoScreen extends StatelessWidget {
  const ContinuityHookInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final parsedContent = _parseContent(l10n.continuityInfoDesc);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.30),
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
                    // ---- Cabeçalho com título e botão fechar ----
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.continuityInfoTitle,
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

                    // ---- Ícone central ----
                    Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.auto_stories_rounded,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ---- Texto introdutório ----
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

                    // ---- Seções de conteúdo ----
                    ...parsedContent.sections.asMap().entries.map((entry) {
                      final index = entry.key;
                      final section = entry.value;
                      final isLast =
                          index == parsedContent.sections.length - 1;

                      return Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                        child: _SectionCard(
                          icon: _iconForSection(index),
                          iconColor: colorScheme.primary,
                          iconBackground: colorScheme.primaryContainer,
                          title: section.title,
                          bullets: section.bullets,
                          plainText: section.plainText,
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // ---- Botão fechar ----
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

  IconData _iconForSection(int index) {
    if (index == 0) return Icons.link_rounded;
    if (index == 1) return Icons.notifications_active_rounded;
    return Icons.self_improvement_rounded;
  }

  _ParsedContent _parseContent(String content) {
    final lines = content.split('\n');
    final introBuffer = StringBuffer();
    final sections = <_Section>[];

    _Section? currentSection;

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final isHeading = line.startsWith('###');
      final isBullet =
          line.startsWith('•') || line.startsWith('-') || line.startsWith('*');

      if (isHeading) {
        if (currentSection != null) sections.add(currentSection);
        final title = line.replaceAll(RegExp(r'^#+\s*'), '').trim();
        currentSection = _Section(title: title, bullets: [], plainText: '');
      } else if (isBullet) {
        final text = line.substring(1).trim();
        if (currentSection != null) {
          currentSection.bullets.add(text);
        }
      } else {
        if (currentSection == null) {
          if (introBuffer.isNotEmpty) introBuffer.write(' ');
          introBuffer.write(line);
        } else {
          final prev = currentSection.plainText;
          currentSection = _Section(
            title: currentSection.title,
            bullets: currentSection.bullets,
            plainText: prev.isEmpty ? line : '$prev $line',
          );
        }
      }
    }

    if (currentSection != null) sections.add(currentSection);

    return _ParsedContent(
      intro: introBuffer.toString(),
      sections: sections,
    );
  }
}

// ---------------------------------------------------------------------------
// Card de seção
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final List<String> bullets;
  final String plainText;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.bullets,
    required this.plainText,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            if (plainText.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                plainText,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
            if (bullets.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...bullets.map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          b,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Modelos internos de parsing
// ---------------------------------------------------------------------------

class _Section {
  final String title;
  final List<String> bullets;
  final String plainText;

  _Section({
    required this.title,
    required this.bullets,
    required this.plainText,
  });
}

class _ParsedContent {
  final String intro;
  final List<_Section> sections;

  const _ParsedContent({required this.intro, required this.sections});
}
