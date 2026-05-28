import 'package:flutter/material.dart';
import '../widgets/video_player_widget.dart';

/// Widget compacto para exibir ícone de vídeo que abre player em dialog
class CompactVideoIcon extends StatelessWidget {
  final List<int>? videoData; // Para vídeos novos (bytes)
  final String? videoPath; // Para vídeos existentes (caminho)
  final List<int>? thumbnail;
  final int? duration;
  final VoidCallback? onDelete;

  const CompactVideoIcon({
    super.key,
    this.videoData,
    this.videoPath,
    this.thumbnail,
    this.duration,
    this.onDelete,
  }) : assert(
         videoData != null || videoPath != null,
         'Deve fornecer videoData ou videoPath',
       );

  void _showVideoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reproduzir Vídeo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              VideoPlayerWidget(
                videoData: videoData,
                videoPath: videoPath,
                thumbnail: thumbnail,
                duration: duration,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () => _showVideoDialog(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              'assets/image/video.png',
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.videocam, size: 40);
              },
            ),
          ),
        ),
        if (onDelete != null)
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.onError,
                  size: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
