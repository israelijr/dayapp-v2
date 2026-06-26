import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chapters_screen.dart';

class ChaptersEntryScreen extends StatefulWidget {
  final bool forceShowIntro;

  const ChaptersEntryScreen({super.key, this.forceShowIntro = false});

  @override
  State<ChaptersEntryScreen> createState() => _ChaptersEntryScreenState();
}

class _ChaptersEntryScreenState extends State<ChaptersEntryScreen> {
  static const String _prefShowIntroOnOpen = 'chapters_show_intro_on_open';

  bool _isLoading = true;
  bool _showIntroOnOpen = true;
  bool _showIntroInCurrentOpen = true;

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final showIntro = prefs.getBool(_prefShowIntroOnOpen) ?? true;
      if (!mounted) return;
      setState(() {
        _showIntroOnOpen = showIntro;
        _showIntroInCurrentOpen = showIntro || widget.forceShowIntro;
        _isLoading = false;
      });
    } catch (e) {
      // Em falha de leitura, mantém o padrão para não ocultar a introdução.
      debugPrint('ChaptersEntryScreen._loadPreference: erro ao ler preferências: $e');
      if (!mounted) return;
      setState(() {
        _showIntroOnOpen = true;
        _showIntroInCurrentOpen = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateShowOnOpen(bool value) async {
    setState(() {
      _showIntroOnOpen = value;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefShowIntroOnOpen, value);
    } catch (e) {
      // Falha de persistência não deve interromper a navegação.
      debugPrint('ChaptersEntryScreen._updateShowOnOpen: erro ao salvar preferência: $e');
    }
  }

  void _openChapters() {
    setState(() {
      _showIntroInCurrentOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_showIntroInCurrentOpen) {
      return const ChaptersScreen();
    }

    return _ChaptersIntroScreen(
      showOnOpen: _showIntroOnOpen,
      onShowOnOpenChanged: _updateShowOnOpen,
      onContinue: _openChapters,
    );
  }
}

class _ChaptersIntroScreen extends StatelessWidget {
  final bool showOnOpen;
  final ValueChanged<bool> onShowOnOpenChanged;
  final VoidCallback onContinue;

  const _ChaptersIntroScreen({
    required this.showOnOpen,
    required this.onShowOnOpenChanged,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surfaceContainerLowest,
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
                    Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.chaptersTitle,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.chapterIntroSubtitle,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _IntroFeatureCard(
                      icon: Icons.layers_rounded,
                      iconColor: colorScheme.primary,
                      iconBackground: colorScheme.primaryContainer,
                      title: l10n.chapterIntroGroupTitle,
                      body: l10n.chapterIntroGroupBody,
                    ),
                    const SizedBox(height: 14),
                    _IntroFeatureCard(
                      icon: Icons.calendar_today_rounded,
                      iconColor: colorScheme.tertiary,
                      iconBackground: colorScheme.tertiaryContainer,
                      title: l10n.chapterIntroTimelineTitle,
                      body: l10n.chapterIntroTimelineBody,
                    ),
                    const SizedBox(height: 14),
                    _IntroFeatureCard(
                      icon: Icons.bookmark_added_rounded,
                      iconColor: colorScheme.secondary,
                      iconBackground: colorScheme.secondaryContainer,
                      title: l10n.chapterIntroPhaseTitle,
                      body: l10n.chapterIntroPhaseBody,
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [colorScheme.primary, colorScheme.secondary],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            l10n.chapterIntroCtaTitle,
                            textAlign: TextAlign.center,
                            style: textTheme.titleLarge?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.chapterIntroCtaBody,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimary.withValues(
                                alpha: 0.92,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          FilledButton(
                            onPressed: onContinue,
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.surface,
                              foregroundColor: colorScheme.primary,
                            ),
                            child: Text(l10n.chapterCreateFromSuggestion),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CheckboxListTile(
                        value: showOnOpen,
                        onChanged: (value) {
                          onShowOnOpenChanged(value ?? true);
                        },
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          l10n.chapterIntroShowOnOpen,
                          style: textTheme.bodyMedium,
                        ),
                      ),
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
}

class _IntroFeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String body;

  const _IntroFeatureCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      margin: EdgeInsets.zero,
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
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
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
