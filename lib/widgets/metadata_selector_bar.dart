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
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: _buildChip(
            context,
            icon: Icons.people_alt_outlined,
            tooltip: loc.pessoasLabel,
            color: isDark ? const Color(0xFFC85A32).withValues(alpha: 0.2) : const Color(0xFFFFE0D3),
            textColor: isDark ? const Color(0xFFFFE0D3) : const Color(0xFFC85A32),
            onTap: onPessoasPressed,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _buildChip(
            context,
            icon: Icons.location_on_outlined,
            tooltip: loc.localLabel,
            color: isDark ? const Color(0xFF4A69B8).withValues(alpha: 0.2) : const Color(0xFFDCE6FF),
            textColor: isDark ? const Color(0xFFDCE6FF) : const Color(0xFF4A69B8),
            onTap: onLocalPressed,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _buildChip(
            context,
            icon: Icons.tag_outlined,
            tooltip: loc.tagsLabel,
            color: isDark ? const Color(0xFF904F9F).withValues(alpha: 0.2) : const Color(0xFFF0D6F5),
            textColor: isDark ? const Color(0xFFF0D6F5) : const Color(0xFF904F9F),
            onTap: onTagsPressed,
          ),
        ),
      ],
    );
  }

  Widget _buildChip(
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
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(
                icon,
                size: 20,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
