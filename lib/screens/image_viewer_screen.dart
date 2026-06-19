import 'dart:convert';

import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../db/historia_foto_helper.dart';
import '../providers/pin_provider.dart';
import '../theme/animation_durations.dart';

class ImageViewerScreen extends StatefulWidget {
  final List<Uint8List> images;
  final List<int>? photoIds; // optional DB ids corresponding to images
  final int? historiaId; // optional for context
  final int initialIndex;
  const ImageViewerScreen({
    required this.images,
    super.key,
    this.photoIds,
    this.historiaId,
    this.initialIndex = 0,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _shareCurrent() async {
    // Seta flag para evitar bloqueio de tela quando o app vai para background
    final pinProvider = context.read<PinProvider>();
    pinProvider.isPickingExternalMedia = true;

    try {
      final bytes = widget.images[_currentIndex];
      // ignore: deprecated_member_use
      await Share.shareXFiles([
        XFile.fromData(
          bytes,
          mimeType: 'image/png',
          name: 'image_${_currentIndex + 1}.png',
        ),
      ]);

      // Reseta a flag após retornar do app externo
      pinProvider.isPickingExternalMedia = false;
    } catch (e) {
      // Garante reset da flag em caso de erro
      pinProvider.isPickingExternalMedia = false;

      // fallback: copy base64 to clipboard
      try {
        final bytes = widget.images[_currentIndex];
        final base64 = base64Encode(bytes);
        await Clipboard.setData(ClipboardData(text: base64));
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.imageCopiedBase64),
            ),
          );
        }
      } catch (fallbackError) {
        debugPrint(
          'ImageViewerScreen: falha ao compartilhar arquivo; fallback para base64: $fallbackError',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.shareError)),
          );
        }
      }
    }
  }

  Future<void> _deleteCurrent() async {
    if (widget.photoIds == null) return;
    final id = widget.photoIds![_currentIndex];
    if (id <= 0) {
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.cannotDeletePhoto),
          ),
        );
      }
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deletePhotoTitle),
        content: Text(AppLocalizations.of(context)!.deletePhotoConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context)!.deleteLabel,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await HistoriaFotoHelper().deleteFoto(id);
      if (!mounted) return;
      final navigator = Navigator.of(context);
      navigator.pop(true); // signal deletion happened to caller
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: AppLocalizations.of(context)!.close,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('${_currentIndex + 1} / ${widget.images.length}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: AppLocalizations.of(context)!.share,
            onPressed: _shareCurrent,
          ),
          if (widget.photoIds != null)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: AppLocalizations.of(context)!.deletePhotoTitle,
              onPressed: _deleteCurrent,
            ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              return Semantics(
                label: 'Imagem ${index + 1} de ${widget.images.length}',
                child: InteractiveViewer(
                  child: Center(
                    child: Image.memory(
                      widget.images[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),

          // Left arrow
          if (_currentIndex > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                iconSize: 46,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  final prev = (_currentIndex - 1).clamp(
                    0,
                    widget.images.length - 1,
                  );
                  _controller.animateToPage(
                    prev,
                    duration: AppDurations.pageView,
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),

          // Right arrow
          if (_currentIndex < widget.images.length - 1)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                iconSize: 46,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  final next = (_currentIndex + 1).clamp(
                    0,
                    widget.images.length - 1,
                  );
                  _controller.animateToPage(
                    next,
                    duration: AppDurations.pageView,
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),

          // Dots indicator (bottom center)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (i) {
                final active = i == _currentIndex;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 10 : 6,
                  height: active ? 10 : 6,
                  decoration: BoxDecoration(
                    color: active
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.54),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
