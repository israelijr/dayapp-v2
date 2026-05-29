import 'dart:ui' as ui;

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
      body: Stack(
        children: [
          if (story.images.isNotEmpty)
            Positioned.fill(
              child: Image.memory(story.images.first, fit: BoxFit.cover),
            )
          else
            Positioned.fill(child: ColoredBox(color: colorScheme.surface)),
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: colorScheme.surface.withValues(alpha: 0.12),
              ),
            ),
          ),
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.92,
              heightFactor: 0.80,
              child: Material(
                color: Colors.transparent,
                elevation: 12,
                shadowColor: colorScheme.onSurface.withValues(alpha: 0.12),
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
