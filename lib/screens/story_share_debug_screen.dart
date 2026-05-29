import 'dart:io';
import 'dart:ui' as ui;

import 'package:dayapp/sharing/story_data.dart';
import 'package:dayapp/sharing/templates/story_share_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class StoryShareDebugScreen extends StatefulWidget {
  const StoryShareDebugScreen({super.key});

  @override
  State<StoryShareDebugScreen> createState() => _StoryShareDebugScreenState();
}

class _StoryShareDebugScreenState extends State<StoryShareDebugScreen> {
  final GlobalKey _previewKey = GlobalKey();
  String? _savedPath;
  bool _isSaving = false;

  StoryData _buildSampleStory() {
    return StoryData(
      title: 'Praia de Verão',
      subtitle: 'Lembrança de fim de tarde',
      description:
          'Um dia leve com sol, amigos e mar. A brisa suave trouxe risos e memórias.',
      emoticon: '🏖️',
      date: DateTime(2026, 5, 29, 18, 30),
      localeName: 'pt_BR',
      mood: 4,
      energy: 3,
      tags: const ['férias', 'amizade'],
      images: const [],
    );
  }

  Future<void> _savePreviewImage() async {
    final renderObject = _previewKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final ui.Image image = await renderObject.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/dayapp_story_share_debug.png');
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      setState(() => _savedPath = file.path);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final storyData = _buildSampleStory();

    return Scaffold(
      appBar: AppBar(title: const Text('Preview de Compartilhamento')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: Material(
                    elevation: 4,
                    shadowColor: Colors.black12,
                    borderRadius: BorderRadius.circular(32),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: RepaintBoundary(
                        key: _previewKey,
                        child: StoryShareWidget(story: storyData),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar preview como PNG'),
                  onPressed: _isSaving ? null : _savePreviewImage,
                ),
                const SizedBox(height: 12),
                if (_savedPath != null) ...[
                  Text(
                    'Imagem salva em:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _savedPath!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
