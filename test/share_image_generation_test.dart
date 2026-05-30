import 'dart:io';
import 'dart:typed_data';

import 'package:dayapp/models/historia.dart';
import 'package:dayapp/sharing/renderer/story_share_renderer.dart';
import 'package:dayapp/sharing/story_data.dart';
import 'package:dayapp/sharing/templates/story_share_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('generate story share image', (WidgetTester tester) async {
    final pngBytes = Uint8List.fromList([
      137,
      80,
      78,
      71,
      13,
      10,
      26,
      10,
      0,
      0,
      0,
      13,
      73,
      72,
      68,
      82,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      1,
      8,
      6,
      0,
      0,
      0,
      31,
      21,
      196,
      137,
      0,
      0,
      0,
      12,
      73,
      68,
      65,
      84,
      8,
      153,
      99,
      248,
      255,
      255,
      63,
      0,
      5,
      254,
      2,
      254,
      165,
      42,
      236,
      17,
      0,
      0,
      0,
      0,
      73,
      69,
      78,
      68,
      174,
      66,
      96,
      130,
    ]);

    final historia = Historia(
      userId: 'test-user',
      titulo: 'Praia de verão',
      data: DateTime(2026, 5, 29, 18, 30),
      descricao: 'Um dia leve com sol, amigos e mar.',
      emoticon: '🏖️',
      assunto: 'Verão',
      tag: 'férias',
      humor: 4,
      energia: 3,
    );

    late OverlayState overlayState;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              overlayState = Overlay.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Uint8List? bytes = await tester.runAsync<Uint8List?>(() async {
      final storyData = StoryData.fromHistoria(historia, [
        pngBytes,
        pngBytes,
        pngBytes,
      ], localeName: 'pt_BR');

      return await renderStoryShareToImage(
        overlayState,
        StoryShareWidget(story: storyData),
      );
    });

    final Uint8List typedBytes = bytes!;
    final output = File('build/generated_story_share.png');
    await output.create(recursive: true);
    await output.writeAsBytes(typedBytes);

    expect(typedBytes, isNotEmpty);
    expect(output.existsSync(), isTrue);
  });
}
