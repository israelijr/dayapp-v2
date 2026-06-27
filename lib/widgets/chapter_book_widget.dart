import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ChapterBookWidget extends StatelessWidget {
  final String titulo;
  final DateTime? dataUpdate;
  final VoidCallback onTap;
  final String? coverAsset;
  final String? fotoPath;

  const ChapterBookWidget({
    required this.titulo,
    required this.onTap,
    super.key,
    this.dataUpdate,
    this.coverAsset,
    this.fotoPath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = dataUpdate != null
        ? DateFormat('dd/MM/yyyy').format(dataUpdate!)
        : '--/--/----';

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
          topLeft: Radius.circular(4),
          bottomLeft: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
            topLeft: Radius.circular(4),
            bottomLeft: Radius.circular(4),
          ),
          child: Stack(
            children: [
              // Background Image/Color (Random Covers)
              if (coverAsset != null)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                    child: Image.asset(
                      coverAsset!,
                      fit: BoxFit.cover,
                      color: Colors.black.withValues(alpha: 0.25),
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),
                ),
              // Cover color / Spine
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      theme.colorScheme.primary.withValues(
                        alpha: (coverAsset != null || fotoPath != null)
                            ? 0.4
                            : 0.15,
                      ),
                      theme.colorScheme.primary.withValues(
                        alpha: (coverAsset != null || fotoPath != null)
                            ? 0.2
                            : 0.05,
                      ),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.08, 0.12],
                  ),
                ),
              ),
              // Spine Highlight
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.8),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                ),
              ),
              // Pages side decoration
              Positioned(
                right: 0,
                top: 10,
                bottom: 10,
                width: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    5,
                    (_) => Container(
                      height: 1,
                      width: 2,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        height: 1.2,
                        color: (coverAsset != null || fotoPath != null)
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                        shadows: (coverAsset != null || fotoPath != null)
                            ? [
                                const Shadow(
                                  color: Colors.black,
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (fotoPath != null && File(fotoPath!).existsSync())
                      Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.file(
                              File(fotoPath!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (coverAsset != null || fotoPath != null)
                            ? Colors.white.withValues(alpha: 0.9)
                            : theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        dateStr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
