import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:dayapp/sharing/story_data.dart';
import 'package:dayapp/sharing/templates/story_share_widget.dart';
import 'package:flutter/material.dart';

enum ShareFormat { image, pdf }

class StorySharePreviewScreen extends StatelessWidget {
  final StoryData story;

  const StorySharePreviewScreen({required this.story, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                StoryShareWidget(story: story),
                // Espaço extra no final para não ficar colado no botão de compartilhar
                const SizedBox(height: 100),
              ],
            ),
          ),
          // Botões no topo (Close) e rodapé (Share)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: IconButton.filled(
              onPressed: () => Navigator.of(context).pop(null),
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surface.withValues(alpha: 0.7),
                foregroundColor: colorScheme.onSurface,
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: FilledButton.icon(
                onPressed: () => _showShareOptions(context, l10n),
                icon: const Icon(Icons.share),
                label: Text(l10n.share),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showShareOptions(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Opções',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Exportar como Imagem'),
              subtitle: const Text('Ótimo para redes sociais.'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pop(ShareFormat.image);
              },
            ),
            ListTile(
              leading: const Icon(Icons.html),
              title: const Text('Exportar como HTML'),
              subtitle: const Text('Inclui todas as imagens.'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pop(ShareFormat.pdf);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
