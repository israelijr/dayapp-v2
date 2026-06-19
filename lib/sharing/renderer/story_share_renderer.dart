import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

Future<Uint8List> renderStoryShareToImage(
  OverlayState overlayState,
  Widget child,
) async {
  final paintKey = GlobalKey();
  final overlayEntry = OverlayEntry(
    builder: (context) => Material(
      type: MaterialType.transparency,
      child: Transform.translate(
        offset: const Offset(-9999, 0),
        child: RepaintBoundary(
          key: paintKey,
          child: SizedBox(width: 1080, height: 1920, child: child),
        ),
      ),
    ),
  );

  overlayState.insert(overlayEntry);
  await WidgetsBinding.instance.endOfFrame;
  await Future.delayed(const Duration(milliseconds: 150));

  final boundary =
      paintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) {
    overlayEntry.remove();
    throw StateError('Unable to capture story share image render object.');
  }

  ui.Image? image;
  try {
    image = await boundary.toImage(pixelRatio: 2.0);
  } on AssertionError catch (_) {
    await WidgetsBinding.instance.endOfFrame;
    await Future.delayed(const Duration(milliseconds: 150));
    image = await boundary.toImage(pixelRatio: 2.0);
  }

  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  overlayEntry.remove();

  if (byteData == null) {
    throw StateError('Unable to encode story share image.');
  }

  return byteData.buffer.asUint8List();
}
