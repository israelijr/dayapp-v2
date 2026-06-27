import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

Future<Uint8List> renderStoryShareToImage(
  OverlayState overlayState,
  Widget child,
) async {
  final paintKey = GlobalKey();
  double exportPixelRatio = 2.0;

  final overlayEntry = OverlayEntry(
    builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;
      exportPixelRatio = 1080.0 / screenWidth;

      return Positioned(
        left: -9999,
        top: 0,
        child: Material(
          type: MaterialType.transparency,
          child: RepaintBoundary(
            key: paintKey,
            child: UnconstrainedBox(
              constrainedAxis: Axis.horizontal,
              alignment: Alignment.topCenter,
              child: Container(
                width: screenWidth,
                constraints: BoxConstraints(minHeight: screenWidth * (1920.0 / 1080.0)),
                color: Colors.white,
                child: child,
              ),
            ),
          ),
        ),
      );
    },
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

  final logicalHeight = boundary.size.height;
  final logicalWidth = boundary.size.width;

  double finalPixelRatio = 1080.0 / logicalWidth;
  
  // Limite seguro de textura para evitar downscale da GPU (que causa o texto borrado).
  final maxDimension = logicalHeight > logicalWidth ? logicalHeight : logicalWidth;
  if (maxDimension * finalPixelRatio > 4000) {
    finalPixelRatio = 4000 / maxDimension;
  }

  ui.Image? image;
  try {
    image = await boundary.toImage(pixelRatio: finalPixelRatio);
  } on AssertionError catch (_) {
    await WidgetsBinding.instance.endOfFrame;
    await Future.delayed(const Duration(milliseconds: 150));
    image = await boundary.toImage(pixelRatio: finalPixelRatio);
  }

  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  overlayEntry.remove();

  if (byteData == null) {
    throw StateError('Unable to encode story share image.');
  }

  return byteData.buffer.asUint8List();
}
