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
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(34),
                clipBehavior: Clip.antiAlias,
                child: StoryShareWidget(story: story),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(l10n.share),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: colorScheme.surface,
                        foregroundColor: colorScheme.onSurface,
                        side: BorderSide(
                          color: colorScheme.onSurface.withValues(alpha: 0.16),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(l10n.close),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
