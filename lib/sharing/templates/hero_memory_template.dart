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
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        final horizontalPadding = width * 0.08;
        const topSafeArea = 100.0;
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
                    offset: const Offset(0, 8),
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

        return IntrinsicHeight(
          child: Stack(
            children: [
              // Fundo
              Positioned.fill(
                child: primaryPhoto != null
                    ? Image.memory(primaryPhoto, fit: BoxFit.cover)
                    : buildEmptyPhotoBackground(colorScheme),
              ),
              Positioned.fill(
                child: Container(
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
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: colorScheme.surface.withValues(alpha: 0.06),
                  ),
                ),
              ),
              // Conteúdo que cresce
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  topSafeArea,
                  horizontalPadding,
                  40,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Área das Miniaturas
                    if (displayPhotos.isNotEmpty)
                      SizedBox(
                        height: thumbSize * 1.2,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: 0,
                              child: SizedBox(
                                width: thumbSize * 0.92,
                                height: thumbSize * 0.92,
                                child: buildThumbnailCard(
                                  displayPhotos[0],
                                  -0.1,
                                ),
                              ),
                            ),
                            if (displayPhotos.length > 1)
                              Positioned(
                                left: width * 0.25,
                                top: 20,
                                child: SizedBox(
                                  width: thumbSize * 0.82,
                                  height: thumbSize * 0.82,
                                  child: buildThumbnailCard(
                                    displayPhotos[1],
                                    0.08,
                                  ),
                                ),
                              ),
                            if (displayPhotos.length > 2)
                              Positioned(
                                right: 0,
                                child: SizedBox(
                                  width: thumbSize,
                                  height: thumbSize,
                                  child: buildThumbnailCard(
                                    displayPhotos[2],
                                    0.13,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Card de Texto
                    ClipRRect(
                      borderRadius: BorderRadius.circular(34),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          padding: EdgeInsets.fromLTRB(
                            width * 0.06,
                            32,
                            width * 0.06,
                            28,
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
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                story.title,
                                softWrap: true,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: width * 0.082,
                                  color: colorScheme.onSurface,
                                  height: 1.03,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                normalizedDescription(story.description),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: width * 0.039,
                                  height: 1.45,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.9,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
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
                                    const SizedBox(width: 8),
                                    Text(
                                      story.emoticon!,
                                      style: TextStyle(
                                        fontSize: width * 0.05,
                                        height: 1,
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
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
