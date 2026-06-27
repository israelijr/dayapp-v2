import 'dart:typed_data';
import 'dart:ui';

import 'package:dayapp/sharing/story_data.dart';
import 'package:dayapp/sharing/templates/template_helpers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// PolaroidStack template:
///
/// - Usado para mais de 5 imagens.
/// - EXPANSIVO: Ocupa toda a tela independente de restrições do widget pai.
/// - Exibe a imagem principal desfocada como fundo total da tela.
class PolaroidStackTemplate extends StatelessWidget {
  final StoryData story;

  const PolaroidStackTemplate({required this.story, super.key});

  @override
  Widget build(BuildContext context) {
    final photos = story.images;
    final displayImages = photos.take(4).toList();
    final colorScheme = Theme.of(context).colorScheme;
    final dateLabel = DateFormat(
      'dd MMM yyyy',
      story.localeName,
    ).format(story.date);

    Widget buildPolaroidCard(Uint8List? image, double width, double height) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: image != null
              ? Image.memory(image, fit: BoxFit.cover)
              : Container(color: colorScheme.surfaceContainerHighest),
        ),
      );
    }

    // Resolve o problema do pai limitando o tamanho: Força o tamanho a ser o da tela
    return Stack(
      children: [
        // 1. Fundo total
        Positioned.fill(
          child: photos.isNotEmpty
              ? Image.memory(photos.first, fit: BoxFit.cover)
              : buildEmptyPhotoBackground(colorScheme),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.5, sigmaY: 5.5),
            child: Container(color: Colors.black.withValues(alpha: 0.03)),
          ),
        ),

        // Gradiente linear
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.35),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // 2. Conteúdo flutuante principal que cresce
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100), // Safe area
              // Área das fotos com altura proporcional ao largura
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = width * 1.2; // Altura fixa proporcional

                  final largeWidth = width * 0.65;
                  final largeHeight = height * 0.35;
                  final smallWidth = width * 0.38;
                  final smallHeight = height * 0.18;

                  return SizedBox(
                    height: height,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Foto Principal
                        Positioned(
                          left: 0,
                          top: height * 0.05,
                          child: Transform.rotate(
                            angle: -0.08,
                            child: buildPolaroidCard(
                              displayImages.isNotEmpty
                                  ? displayImages[0]
                                  : null,
                              largeWidth,
                              largeHeight,
                            ),
                          ),
                        ),
                        // Segunda Foto
                        if (displayImages.length > 1)
                          Positioned(
                            right: 0,
                            top: height * 0.01,
                            child: Transform.rotate(
                              angle: 0.10,
                              child: buildPolaroidCard(
                                displayImages[1],
                                smallWidth,
                                smallHeight,
                              ),
                            ),
                          ),
                        // Terceira Foto
                        if (displayImages.length > 2)
                          Positioned(
                            left: width * 0.14,
                            bottom: height * 0.1,
                            child: Transform.rotate(
                              angle: 0.05,
                              child: buildPolaroidCard(
                                displayImages[2],
                                smallWidth,
                                smallHeight,
                              ),
                            ),
                          ),
                        // Quarta Foto
                        if (displayImages.length > 3)
                          Positioned(
                            right: width * 0.02,
                            bottom: height * 0.05,
                            child: Transform.rotate(
                              angle: -0.06,
                              child: buildPolaroidCard(
                                displayImages[3],
                                smallWidth,
                                smallHeight,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Story Card que cresce
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.onSurface.withValues(alpha: 0.18),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      story.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        color: const Color(0xFF1A1A1A),
                        height: 1.05,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      normalizedDescription(story.description),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        height: 1.6,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateLabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withValues(alpha: 0.70),
                          ),
                        ),
                        if (story.emoticon != null)
                          Text(
                            story.emoticon!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              color: Colors.black.withValues(alpha: 0.40),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'DayApp',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }
}
