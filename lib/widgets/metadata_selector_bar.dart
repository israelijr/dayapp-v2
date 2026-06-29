import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

class MetadataSelectorBar extends StatelessWidget {
  final VoidCallback onPessoasPressed;
  final VoidCallback onLocalPressed;
  final VoidCallback onTagsPressed;

  const MetadataSelectorBar({
    required this.onPessoasPressed,
    required this.onLocalPressed,
    required this.onTagsPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            // Botão Pessoas
            Expanded(
              child: _buildBarButton(
                context,
                icon: Icons.people_alt_outlined,
                tooltip: loc.pessoasLabel,
                color: const Color(0xFFFFE0D3), // Pêssego suave
                textColor: const Color(0xFFC85A32),
                onTap: onPessoasPressed,
              ),
            ),
            // Divisor
            Container(
              width: 1,
              height: 48,
              color: theme.colorScheme.outlineVariant,
            ),
            // Botão Local
            Expanded(
              child: _buildBarButton(
                context,
                icon: Icons.location_on_outlined,
                tooltip: loc.localLabel,
                color: const Color(0xFFDCE6FF), // Azul suave
                textColor: const Color(0xFF4A69B8),
                onTap: onLocalPressed,
              ),
            ),
            // Divisor
            Container(
              width: 1,
              height: 48,
              color: theme.colorScheme.outlineVariant,
            ),
            // Botão Tags
            Expanded(
              child: _buildBarButton(
                context,
                icon: Icons.tag_outlined,
                tooltip: loc.tagsLabel,
                color: const Color(0xFFF0D6F5), // Lilás suave
                textColor: const Color(0xFF904F9F),
                onTap: onTagsPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
