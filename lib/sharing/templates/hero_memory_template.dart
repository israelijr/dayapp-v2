import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dayapp/sharing/story_data.dart';
import 'package:dayapp/sharing/templates/template_helpers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// HeroMemory template:
///
/// - Usado para 0 a 3 imagens.
/// - Exibe uma foto principal grande no fundo quando há imagem.
/// - Se não há imagem, mantém o placeholder interno atual.
/// - Mostra um bloco de texto opaco na parte inferior com título,
///   descrição breve e data.
class HeroMemoryTemplate extends StatelessWidget {
  final StoryData story;

  // Construtor corrigido aqui:
  const HeroMemoryTemplate({required this.story, super.key});

  @override
  Widget build(BuildContext context) {
    final photos = story.images;
    // Pega até 3 fotos sem duplicar nenhuma via módulo
    final displayPhotos = photos.take(3).toList(growable: false);
    final primaryPhoto = photos.isNotEmpty ? photos.first : null;

    final dateLabel = DateFormat(
      'dd MMM yyyy',
      story.localeName,
    ).format(story.date);
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final height = constraints.maxHeight > 0
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height * 0.6;
        final horizontalPadding = width * 0.08;
        final verticalPadding = height * 0.1;
        final cardHeight = height * 0.56;
        final thumbSize = width * 0.28;

        Widget buildThumbnailCard(Uint8List imageBytes, double radius) {
          return Transform.rotate(
            angle: radius,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colorScheme.surface.withValues(alpha: 0.34),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurface.withValues(alpha: 0.24),
                    blurRadius: 18,
                    offset: Offset(0, height * 0.014),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.memory(imageBytes, fit: BoxFit.cover),
              ),
            ),
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            if (primaryPhoto != null)
              Image.memory(primaryPhoto, fit: BoxFit.cover)
            else
              buildEmptyPhotoBackground(colorScheme),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.onSurface.withValues(alpha: 0.12),
                    colorScheme.onSurface.withValues(alpha: 0.44),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: colorScheme.surface.withValues(alpha: 0.06),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: double.infinity,
                      height: cardHeight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(34),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: Container(
                            padding: EdgeInsets.fromLTRB(
                              width * 0.06,
                              height * 0.04,
                              width * 0.06,
                              height * 0.028,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.surface.withValues(alpha: 0.44),
                                  colorScheme.surfaceContainerLowest.withValues(
                                    alpha: 0.3,
                                  ),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(34),
                              border: Border.all(
                                color: colorScheme.surface.withValues(
                                  alpha: 0.52,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.26,
                                  ),
                                  blurRadius: 30,
                                  offset: Offset(0, height * 0.014),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  story.title,
                                  softWrap: true,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: width * 0.082,
                                    color: colorScheme.onSurface,
                                    height: 1.03,
                                  ),
                                ),
                                SizedBox(height: height * 0.018),
                                Expanded(
                                  child: Text(
                                    normalizedDescription(story.description),
                                    maxLines: 10,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: width * 0.039,
                                      height: 1.45,
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.9,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: height * 0.014),
                                Row(
                                  children: [
                                    Text(
                                      dateLabel,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: width * 0.036,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    if (story.emoticon != null &&
                                        story.emoticon!.isNotEmpty) ...[
                                      SizedBox(width: width * 0.024),
                                      Text(
                                        story.emoticon!,
                                        style: TextStyle(
                                          fontSize: width * 0.05,
                                          height: 1,
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.66),
                                        ),
                                      ),
                                    ],
                                    const Spacer(),
                                    Text(
                                      'DayApp',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: width * 0.033,
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Renderiza condicionalmente as miniaturas baseado no número real de imagens
                  if (displayPhotos.isNotEmpty)
                    Positioned(
                      top: 0,
                      left: width * 0.02,
                      child: SizedBox(
                        width: thumbSize * 0.92,
                        height: thumbSize * 0.92,
                        child: buildThumbnailCard(displayPhotos[0], -0.1),
                      ),
                    ),
                  if (displayPhotos.length > 1)
                    Positioned(
                      top: height * 0.03,
                      left: width * 0.3,
                      child: SizedBox(
                        width: thumbSize * 0.82,
                        height: thumbSize * 0.82,
                        child: buildThumbnailCard(displayPhotos[1], 0.08),
                      ),
                    ),
                  if (displayPhotos.length > 2)
                    Positioned(
                      top: height * 0.005,
                      right: width * 0.02,
                      child: SizedBox(
                        width: thumbSize,
                        height: thumbSize,
                        child: buildThumbnailCard(displayPhotos[2], 0.13),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
