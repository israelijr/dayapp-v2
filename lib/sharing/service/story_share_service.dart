import 'dart:ui' as ui;

import 'package:dayapp/db/historia_foto_helper.dart';
import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:dayapp/models/historia.dart';
import 'package:dayapp/providers/pin_provider.dart';
import 'package:dayapp/sharing/renderer/story_share_renderer.dart';
import 'package:dayapp/sharing/story_data.dart';
import 'package:dayapp/sharing/story_share_preview_screen.dart';
import 'package:dayapp/sharing/templates/story_share_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class StoryShareService {
  static Future<void> shareHistoria(
    BuildContext context,
    Historia historia,
    String localeName,
  ) async {
    final args = _StoryShareArguments.fromContext(context);
    final navigator = Navigator.of(context);
    args.pinProvider.isPickingExternalMedia = true;

    try {
      final photos = await HistoriaFotoHelper().getFotosComBytesByHistoria(
        historia.id ?? 0,
      );
      final images = photos.map((photo) => photo.bytes).toList();
      final storyData = StoryData.fromHistoria(
        historia,
        images,
        localeName: localeName,
      );

      final shouldShare = await navigator.push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => StorySharePreviewScreen(story: storyData),
        ),
      );

      if (shouldShare != true) {
        return;
      }

      final bytes = await renderStoryShareToImage(
        args.overlayState,
        _ShareStoryShareableScene(story: storyData),
      );

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              mimeType: 'image/png',
              name:
                  'dayapp_story_${historia.id ?? DateTime.now().millisecondsSinceEpoch}.png',
            ),
          ],
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('StoryShareService: failed to share story: $error');
      debugPrint(stackTrace.toString());
      args.messenger.showSnackBar(
        SnackBar(content: Text(args.localizations.shareError)),
      );
    } finally {
      args.pinProvider.isPickingExternalMedia = false;
    }
  }
}

class _ShareStoryShareableScene extends StatelessWidget {
  final StoryData story;

  const _ShareStoryShareableScene({required this.story});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (story.images.isNotEmpty)
          Image.memory(story.images.first, fit: BoxFit.cover)
        else
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surfaceContainerHighest,
                  colorScheme.surface,
                ],
              ),
            ),
          ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              color: colorScheme.surface.withValues(alpha: 0.10),
            ),
          ),
        ),
        Center(
          child: FractionallySizedBox(
            widthFactor: 0.70,
            heightFactor: 0.78,
            child: Material(
              color: Colors.transparent,
              child: StoryShareWidget(story: story),
            ),
          ),
        ),
      ],
    );
  }
}

class _StoryShareArguments {
  final ScaffoldMessengerState messenger;
  final AppLocalizations localizations;
  final OverlayState overlayState;
  final PinProvider pinProvider;

  _StoryShareArguments({
    required this.messenger,
    required this.localizations,
    required this.overlayState,
    required this.pinProvider,
  });

  factory _StoryShareArguments.fromContext(BuildContext context) {
    return _StoryShareArguments(
      messenger: ScaffoldMessenger.of(context),
      localizations: AppLocalizations.of(context)!,
      overlayState: Overlay.of(context),
      pinProvider: Provider.of<PinProvider>(context, listen: false),
    );
  }
}
