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

    final moodEmojis = ['😞', '🙁', '😐', '🙂', '😄'];
    final energyEmojis = ['🔋', '🔋🔋', '🔋🔋🔋'];

    final selectedMoodEmoji = moodEmojis[(selectedMood - 1).clamp(0, 4)];
    final selectedEnergyEmoji = energyEmojis[(selectedEnergy - 1).clamp(0, 2)];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        //border: Border.all(
          //color: theme.colorScheme.outlineVariant,
         //width: 1,
    //),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            // Botão Humor
            Expanded(
              child: _buildBarButton(
                context,
                icon: Icons.face_outlined,
                tooltip: loc.moodLabel,
                color: const Color(0xFFFFF9C4), // Amarelo suave
                textColor: const Color(0xFFFBC02D),
                onTap: onMoodPressed,
                trailing: Text(
                  selectedMoodEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            // Divisor
            Container(
              width: 1,
              height: 44,
              color: theme.colorScheme.outlineVariant,
            ),
            // Botão Energia
            Expanded(
              child: _buildBarButton(
                context,
                icon: Icons.bolt_outlined,
                tooltip: loc.energyLabel,
                color: const Color(0xFFE8F5E9), // Verde suave
                textColor: const Color(0xFF2E7D32),
                onTap: onEnergyPressed,
                trailing: Text(
                  selectedEnergyEmoji,
                  style: const TextStyle(fontSize: 16),
                ),
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
    Widget? trailing,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: textColor,
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
