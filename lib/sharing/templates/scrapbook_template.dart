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
        children: [
          Text(
            story.title,
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.playfairDisplay(
              fontSize: 34,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
              height: 1.04,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Text(
              normalizedDescription(story.description),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                height: 1.65,
                color: colorScheme.onSurface.withValues(alpha: 0.84),
              ),
            ),
          ),
          const SizedBox(height: 18),
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
          const SizedBox(height: 10),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final height = constraints.maxHeight > 0
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height * 0.6;
        final cardWidth = (width * 0.84).clamp(300.0, 720.0).toDouble();
        final desiredCardHeight = (height * 0.56)
            .clamp(360.0, 620.0)
            .toDouble();
        final photoAreaHeight = (height * 0.30).clamp(180.0, 290.0).toDouble();
        final topPadding = (height * 0.05).clamp(20.0, 54.0).toDouble();
        final bottomPadding = (height * 0.12).clamp(70.0, 130.0).toDouble();
        final contentGap = (height * 0.02).clamp(10.0, 20.0).toDouble();
        final maxCardHeight =
            height - topPadding - bottomPadding - photoAreaHeight - contentGap;
        final cardHeight = desiredCardHeight.clamp(250.0, maxCardHeight);

        return Stack(
          fit: StackFit.expand,
          children: [
            if (backgroundImage != null)
              Image.memory(backgroundImage, fit: BoxFit.cover)
            else
              buildEmptyPhotoBackground(colorScheme),
            Container(
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
            Positioned.fill(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  color: colorScheme.surface.withValues(alpha: 0.06),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(18, topPadding, 18, bottomPadding),
                child: Column(
                  children: [
                    SizedBox(
                      height: photoAreaHeight,
                      child: LayoutBuilder(
                        builder: (context, photoConstraints) {
                          final photoAreaWidth = photoConstraints.maxWidth;
                          final mainWidth = (photoAreaWidth * 0.40)
                              .clamp(145.0, 250.0)
                              .toDouble();
                          final mainHeight = (photoAreaHeight * 0.78)
                              .clamp(132.0, 220.0)
                              .toDouble();
                          final sideWidth = (mainWidth * 0.58)
                              .clamp(96.0, 170.0)
                              .toDouble();
                          final sideHeight = sideWidth * 1.08;
                          final mainLeft = (photoAreaWidth - mainWidth) / 2;
                          final mainTop = (photoAreaHeight - mainHeight) * 0.16;

                          Uint8List? imageAt(int index) {
                            if (displayImages.length > index) {
                              return displayImages[index];
                            }
                            return floatingImages[index];
                          }

                          return Stack(
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
                                left: mainLeft - sideWidth * 0.92,
                                top: mainTop + mainHeight * 0.10,
                                child: SizedBox(
                                  width: sideWidth,
                                  height: sideHeight * 1.52,
                                  child: Transform.rotate(
                                    angle: 0.1,
                                    child: buildPhotoCard(imageAt(1)),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: mainLeft + mainWidth - sideWidth * 0.18,
                                top: mainTop + mainHeight * 0.02,
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
                                left: mainLeft + mainWidth * 0.86,
                                top: mainTop + mainHeight - sideHeight * 0.60,
                                child: SizedBox(
                                  width: sideWidth * 1.2,
                                  height: sideHeight * 1.0,
                                  child: Transform.rotate(
                                    angle: 0.06,
                                    child: buildPhotoCard(imageAt(3)),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: contentGap),
                    SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(38),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
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
                              padding: const EdgeInsets.all(22),
                              child: buildTextContent(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
