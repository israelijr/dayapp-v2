// Widgets compartilhados para exibição de mídia (fotos, áudios, vídeos) das histórias.
// Usado em: home_content, group_stories, archived_stories, search, calendar, trash.
import 'dart:io';
import 'dart:typed_data';

import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../db/historia_audio_helper.dart';
import '../db/historia_foto_helper.dart';
import '../db/historia_video_helper.dart';
import '../models/historia_video_v2.dart' as v2;
import '../providers/pin_provider.dart';
import '../providers/refresh_provider.dart';
import '../services/thumbnail_service.dart';
import 'compact_audio_icon.dart';
import 'compact_video_icon.dart';

/// Exibe a grade de fotos de uma história com visualizador completo
/// (navegação entre fotos, zoom, compartilhar, excluir).
class HistoriaFotosGrid extends StatelessWidget {
  final int historiaId;
  final double height;

  /// Se verdadeiro, exibe um container com ícone de imagem quando não há fotos.
  /// Por padrão é false (retorna widget vazio).
  final bool showPlaceholderIfEmpty;

  const HistoriaFotosGrid({
    required this.historiaId,
    super.key,
    this.height = 120,
    this.showPlaceholderIfEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FotoComBytes>>(
      future: HistoriaFotoHelper().getFotosComBytesByHistoria(historiaId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          if (!showPlaceholderIfEmpty) return const SizedBox.shrink();
          return Container(
            height: height,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.image,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                size: 48,
              ),
            ),
          );
        }

        final fotos = snapshot.data!;
        if (fotos.length == 1) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GestureDetector(
              onTap: () {
                // Abre o visualizador completo para imagem única
                _openViewer(context, fotos, 0);
              },
              child: SizedBox(
                height: height,
                width: double.infinity,
                child: HistoriaThumbnailImage(
                  imageBytes: fotos[0].bytes,
                  identifier: 'foto_${fotos[0].id}',
                ),
              ),
            ),
          );
        }

        // Monta colagem responsiva para 2+ fotos
        final displayFotos = fotos;
        final total = displayFotos.length;

        Widget tileForIndex(int index) {
          final foto = displayFotos[index];
          final isOverlay = index == 3 && total > 4;
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: InkWell(
                onTap: () => _openViewer(context, displayFotos, index),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Semantics(
                      label: 'Foto ${index + 1} de $total',
                      image: true,
                      child: HistoriaThumbnailImage(
                        imageBytes: foto.bytes,
                        identifier: 'foto_${foto.id}',
                      ),
                    ),
                    if (isOverlay)
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.54),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '+${total - 3}',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onInverseSurface,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'mais',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        if (total == 2) {
          return SizedBox(
            height: height,
            child: Row(
              children: [
                Expanded(child: tileForIndex(0)),
                const SizedBox(width: 4),
                Expanded(child: tileForIndex(1)),
              ],
            ),
          );
        }

        if (total == 3) {
          return SizedBox(
            height: height,
            child: Row(
              children: [
                Expanded(flex: 2, child: tileForIndex(0)),
                const SizedBox(width: 4),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Expanded(child: tileForIndex(1)),
                      const SizedBox(height: 4),
                      Expanded(child: tileForIndex(2)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // total >= 4
        return SizedBox(
          height: height,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: tileForIndex(0)),
                    const SizedBox(width: 4),
                    Expanded(child: tileForIndex(1)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: tileForIndex(2)),
                    const SizedBox(width: 4),
                    Expanded(child: tileForIndex(3)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Abre o visualizador de fotos completo com navegação, zoom, compartilhar e excluir.
  void _openViewer(
    BuildContext context,
    List<FotoComBytes> displayFotos,
    int initialIndex,
  ) {
    final parentContext = context;
    final images = displayFotos.map((f) => f.bytes).toList();
    final ids = displayFotos.map((f) => f.id).toList();

    final localImages = List<Uint8List>.from(images);
    final localIds = List<int>.from(ids);

    final refreshProviderForDialog = Provider.of<RefreshProvider>(
      parentContext,
      listen: false,
    );

    showDialog<bool>(
      context: parentContext,
      barrierDismissible: true,
      builder: (ctx) {
        int currentIndex = initialIndex;
        final controller = PageController(initialPage: initialIndex);
        return StatefulBuilder(
          builder: (ctx2, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(8),
              backgroundColor: const Color(0x00000000),
              child: Container(
                width: MediaQuery.of(parentContext).size.width * 0.98,
                height: MediaQuery.of(parentContext).size.height * 0.88,
                decoration: BoxDecoration(
                  color: Theme.of(parentContext).colorScheme.inverseSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: PageView.builder(
                        controller: controller,
                        itemCount: localImages.length,
                        onPageChanged: (i) => setState(() => currentIndex = i),
                        itemBuilder: (c, i) => InteractiveViewer(
                          panEnabled: true,
                          minScale: 1.0,
                          maxScale: 4.0,
                          child: Center(
                            child: Image.memory(
                              localImages[i],
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Seta esquerda
                    if (localImages.length > 1)
                      Positioned(
                        left: 12,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: AnimatedOpacity(
                            opacity: currentIndex > 0 ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 120),
                            child: Material(
                              color: Theme.of(
                                ctx2,
                              ).colorScheme.onSurface.withValues(alpha: 0.54),
                              shape: const CircleBorder(),
                              elevation: 8,
                              child: IconButton(
                                iconSize: 44,
                                color: Theme.of(
                                  ctx2,
                                ).colorScheme.onInverseSurface,
                                onPressed: currentIndex > 0
                                    ? () => controller.previousPage(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        curve: Curves.easeInOut,
                                      )
                                    : null,
                                icon: const Icon(Icons.chevron_left),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Seta direita
                    if (localImages.length > 1)
                      Positioned(
                        right: 12,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: AnimatedOpacity(
                            opacity: currentIndex < localImages.length - 1
                                ? 1.0
                                : 0.0,
                            duration: const Duration(milliseconds: 120),
                            child: Material(
                              color: Theme.of(
                                ctx2,
                              ).colorScheme.onSurface.withValues(alpha: 0.54),
                              shape: const CircleBorder(),
                              elevation: 8,
                              child: IconButton(
                                iconSize: 44,
                                color: Theme.of(
                                  ctx2,
                                ).colorScheme.onInverseSurface,
                                onPressed: currentIndex < localImages.length - 1
                                    ? () => controller.nextPage(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        curve: Curves.easeInOut,
                                      )
                                    : null,
                                icon: const Icon(Icons.chevron_right),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Botão fechar
                    Positioned(
                      right: 8,
                      top: 8,
                      child: SafeArea(
                        child: Material(
                          color: Theme.of(
                            ctx2,
                          ).colorScheme.onSurface.withValues(alpha: 0.45),
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(
                                ctx2,
                              ).colorScheme.onInverseSurface,
                            ),
                            onPressed: () => Navigator.of(ctx2).pop(false),
                          ),
                        ),
                      ),
                    ),

                    // Botões de ação (compartilhar e excluir)
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Compartilhar
                          Material(
                            color: Theme.of(
                              ctx2,
                            ).colorScheme.onSurface.withValues(alpha: 0.54),
                            shape: const CircleBorder(),
                            elevation: 6,
                            child: IconButton(
                              icon: Icon(
                                Icons.share,
                                color: Theme.of(
                                  ctx2,
                                ).colorScheme.onInverseSurface,
                              ),
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(
                                  parentContext,
                                );
                                final pinProvider = Provider.of<PinProvider>(
                                  parentContext,
                                  listen: false,
                                );
                                final localizations = AppLocalizations.of(
                                  parentContext,
                                )!;
                                pinProvider.isPickingExternalMedia = true;

                                try {
                                  final bytes = localImages[currentIndex];
                                  final tempDir = await getTemporaryDirectory();
                                  final file = File(
                                    '${tempDir.path}/image_${currentIndex + 1}.png',
                                  );
                                  await file.writeAsBytes(bytes);
                                  // ignore: deprecated_member_use
                                  await Share.shareXFiles([XFile(file.path)]);
                                  pinProvider.isPickingExternalMedia = false;
                                } catch (e) {
                                  pinProvider.isPickingExternalMedia = false;
                                  debugPrint(
                                    'HistoriaMediaWidgets: erro ao compartilhar imagem da história: $e',
                                  );
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(localizations.errorShare),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Excluir foto
                          if (localIds.isNotEmpty)
                            Material(
                              color: Theme.of(
                                ctx2,
                              ).colorScheme.onSurface.withValues(alpha: 0.54),
                              shape: const CircleBorder(),
                              elevation: 6,
                              child: IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Theme.of(
                                    ctx2,
                                  ).colorScheme.onInverseSurface,
                                ),
                                onPressed: () async {
                                  final id = localIds[currentIndex];
                                  final refreshProviderRef =
                                      Provider.of<RefreshProvider>(
                                        parentContext,
                                        listen: false,
                                      );
                                  final messengerRef = ScaffoldMessenger.of(
                                    parentContext,
                                  );
                                  final navigatorRef = Navigator.of(ctx2);

                                  final loc = AppLocalizations.of(ctx2)!;
                                  final confirm = await showDialog<bool>(
                                    context: ctx2,
                                    builder: (_) => AlertDialog(
                                      title: Text(loc.deletePhotoTitle),
                                      content: Text(loc.deletePhotoConfirm),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx2, false),
                                          child: Text(loc.cancel),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx2, true),
                                          child: Text(
                                            loc.deleteLabel,
                                            style: TextStyle(
                                              color: Theme.of(
                                                ctx2,
                                              ).colorScheme.error,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    final deletedBytes =
                                        localImages[currentIndex];
                                    final historiaIdRef = historiaId;

                                    await HistoriaFotoHelper().deleteFoto(id);
                                    setState(() {
                                      localImages.removeAt(currentIndex);
                                      localIds.removeAt(currentIndex);
                                      if (currentIndex >= localImages.length &&
                                          localImages.isNotEmpty) {
                                        currentIndex = localImages.length - 1;
                                        controller.jumpToPage(currentIndex);
                                      }
                                    });

                                    messengerRef.hideCurrentSnackBar();
                                    messengerRef.showSnackBar(
                                      SnackBar(
                                        content: Text(loc.photoDeleted),
                                        action: SnackBarAction(
                                          label: loc.undo,
                                          onPressed: () async {
                                            await HistoriaFotoHelper()
                                                .insertFotoFromBytes(
                                                  historiaId: historiaIdRef,
                                                  fotoBytes: deletedBytes,
                                                );
                                            refreshProviderRef.refresh();
                                          },
                                        ),
                                      ),
                                    );

                                    if (localImages.isEmpty) {
                                      navigatorRef.pop(true);
                                    }
                                  }
                                },
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Indicadores de página (bolinhas)
                    Positioned(
                      bottom: 18,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(localImages.length, (i) {
                          final active = i == currentIndex;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: active ? 10 : 6,
                            height: active ? 10 : 6,
                            decoration: BoxDecoration(
                              color: active
                                  ? Theme.of(ctx2).colorScheme.onInverseSurface
                                  : Theme.of(ctx2).colorScheme.onSurface
                                        .withValues(alpha: 0.54),
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((deleted) {
      if (deleted == true) {
        refreshProviderForDialog.refresh();
      }
    });
  }
}

/// Exibe emoticon, áudios e vídeos de uma história em linha horizontal.
class HistoriaMediaRow extends StatelessWidget {
  final int historiaId;
  final String? emoticon;
  final String? Function(String)? convertLegacyEmoticon;

  const HistoriaMediaRow({
    required this.historiaId,
    super.key,
    this.emoticon,
    this.convertLegacyEmoticon,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadMediaData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;
        final audios = data['audios'] as List<AudioComBytes>;
        final videos = data['videos'] as List<v2.HistoriaVideo>;

        if (audios.isEmpty && videos.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: 64,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...audios.map((audio) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CompactAudioIcon(
                      audioData: audio.bytes,
                      duration: audio.duracao,
                    ),
                  );
                }),
                ...videos.map((video) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CompactVideoIcon(
                      videoPath: video.videoPath,
                      duration: video.duracao,
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadMediaData() async {
    try {
      final audios = await HistoriaAudioHelper().getAudiosComBytesByHistoria(
        historiaId,
      );
      final videos = await HistoriaVideoHelper().getVideosByHistoria(
        historiaId,
      );
      return {'audios': audios, 'videos': videos};
    } catch (e) {
      // Silencia erros de carregamento de mídia — não crítico
      return {'audios': <AudioComBytes>[], 'videos': <v2.HistoriaVideo>[]};
    }
  }
}

/// Exibe apenas os áudios de uma história (legado / uso pontual).
class HistoriaAudiosSection extends StatelessWidget {
  final int historiaId;

  const HistoriaAudiosSection({required this.historiaId, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AudioComBytes>>(
      future: HistoriaAudioHelper().getAudiosComBytesByHistoria(historiaId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final audios = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: audios.map((audio) {
              return CompactAudioIcon(
                audioData: audio.bytes,
                duration: audio.duracao,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

/// Exibe apenas os vídeos de uma história (legado / uso pontual).
class HistoriaVideosSection extends StatelessWidget {
  final int historiaId;

  const HistoriaVideosSection({required this.historiaId, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<v2.HistoriaVideo>>(
      future: HistoriaVideoHelper().getVideosByHistoria(historiaId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final videos = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: videos.map((video) {
              return CompactVideoIcon(
                videoPath: video.videoPath,
                duration: video.duracao,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

/// Thumbnail de imagem com cache via ThumbnailService.
class HistoriaThumbnailImage extends StatefulWidget {
  final Uint8List imageBytes;
  final String identifier;

  const HistoriaThumbnailImage({
    required this.imageBytes,
    required this.identifier,
    super.key,
  });

  @override
  State<HistoriaThumbnailImage> createState() => _HistoriaThumbnailImageState();
}

class _HistoriaThumbnailImageState extends State<HistoriaThumbnailImage> {
  Uint8List? _thumbnailBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(covariant HistoriaThumbnailImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.identifier != widget.identifier ||
        oldWidget.imageBytes != widget.imageBytes) {
      setState(() {
        _isLoading = true;
        _thumbnailBytes = null;
      });
      _loadThumbnail();
    }
  }

  Future<void> _loadThumbnail() async {
    try {
      final thumbnail = await ThumbnailService().getThumbnailFromBytes(
        widget.imageBytes,
        widget.identifier,
      );
      if (mounted) {
        setState(() {
          _thumbnailBytes = thumbnail;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Em caso de erro, usa imagem original sem thumbnail
      debugPrint(
        'HistoriaMediaWidgets: erro ao gerar thumbnail, usando imagem original: $e',
      );
      if (mounted) {
        setState(() {
          _thumbnailBytes = widget.imageBytes;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Image.memory(
      _thumbnailBytes ?? widget.imageBytes,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Center(
            child: Icon(
              Icons.broken_image,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}
