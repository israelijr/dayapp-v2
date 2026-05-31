import 'dart:typed_data';

import 'package:dayapp/l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final displayImages = photos.take(4).toList();
    final extraCount = photos.length > 4 ? photos.length - 4 : 0;
    final colorScheme = Theme.of(context).colorScheme;
    final dateLabel = DateFormat(
      'dd MMM yyyy',
      story.localeName,
    ).format(story.date);

    Widget buildPhotoCard(Uint8List? image) {
      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withValues(alpha: 0.10),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: ColoredBox(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.14,
              ),
              child: image != null
                  ? Image.memory(image, fit: BoxFit.cover)
                  : Container(color: colorScheme.surfaceContainerHighest),
            ),
          ),
        ),
      );
    }

    Widget buildTextContent() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.scrapbookTemplateLabel,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface.withValues(alpha: 0.72),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
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
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(38),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.70),
                    borderRadius: BorderRadius.circular(38),
                    border: Border.all(
                      color: colorScheme.onSurface.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.onSurface.withValues(alpha: 0.10),
                        blurRadius: 30,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          flex: 6,
                          child: AspectRatio(
                            aspectRatio: 1.02,
                            child: LayoutBuilder(
                              builder: (context, photoConstraints) {
                                final photoWidth = photoConstraints.maxWidth;
                                final photoHeight = photoConstraints.maxHeight;
                                final largeWidth = photoWidth * 0.56;
                                final largeHeight = photoHeight * 0.62;
                                final smallWidth = photoWidth * 0.34;
                                final smallHeight = photoHeight * 0.28;

                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      left: 0,
                                      top: photoHeight * 0.06,
                                      child: Transform.rotate(
                                        angle: -0.045,
                                        child: SizedBox(
                                          width: largeWidth,
                                          height: largeHeight,
                                          child: buildPhotoCard(
                                            displayImages.isNotEmpty
                                                ? displayImages[0]
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (displayImages.length > 1)
                                      Positioned(
                                        left: photoWidth * 0.56,
                                        top: photoHeight * 0.04,
                                        child: Transform.rotate(
                                          angle: 0.08,
                                          child: SizedBox(
                                            width: smallWidth,
                                            height: smallHeight,
                                            child: buildPhotoCard(
                                              displayImages[1],
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (displayImages.length > 2)
                                      Positioned(
                                        left: photoWidth * 0.16,
                                        top: photoHeight * 0.52,
                                        child: Transform.rotate(
                                          angle: 0.05,
                                          child: SizedBox(
                                            width: smallWidth,
                                            height: smallHeight,
                                            child: buildPhotoCard(
                                              displayImages[2],
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (displayImages.length > 3)
                                      Positioned(
                                        left: photoWidth * 0.50,
                                        top: photoHeight * 0.38,
                                        child: Transform.rotate(
                                          angle: -0.075,
                                          child: SizedBox(
                                            width: smallWidth,
                                            height: smallHeight,
                                            child: buildPhotoCard(
                                              displayImages[3],
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (extraCount > 0)
                                      Positioned(
                                        left: photoWidth * 0.70,
                                        top: photoHeight * 0.66,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colorScheme.onSurface
                                                .withValues(alpha: 0.72),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(
                                            '+$extraCount',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: colorScheme.surface,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(flex: 4, child: buildTextContent()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
