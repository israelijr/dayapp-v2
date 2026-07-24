import 'dart:io';

import 'package:dayapp/domain/export_block.dart';
import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../repositories/historia_repository.dart';
import '../../services/thumbnail_service.dart';
import '../story_card.dart';

class ReaderBlockRenderer extends StatelessWidget {
  final ExportBlock block;

  const ReaderBlockRenderer({required this.block, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (block is TitleExportBlock) {
      final titleBlock = block as TitleExportBlock;

      Future<void> openPreview() async {
        final storyId = titleBlock.storyId;
        if (storyId == null) return;
        final repo = HistoriaRepository();
        final historia = await repo.getHistoriaById(storyId);
        if (historia == null) return;

        try {
          final fotos = await repo.getFotosComBytesByHistoria(
            historia.id ?? 0,
          );
          if (fotos.isNotEmpty) {
            final thumbnailsInput = fotos
                .map((foto) => MapEntry('foto_${foto.id}', foto.bytes))
                .toList(growable: false);
            await ThumbnailService().preloadThumbnails(thumbnailsInput);
          }
        } catch (_) {
          // ignore prewarm errors
        }

        if (!context.mounted) return;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoryPreviewScreen(
              historia: historia,
              localeName: AppLocalizations.of(context)!.localeName,
              convertLegacyEmoticon: (em) {
                switch (em) {
                  case 'Feliz':
                    return '😊';
                  case 'Tranquilo':
                    return '😌';
                  case 'Aliviado':
                    return '😮‍💨';
                  case 'Pensativo':
                    return '🤔';
                  case 'Sono':
                    return '😴';
                  case 'Preocupado':
                    return '😟';
                  case 'Assustado':
                    return '😨';
                  case 'Bravo':
                    return '😠';
                  case 'Triste':
                    return '😢';
                  case 'Muito Triste':
                    return '😭';
                  default:
                    return null;
                }
              },
              heroTag:
                  'chapter_story_${historia.id ?? historia.titulo.hashCode}',
              showEditDelete: true,
              showMoodNotes: true,
              showBottomActions: true,
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
        child: GestureDetector(
          onTap: titleBlock.storyId != null ? openPreview : null,
          child: Text(
            titleBlock.text,
            style: GoogleFonts.plusJakartaSans(
              textStyle: Theme.of(context).textTheme.titleLarge,
              color: colorScheme.onSurface,
              height: 1.35,
            ),
          ),
        ),
      );
    }

    if (block is DateExportBlock) {
      final dateBlock = block as DateExportBlock;
      final formattedDate = DateFormat(
        'dd MMM yyyy',
        l10n.localeName,
      ).format(dateBlock.date);

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 2),
        child: Text(
          formattedDate.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            textStyle: Theme.of(context).textTheme.labelMedium,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    if (block is ParagraphExportBlock) {
      final paragraphBlock = block as ParagraphExportBlock;
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
        child: Text(
          paragraphBlock.text,
          style: GoogleFonts.plusJakartaSans(
            textStyle: Theme.of(context).textTheme.bodyLarge,
            height: 1.7,
            color: colorScheme.onSurface,
          ),
        ),
      );
    }

    if (block is ImageExportBlock) {
      final imageBlock = block as ImageExportBlock;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.file(
                File(imageBlock.imagePath),
                fit: BoxFit.cover,
                cacheWidth: 1200,
                errorBuilder: (_, _, _) => Container(
                  height: 180,
                  color: colorScheme.surfaceContainerHigh,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: colorScheme.onSurfaceVariant,
                    size: 28,
                  ),
                ),
              ),
              if (imageBlock.caption != null && imageBlock.caption!.isNotEmpty)
                Container(
                  color: colorScheme.surfaceContainerLowest,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Text(
                    imageBlock.caption!,
                    style: GoogleFonts.plusJakartaSans(
                      textStyle: Theme.of(context).textTheme.bodySmall,
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
