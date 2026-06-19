import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class EntryToolbar extends StatelessWidget {
  final VoidCallback onPickPhoto;
  final VoidCallback onPickVideo;
  final VoidCallback onRecordAudio;
  final VoidCallback onSelectEmoji;

  const EntryToolbar({
    required this.onPickPhoto,
    required this.onPickVideo,
    required this.onRecordAudio,
    required this.onSelectEmoji,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton.filledTonal(
              onPressed: onPickPhoto,
              icon: const Icon(Icons.camera_alt_outlined),
              tooltip: AppLocalizations.of(context)!.photoTooltip,
            ),
            IconButton.filledTonal(
              onPressed: onPickVideo,
              icon: const Icon(Icons.videocam_outlined),
              tooltip: AppLocalizations.of(context)!.videoTooltip,
            ),
            IconButton.filledTonal(
              onPressed: onRecordAudio,
              icon: const Icon(Icons.mic_none_outlined),
              tooltip: AppLocalizations.of(context)!.audioTooltip,
            ),
            IconButton.filledTonal(
              onPressed: onSelectEmoji,
              icon: const Icon(Icons.add_reaction_outlined),
              tooltip: AppLocalizations.of(context)!.emojiTooltip,
            ),
          ],
        ),
      ),
    );
  }
}
