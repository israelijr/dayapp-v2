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

  const HeroMemoryTemplate({required this.story, super.key});

  @override
  Widget build(BuildContext context) {
    final primaryPhoto = story.images.isNotEmpty ? story.images.first : null;
    final secondaryPhotos = story.images.length > 1
        ? story.images.skip(1).take(2).toList()
        : <Uint8List>[];
    final dateLabel = DateFormat(
      'dd MMM yyyy',
      story.localeName,
    ).format(story.date);
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final horizontalPadding = width * 0.045;
        final verticalPadding = height * 0.045;
        final innerGap = width * 0.035;
        final smallWidth = width * 0.28;
        final smallHeight = height * 0.23;

        Widget buildPhotoCard(Uint8List? bytes, double rotation) {
          return Transform.rotate(
            angle: rotation,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: colorScheme.surface.withValues(alpha: 0.18),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurface.withValues(alpha: 0.18),
                    blurRadius: 22,
                    offset: Offset(0, height * 0.014),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: bytes != null
                    ? Image.memory(bytes, fit: BoxFit.cover)
                    : Container(color: colorScheme.surfaceContainerHighest),
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
                    colorScheme.onSurface.withValues(alpha: 0.22),
                    colorScheme.onSurface.withValues(alpha: 0.06),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(color: Colors.transparent),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 6,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Transform.rotate(
                              angle: -0.06,
                              child: SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: buildPhotoCard(primaryPhoto, 0),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: innerGap),
                        SizedBox(
                          width: width * 0.32,
                          child: Column(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Transform.translate(
                                    offset: const Offset(-25, 0),
                                    child: Transform.rotate(
                                      angle: 0.06,
                                      child: SizedBox(
                                        width: smallWidth + 20,
                                        height: smallHeight,
                                        child: buildPhotoCard(
                                          secondaryPhotos.isNotEmpty
                                              ? secondaryPhotos[0]
                                              : null,
                                          0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: innerGap),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Transform.translate(
                                    offset: const Offset(-20, 0),
                                    child: Transform.rotate(
                                      angle: -0.065,
                                      child: SizedBox(
                                        width: smallWidth + 150,
                                        height: smallHeight + 80,
                                        child: buildPhotoCard(
                                          secondaryPhotos.length > 1
                                              ? secondaryPhotos[1]
                                              : null,
                                          0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: innerGap),
                  Expanded(
                    flex: 4,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(width * 0.028),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: colorScheme.onSurface.withValues(alpha: 0.08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.06,
                            ),
                            blurRadius: 28,
                            offset: Offset(0, height * 0.012),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story.title,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: width * 0.052,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                              height: 1.02,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Text(
                              normalizedDescription(story.description),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                height: 1.5,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.88,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                dateLabel,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (story.emoticon != null &&
                                  story.emoticon!.isNotEmpty) ...[
                                const SizedBox(width: 10),
                                Text(
                                  story.emoticon!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    height: 1,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.54,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
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
