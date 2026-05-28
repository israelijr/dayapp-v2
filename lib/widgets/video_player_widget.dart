import 'dart:io';
import 'package:dayapp/l10n/generated/app_localizations.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../theme/m3_expressive_theme.dart';

class VideoPlayerWidget extends StatefulWidget {
  final List<int>? videoData; // Para vídeos novos (bytes)
  final String? videoPath; // Para vídeos existentes (caminho)
  final List<int>? thumbnail;
  final int? duration;

  const VideoPlayerWidget({
    super.key,
    this.videoData,
    this.videoPath,
    this.thumbnail,
    this.duration,
  }) : assert(
         videoData != null || videoPath != null,
         'Deve fornecer videoData ou videoPath',
       );

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _hasError = false;

  // Verifica se a plataforma suporta video_player
  bool get _isPlatformSupported {
    return !kIsWeb &&
        (Platform.isAndroid || Platform.isIOS || Platform.isLinux);
  }

  @override
  void initState() {
    super.initState();
    if (_isPlatformSupported) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      File videoFile;

      if (widget.videoPath != null) {
        // Vídeo existente - usar caminho direto

        videoFile = File(widget.videoPath!);

        if (!await videoFile.exists()) {
          throw Exception('Arquivo de vídeo não encontrado');
        }
      } else if (widget.videoData != null) {
        // Vídeo novo - criar arquivo temporário

        final tempDir = await getTemporaryDirectory();
        videoFile = File(
          '${tempDir.path}/temp_video_${DateTime.now().millisecondsSinceEpoch}.mp4',
        );
        await videoFile.writeAsBytes(widget.videoData!);
      } else {
        throw Exception('Nenhuma fonte de vídeo fornecida');
      }

      _controller = VideoPlayerController.file(videoFile);
      await _controller!.initialize();

      _controller!.addListener(() {
        if (mounted) {
          setState(() {
            _isPlaying = _controller!.value.isPlaying;
          });
        }
      });

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  Future<String> _getVideoSize() async {
    if (widget.videoData != null) {
      final sizeInMB = widget.videoData!.length / 1024 / 1024;
      return sizeInMB.toStringAsFixed(2);
    } else if (widget.videoPath != null) {
      try {
        final file = File(widget.videoPath!);
        if (await file.exists()) {
          final size = await file.length();
          final sizeInMB = size / 1024 / 1024;
          return sizeInMB.toStringAsFixed(2);
        }
      } catch (e) {
        // Erro ao obter tamanho do vídeo
      }
    }
    return '?';
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    // Mostra placeholder no Windows/Desktop
    if (!_isPlatformSupported) {
      return _buildWindowsPlaceholder(context);
    }

    // Mostra erro se houver
    if (_hasError) {
      return _buildErrorPlaceholder(context);
    }

    // Mostra loading enquanto inicializa
    if (!_isInitialized) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
          if (!_isPlaying)
            ColoredBox(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.38),
              child: Icon(
                Icons.play_arrow,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          Positioned.fill(
            child: GestureDetector(
              onTap: _togglePlayPause,
              behavior: HitTestBehavior.opaque,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    const Color(0x00000000),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Text(
                    _formatDuration(_controller!.value.position),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 12,
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: SliderComponentShape.noOverlay,
                      ),
                      child: Slider(
                        value: _controller!.value.position.inSeconds.toDouble(),
                        max: _controller!.value.duration.inSeconds.toDouble(),
                        onChanged: (value) {
                          _controller!.seekTo(Duration(seconds: value.toInt()));
                        },
                        activeColor: Theme.of(context).colorScheme.onSurface,
                        inactiveColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.38),
                      ),
                    ),
                  ),
                  Text(
                    _formatDuration(_controller!.value.duration),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 12,
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

  Widget _buildWindowsPlaceholder(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 280),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.emoticonBlue2, AppColors.purple300],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.videocam,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(height: 16),
          Text(
            'Vídeo salvo com sucesso',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          FutureBuilder<String>(
            future: _getVideoSize(),
            builder: (context, snapshot) {
              return Text(
                'Tamanho: ${snapshot.data ?? "..."} MB',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              );
            },
          ),
          if (widget.duration != null) ...[
            const SizedBox(height: 4),
            Text(
              'Duração: ${_formatDuration(Duration(seconds: widget.duration!))}',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Reprodução de vídeo não disponível no Windows',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.errorLoadVideo,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          FutureBuilder<String>(
            future: _getVideoSize(),
            builder: (context, snapshot) {
              return Text(
                'Tamanho: ${snapshot.data ?? "..."} MB',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.error.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
