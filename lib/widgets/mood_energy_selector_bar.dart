import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';

class MoodEnergySelectorBar extends StatelessWidget {
  final int selectedMood;
  final int selectedEnergy;
  final VoidCallback onMoodPressed;
  final VoidCallback onEnergyPressed;

  const MoodEnergySelectorBar({
    required this.selectedMood,
    required this.selectedEnergy,
    required this.onMoodPressed,
    required this.onEnergyPressed,
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
            icon: Icons.face_outlined,
            tooltip: loc.moodLabel,
            color: isDark ? const Color(0xFFFBC02D).withValues(alpha: 0.2) : const Color(0xFFFFF9C4),
            textColor: isDark ? const Color(0xFFFFF9C4) : const Color(0xFFFBC02D),
            onTap: onMoodPressed,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _buildChip(
            context,
            icon: Icons.bolt_outlined,
            tooltip: loc.energyLabel,
            color: isDark ? const Color(0xFF2E7D32).withValues(alpha: 0.2) : const Color(0xFFE8F5E9),
            textColor: isDark ? const Color(0xFFE8F5E9) : const Color(0xFF2E7D32),
            onTap: onEnergyPressed,
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
    Widget? trailing,
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: textColor,
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 4),
                    trailing,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
