import 'dart:io';

import 'package:dayapp/domain/export_block.dart';
import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ReaderBlockRenderer extends StatelessWidget {
  final ExportBlock block;

  const ReaderBlockRenderer({required this.block, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (block is TitleExportBlock) {
      final titleBlock = block as TitleExportBlock;
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
        child: Text(
          titleBlock.text,
          style: GoogleFonts.notoSerif(
            textStyle: Theme.of(context).textTheme.titleLarge,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            height: 1.35,
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
                errorBuilder: (_, __, ___) => Container(
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
