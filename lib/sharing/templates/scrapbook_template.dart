import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dayapp/sharing/story_data.dart';
import 'package:dayapp/sharing/templates/template_helpers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Scrapbook template:
///
/// - Usado para 4 a 5 imagens.
/// - Organiza as fotos em um layout de página de álbum com um bloco
///   de texto à direita.
/// - Mostra o título, descrição, data e humor.
/// - Não usa imagem de fundo externa; a textura vem do painel interno.
class ScrapbookTemplate extends StatelessWidget {
  final StoryData story;

  const ScrapbookTemplate({required this.story, super.key});

  @override
  Widget build(BuildContext context) {
    final photos = story.images;
    final displayImages = photos.take(4).toList(growable: false);
    final backgroundImage = photos.isNotEmpty ? photos.first : null;
    final floatingImages = List<Uint8List?>.generate(
      4,
      (index) => photos.isNotEmpty ? photos[index % photos.length] : null,
    );
    final colorScheme = Theme.of(context).colorScheme;
    final dateLabel = DateFormat(
      'dd MMM yyyy',
      story.localeName,
    ).format(story.date);

    Widget buildPhotoCard(Uint8List? image) {
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withValues(alpha: 0.10),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.surface.withValues(alpha: 0.56),
            width: 1.8,
          ),
        ),
        child: image != null
            ? Image.memory(image, fit: BoxFit.cover)
            : Container(color: colorScheme.surfaceContainerHighest),
      );
    }

    Widget buildTextContent() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            story.title,
            softWrap: true,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              color: colorScheme.onSurface,
              height: 1.04,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            normalizedDescription(story.description),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              height: 1.65,
              color: colorScheme.onSurface.withValues(alpha: 0.84),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                moodLabel(context, story.mood),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                dateLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w600,
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
                color: colorScheme.onSurface.withValues(alpha: 0.64),
              ),
            ),
          ),
        ],
      );
    }

    return IntrinsicHeight(
      child: Stack(
        children: [
          // Fundo
          Positioned.fill(
            child: backgroundImage != null
                ? Image.memory(backgroundImage, fit: BoxFit.cover)
                : buildEmptyPhotoBackground(colorScheme),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.onSurface.withValues(alpha: 0.14),
                    colorScheme.onSurface.withValues(alpha: 0.38),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: colorScheme.surface.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Conteúdo que cresce
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 100, 18, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Área das Fotos
                LayoutBuilder(
                  builder: (context, constraints) {
                    final photoAreaWidth = constraints.maxWidth.isFinite
                        ? constraints.maxWidth
                        : MediaQuery.of(context).size.width - 36;
                    final photoAreaHeight = photoAreaWidth * 0.6;
                    final mainWidth = photoAreaWidth * 0.45;
                    final mainHeight = photoAreaHeight * 0.75;
                    final sideWidth = mainWidth * 0.65;
                    final sideHeight = sideWidth * 1.1;

                    final mainLeft = (photoAreaWidth - mainWidth) / 2;
                    final mainTop = (photoAreaHeight - mainHeight) / 2;

                    Uint8List? imageAt(int index) {
                      if (displayImages.length > index) {
                        return displayImages[index];
                      }
                      return floatingImages[index];
                    }

                    return SizedBox(
                      height: photoAreaHeight,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: mainLeft,
                            top: mainTop,
                            child: SizedBox(
                              width: mainWidth,
                              height: mainHeight,
                              child: Transform.rotate(
                                angle: -0.03,
                                child: buildPhotoCard(imageAt(0)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: mainLeft - sideWidth * 0.7,
                            top: mainTop + 20,
                            child: SizedBox(
                              width: sideWidth,
                              height: sideHeight,
                              child: Transform.rotate(
                                angle: 0.1,
                                child: buildPhotoCard(imageAt(1)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: mainLeft + mainWidth - sideWidth * 0.3,
                            top: mainTop - 10,
                            child: SizedBox(
                              width: sideWidth,
                              height: sideHeight,
                              child: Transform.rotate(
                                angle: 0.09,
                                child: buildPhotoCard(imageAt(2)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: mainLeft + mainWidth * 0.7,
                            bottom: -10,
                            child: SizedBox(
                              width: sideWidth * 1.1,
                              height: sideHeight * 0.9,
                              child: Transform.rotate(
                                angle: 0.06,
                                child: buildPhotoCard(imageAt(3)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    );
                  },
                ),
                const SizedBox(height: 30),
                // Card de Texto que cresce
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = constraints.maxWidth.isFinite
                        ? constraints.maxWidth * 0.85
                        : 300.0;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(38),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          width: cardWidth,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.surface.withValues(alpha: 0.50),
                                colorScheme.surfaceContainerLow.withValues(
                                  alpha: 0.30,
                                ),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(38),
                            border: Border.all(
                              color: colorScheme.surface.withValues(
                                alpha: 0.56,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.22,
                                ),
                                blurRadius: 30,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(26),
                            child: buildTextContent(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
