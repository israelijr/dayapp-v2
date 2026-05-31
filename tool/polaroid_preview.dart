import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:dayapp/sharing/story_data.dart';
import 'package:dayapp/sharing/templates/story_share_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bytes = await _createSamplePhoto();

  runApp(PolaroidPreviewApp(sampleImage: bytes));
}

Future<Uint8List> _createSamplePhoto() async {
  const width = 1080;
  const height = 1080;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(
    recorder,
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
  );

  final gradient = ui.Gradient.linear(
    const Offset(0, 0),
    Offset(width.toDouble(), height.toDouble()),
    [const Color(0xFF8C52FF), const Color(0xFF5FA9FF)],
  );
  canvas.drawRect(
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    Paint()..shader = gradient,
  );

  canvas.drawCircle(
    const Offset(320, 320),
    180,
    Paint()..color = const Color(0x80FFFFFF),
  );
  canvas.drawCircle(
    const Offset(760, 400),
    140,
    Paint()..color = const Color(0x40FFFFFF),
  );
  canvas.drawCircle(
    const Offset(560, 760),
    220,
    Paint()..color = const Color(0x30FFFFFF),
  );

  final iconPaint = Paint()..color = const Color.fromRGBO(255, 255, 255, 0.95);
  final iconRect = Rect.fromCenter(
    center: const Offset(540, 540),
    width: 320,
    height: 240,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(iconRect, const Radius.circular(24)),
    iconPaint,
  );
  canvas.drawCircle(
    const Offset(520, 540),
    60,
    Paint()..color = const Color(0xFF8C52FF),
  );
  canvas.drawRect(
    Rect.fromLTWH(600, 480, 80, 40),
    Paint()..color = const Color(0xFF8C52FF),
  );

  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) {
    throw StateError('Unable to encode preview sample image.');
  }
  return byteData.buffer.asUint8List();
}

class PolaroidPreviewApp extends StatelessWidget {
  final Uint8List sampleImage;

  const PolaroidPreviewApp({required this.sampleImage, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: PolaroidPreviewScreen(sampleImage: sampleImage),
    );
  }
}

class PolaroidPreviewScreen extends StatelessWidget {
  final Uint8List sampleImage;

  const PolaroidPreviewScreen({required this.sampleImage, super.key});

  StoryData _buildSampleStory() {
    return StoryData(
      title: 'Polaroid Nostálgica',
      subtitle: '6 momentos capturados',
      description:
          'Seis fotos em um layout inspirado em polaroids, com bordas suaves e um contador de imagens extras para reforçar a sensação de álbum.',
      emoticon: '📸',
      date: DateTime(2026, 5, 31, 14, 0),
      localeName: 'pt_BR',
      mood: 4,
      energy: 3,
      tags: const ['memória', 'viagem', 'verão'],
      images: List<Uint8List>.filled(6, sampleImage, growable: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final story = _buildSampleStory();

    return Scaffold(
      appBar: AppBar(title: const Text('Polaroid Preview')),
      body: Container(
        color: Colors.grey.shade200,
        child: SafeArea(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: StoryShareWidget(story: story),
          ),
        ),
      ),
    );
  }
}
