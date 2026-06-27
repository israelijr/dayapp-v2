import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:dayapp/sharing/story_data.dart';
import 'package:dayapp/sharing/templates/story_share_widget.dart';
import 'package:flutter/material.dart';

class StorySharePreviewScreen extends StatelessWidget {
  final StoryData story;

  const StorySharePreviewScreen({required this.story, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: StoryShareWidget(story: story),
            ),
          ),
          // Botões no topo (Close) e rodapé (Share)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: IconButton.filled(
              onPressed: () => Navigator.of(context).pop(false),
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surface.withValues(alpha: 0.7),
                foregroundColor: colorScheme.onSurface,
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.share),
                label: Text(l10n.share),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
