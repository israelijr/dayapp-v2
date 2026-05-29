import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dayapp/sharing/engine/template_selector.dart';
import 'package:dayapp/sharing/story_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StoryShareWidget extends StatelessWidget {
  final StoryData story;

  const StoryShareWidget({required this.story, super.key});

  @override
  Widget build(BuildContext context) {
    final selectedTemplate = StoryShareTemplateSelector.selectTemplate(story);
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: _buildTemplate(context, selectedTemplate),
    );
  }

  Widget _buildTemplate(
    BuildContext context,
    StoryShareTemplateType templateType,
  ) {
    switch (templateType) {
      case StoryShareTemplateType.heroMemory:
        return _buildHeroMemory(context);
      case StoryShareTemplateType.scrapbook:
        return _buildScrapbook(context);
      case StoryShareTemplateType.minimalTimeline:
        return _buildMinimalTimeline(context);
    }
  }

  Widget _buildHeroMemory(BuildContext context) {
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
              _buildEmptyPhotoBackground(colorScheme),
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
                          child: buildPhotoCard(primaryPhoto, -0.025),
                        ),
                        SizedBox(width: innerGap),
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              Expanded(
                                child: buildPhotoCard(
                                  secondaryPhotos.isNotEmpty
                                      ? secondaryPhotos[0]
                                      : null,
                                  0.04,
                                ),
                              ),
                              SizedBox(height: innerGap),
                              Expanded(
                                child: buildPhotoCard(
                                  secondaryPhotos.length > 1
                                      ? secondaryPhotos[1]
                                      : null,
                                  -0.03,
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
                          if (story.emoticon != null &&
                              story.emoticon!.isNotEmpty)
                            Text(
                              story.emoticon!,
                              style: TextStyle(
                                fontSize: 28,
                                height: 1,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.40,
                                ),
                              ),
                            ),
                          if (story.emoticon != null &&
                              story.emoticon!.isNotEmpty)
                            SizedBox(height: height * 0.01),
                          Text(
                            story.subtitle ?? 'Memória',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.78,
                              ),
                            ),
                          ),
                          SizedBox(height: height * 0.01),
                          Text(
                            story.title,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: width * 0.052,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                              height: 1.02,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            dateLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: height * 0.015),
                          Text(
                            _normalizedDescription(story.description),
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

  Widget _buildEmptyPhotoBackground(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
            colorScheme.surface.withValues(alpha: 0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.photo,
          size: 80,
          color: colorScheme.onSurface.withValues(alpha: 0.22),
        ),
      ),
    );
  }

  Widget _buildScrapbook(BuildContext context) {
    final photos = story.images;
    final hasPhotos = photos.isNotEmpty;
    final displayImages = photos.take(3).toList();
    final extraCount = photos.length > 3 ? photos.length - 3 : 0;
    final colorScheme = Theme.of(context).colorScheme;
    final dateLabel = DateFormat(
      'dd MMM yyyy',
      story.localeName,
    ).format(story.date);

    Widget buildPhotoTile(Uint8List? image) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: colorScheme.surface,
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: image != null
              ? Image.memory(image, fit: BoxFit.cover)
              : Container(color: colorScheme.surfaceContainerHighest),
        ),
      );
    }

    Widget buildTextContent({required bool expanded}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            story.title,
            softWrap: true,
            overflow: TextOverflow.visible,
            style: GoogleFonts.playfairDisplay(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            flex: expanded ? 3 : 1,
            child: Text(
              _normalizedDescription(story.description),
              maxLines: expanded ? 6 : 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                height: 1.6,
                color: colorScheme.onSurface.withValues(alpha: 0.88),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (story.emoticon != null && story.emoticon!.isNotEmpty)
                    Text(
                      story.emoticon!,
                      style: GoogleFonts.plusJakartaSans(fontSize: 18),
                    ),
                  if (story.emoticon != null && story.emoticon!.isNotEmpty)
                    const SizedBox(width: 8),
                  Text(
                    _moodLabel(story.mood),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.76),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                dateLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.76),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.58),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: colorScheme.onSurface.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.onSurface.withValues(alpha: 0.12),
                        blurRadius: 32,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (hasPhotos) ...[
                          Expanded(
                            flex: 5,
                            child: AspectRatio(
                              aspectRatio: 1.05,
                              child: LayoutBuilder(
                                builder: (context, photoConstraints) {
                                  final photoWidth = photoConstraints.maxWidth;
                                  final photoHeight =
                                      photoConstraints.maxHeight;
                                  final largeWidth = photoWidth * 0.55;
                                  final largeHeight = photoHeight * 0.62;
                                  final smallWidth = photoWidth * 0.38;
                                  final smallHeight = photoHeight * 0.44;

                                  return Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        left: 0,
                                        top: photoHeight * 0.06,
                                        child: Transform.rotate(
                                          angle: -0.04,
                                          child: SizedBox(
                                            width: largeWidth,
                                            height: largeHeight,
                                            child: buildPhotoTile(
                                              displayImages[0],
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (displayImages.length > 1)
                                        Positioned(
                                          left: largeWidth - smallWidth * 0.08,
                                          top: photoHeight * 0.12,
                                          child: Transform.rotate(
                                            angle: 0.02,
                                            child: SizedBox(
                                              width: smallWidth,
                                              height: smallHeight,
                                              child: buildPhotoTile(
                                                displayImages[1],
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (displayImages.length > 2)
                                        Positioned(
                                          left: largeWidth - smallWidth * 0.01,
                                          top: photoHeight * 0.44,
                                          child: Transform.rotate(
                                            angle: -0.05,
                                            child: SizedBox(
                                              width: smallWidth,
                                              height: smallHeight,
                                              child: buildPhotoTile(
                                                displayImages[2],
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (extraCount > 0 &&
                                          displayImages.length > 2)
                                        Positioned(
                                          left: largeWidth + smallWidth * 0.53,
                                          top: photoHeight * 0.75,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorScheme.onSurface
                                                  .withValues(alpha: 0.64),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              '+$extraCount',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
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
                        ],
                        Expanded(
                          flex: hasPhotos ? 4 : 9,
                          child: buildTextContent(expanded: !hasPhotos),
                        ),
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

  String _moodLabel(int value) {
    switch (value) {
      case 1:
        return 'Muito difícil';
      case 2:
        return 'Difícil';
      case 3:
        return 'Neutro';
      case 4:
        return 'Bom';
      case 5:
        return 'Muito bom';
      default:
        return 'Neutro';
    }
  }

  String _normalizedDescription(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return '';
    }

    final trimmed = raw.trim();
    if (!trimmed.startsWith('[') && !trimmed.startsWith('{')) {
      return trimmed;
    }

    try {
      final decoded = json.decode(trimmed);
      final buffer = StringBuffer();

      void extract(dynamic value) {
        if (value is String) {
          buffer.write(value);
        } else if (value is Map) {
          if (value.containsKey('insert')) {
            extract(value['insert']);
          } else {
            for (final item in value.values) {
              extract(item);
            }
          }
        } else if (value is List) {
          for (final item in value) {
            extract(item);
          }
        }
      }

      extract(decoded);
      final text = buffer.toString().trim();
      return text.isEmpty ? trimmed : text;
    } catch (_) {
      return trimmed;
    }
  }

  Widget _buildMinimalTimeline(BuildContext context) {
    final primary = story.images.isNotEmpty ? story.images.first : null;
    final colorScheme = Theme.of(context).colorScheme;
    final dateLabel = DateFormat.yMMMMd(story.localeName).format(story.date);

    return Column(
      children: [
        Expanded(
          flex: 7,
          child: Container(
            width: double.infinity,
            color: colorScheme.surfaceContainerHighest,
            child: primary != null
                ? Image.memory(primary, fit: BoxFit.cover)
                : Container(color: colorScheme.surfaceContainerHighest),
          ),
        ),
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 40, 40, 52),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story.subtitle ?? dateLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    letterSpacing: 0.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  story.title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 42,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: Text(
                    _normalizedDescription(story.description),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      height: 1.7,
                      color: colorScheme.onSurface.withValues(alpha: 0.9),
                    ),
                    overflow: TextOverflow.fade,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: story.tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '#$tag',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
