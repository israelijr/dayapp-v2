import 'dart:io';

import 'package:dayapp/domain/chapter_export_document.dart';
import 'package:dayapp/domain/chapter_export_photo_selection.dart';
import 'package:dayapp/domain/export_block.dart';
import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:dayapp/providers/chapter_reader_provider.dart';
import 'package:dayapp/providers/premium_provider.dart';
import 'package:dayapp/services/chapter_export_telemetry_service.dart';
import 'package:dayapp/services/chapter_pdf_export_service.dart';
import 'package:dayapp/widgets/chapter_reader/reader_block_renderer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ChapterReaderScreen extends StatelessWidget {
  final int chapterId;

  const ChapterReaderScreen({required this.chapterId, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChapterReaderProvider>(
          create: (_) => ChapterReaderProvider(chapterId: chapterId)..load(),
        ),
        ChangeNotifierProvider<_ChapterExportState>(
          create: (_) => _ChapterExportState(),
        ),
      ],
      child: const _ChapterReaderView(),
    );
  }
}

class _ChapterReaderView extends StatelessWidget {
  const _ChapterReaderView();

  static const ChapterExportTelemetryService _telemetry =
      ChapterExportTelemetryService();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<ChapterReaderProvider>(
      builder: (context, provider, _) {
        final isExporting = context.watch<_ChapterExportState>().isExporting;
        final document = provider.document;
        final title = document?.chapterTitle ?? l10n.chaptersTitle;

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                tooltip: l10n.exportPdf,
                onPressed: isExporting ? null : () => _exportPdf(context),
                icon: isExporting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined),
              ),
            ],
          ),
          body: Stack(
            children: [
              _buildBody(context, provider),
              if (isExporting)
                const Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(
                      color: Color(0x26000000),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportPdf(BuildContext context) async {
    final exportState = context.read<_ChapterExportState>();
    if (exportState.isExporting) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final premium = context.read<PremiumProvider>();
    final provider = context.read<ChapterReaderProvider>();
    final document = provider.document;

    if (!premium.isPremium) {
      _telemetry.logBlockedPremium(document);
      await _showPremiumUpgradeDialog(context, l10n);
      return;
    }

    if (document == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.noStoriesHere)));
      return;
    }

    final exportStopwatch = _telemetry.startExport(document);

    try {
      final preparedDocument = await _prepareDocumentForExport(
        context,
        document,
      );
      if (!context.mounted || preparedDocument == null) {
        return;
      }

      exportState.start();
      const exportService = ChapterPdfExportService();
      final pdfFile = await exportService.export(
        document: preparedDocument,
        localeName: l10n.localeName,
        storyCountLabel: l10n.chapterEntriesCount(preparedDocument.storyCount),
      );

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(pdfFile.path)],
          subject: preparedDocument.chapterTitle,
          text: l10n.exportPdf,
        ),
      );

      _telemetry.logSuccess(preparedDocument, exportStopwatch);
    } catch (e) {
      _telemetry.logFailure(document, exportStopwatch, e);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.exportPdfError(e)),
          action: SnackBarAction(
            label: l10n.tryAgain,
            onPressed: () => _exportPdf(context),
          ),
        ),
      );
    } finally {
      exportState.finish();
    }
  }

  Future<ChapterExportDocument?> _prepareDocumentForExport(
    BuildContext context,
    ChapterExportDocument document,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final choices = _collectStoryPhotoChoices(document, l10n);
    if (choices.isEmpty) {
      return document;
    }

    final selectedImagePathByStoryId = await _showPhotoSelectionDialog(
      context,
      l10n,
      choices,
    );

    if (!context.mounted || selectedImagePathByStoryId == null) {
      return null;
    }

    final filteredBlocks = filterExportBlocksBySelectedImages(
      blocks: document.blocks,
      selectedImagePathByStoryId: selectedImagePathByStoryId,
    );

    return ChapterExportDocument(
      chapterId: document.chapterId,
      userId: document.userId,
      chapterTitle: document.chapterTitle,
      chapterDescription: document.chapterDescription,
      startDate: document.startDate,
      endDate: document.endDate,
      coverImagePath: document.coverImagePath,
      storyCount: document.storyCount,
      blocks: filteredBlocks,
    );
  }

  List<_StoryPhotoChoice> _collectStoryPhotoChoices(
    ChapterExportDocument document,
    AppLocalizations l10n,
  ) {
    final storyTitles = <int, String>{};
    final imageBlocksByStory = <int, List<ImageExportBlock>>{};

    for (final block in document.blocks) {
      final storyId = block.storyId;
      if (storyId == null) {
        continue;
      }

      if (block is TitleExportBlock && block.text.trim().isNotEmpty) {
        storyTitles.putIfAbsent(storyId, () => block.text.trim());
      }

      if (block is ImageExportBlock) {
        imageBlocksByStory.putIfAbsent(storyId, () => <ImageExportBlock>[]);
        imageBlocksByStory[storyId]!.add(block);
      }
    }

    final sortedStoryIds = imageBlocksByStory.keys.toList()..sort();
    return sortedStoryIds
        .map(
          (storyId) => _StoryPhotoChoice(
            storyId: storyId,
            storyTitle:
                storyTitles[storyId] ?? '${l10n.storiesLabel} #$storyId',
            imageBlocks: imageBlocksByStory[storyId]!,
          ),
        )
        .toList(growable: false);
  }

  Future<Map<int, String?>?> _showPhotoSelectionDialog(
    BuildContext context,
    AppLocalizations l10n,
    List<_StoryPhotoChoice> choices,
  ) {
    return showDialog<Map<int, String?>>(
      context: context,
      builder: (dialogContext) {
        final selectedImagePathByStoryId = <int, String?>{
          for (final choice in choices) choice.storyId: null,
        };

        return StatefulBuilder(
          builder: (statefulContext, setState) => AlertDialog(
            title: Text(l10n.chapterExportPhotoSelectionTitle),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.chapterExportPhotoSelectionSubtitle,
                    style: Theme.of(statefulContext).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: choices.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (_, index) {
                        final choice = choices[index];
                        final selectedPath =
                            selectedImagePathByStoryId[choice.storyId];

                        return _StoryPhotoSelectionCard(
                          choice: choice,
                          selectedImagePath: selectedPath,
                          noPhotoLabel: l10n.chapterExportNoPhotoOption,
                          onSelect: (path) {
                            setState(() {
                              selectedImagePathByStoryId[choice.storyId] = path;
                            });
                          },
                          photoLabelBuilder: (position) =>
                              '${l10n.photoTooltip} ${position + 1}',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.close),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(selectedImagePathByStoryId),
                child: Text(l10n.confirm),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showPremiumUpgradeDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.premiumFeature),
        content: Text(l10n.exportPdfPremiumRequired),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pushNamed('/settings');
            },
            child: Text(l10n.insightPremiumCTA),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ChapterReaderProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null || provider.document == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_stories_outlined,
                size: 46,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.noStoriesHere,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  textStyle: Theme.of(context).textTheme.bodyLarge,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: provider.load,
                child: Text(l10n.tryAgain),
              ),
            ],
          ),
        ),
      );
    }

    final document = provider.document!;
    final blocks = document.blocks
        .where(
          (block) =>
              block.storyId != null ||
              (block is ParagraphExportBlock && block.storyId == null),
        )
        .toList(growable: false);

    final period = l10n.chapterPeriod(
      DateFormat('dd/MM/yy', l10n.localeName).format(document.startDate),
      DateFormat('dd/MM/yy', l10n.localeName).format(document.endDate),
    );

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (document.coverImagePath != null &&
            document.coverImagePath!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(
                File(document.coverImagePath!),
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 220,
                  color: colorScheme.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
          child: Text(
            document.chapterTitle,
            style: GoogleFonts.notoSerif(
              textStyle: Theme.of(context).textTheme.headlineSmall,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(
            '$period - ${l10n.chapterEntriesCount(document.storyCount)}',
            style: GoogleFonts.plusJakartaSans(
              textStyle: Theme.of(context).textTheme.labelLarge,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Divider(
          height: 1,
          indent: 20,
          endIndent: 20,
          color: colorScheme.outlineVariant,
        ),
        const SizedBox(height: 8),
        if (blocks.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              l10n.noStoriesHere,
              style: GoogleFonts.plusJakartaSans(
                textStyle: Theme.of(context).textTheme.bodyLarge,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ...blocks.map((block) => ReaderBlockRenderer(block: block)),
      ],
    );
  }
}

class _ChapterExportState extends ChangeNotifier {
  bool _isExporting = false;

  bool get isExporting => _isExporting;

  void start() {
    _isExporting = true;
    notifyListeners();
  }

  void finish() {
    _isExporting = false;
    notifyListeners();
  }
}

class _StoryPhotoChoice {
  final int storyId;
  final String storyTitle;
  final List<ImageExportBlock> imageBlocks;

  const _StoryPhotoChoice({
    required this.storyId,
    required this.storyTitle,
    required this.imageBlocks,
  });
}

class _StoryPhotoSelectionCard extends StatelessWidget {
  final _StoryPhotoChoice choice;
  final String? selectedImagePath;
  final String noPhotoLabel;
  final ValueChanged<String?> onSelect;
  final String Function(int position) photoLabelBuilder;

  const _StoryPhotoSelectionCard({
    required this.choice,
    required this.selectedImagePath,
    required this.noPhotoLabel,
    required this.onSelect,
    required this.photoLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          choice.storyTitle,
          style: GoogleFonts.notoSerif(
            textStyle: Theme.of(context).textTheme.titleMedium,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PhotoOptionTile(
              isSelected: selectedImagePath == null,
              label: noPhotoLabel,
              onTap: () => onSelect(null),
              child: Icon(
                Icons.hide_image_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            for (var index = 0; index < choice.imageBlocks.length; index++)
              _PhotoOptionTile(
                isSelected:
                    selectedImagePath == choice.imageBlocks[index].imagePath,
                label: photoLabelBuilder(index),
                onTap: () => onSelect(choice.imageBlocks[index].imagePath),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(choice.imageBlocks[index].imagePath),
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => ColoredBox(
                      color: colorScheme.surfaceContainerHighest,
                      child: SizedBox(
                        width: 72,
                        height: 72,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _PhotoOptionTile extends StatelessWidget {
  final bool isSelected;
  final String label;
  final VoidCallback onTap;
  final Widget child;

  const _PhotoOptionTile({
    required this.isSelected,
    required this.label,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 96,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 72, width: 72, child: Center(child: child)),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                textStyle: Theme.of(context).textTheme.labelSmall,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
