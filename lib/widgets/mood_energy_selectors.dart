import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// Mapeamento do valor de humor (1–5) para emoji e chave de localização.
///
/// Tabela:
///   1 → 😞 Muito difícil
///   2 → 🙁 Difícil
///   3 → 😐 Neutro
///   4 → 🙂 Bom
///   5 → 😄 Muito bom
String moodEmoji(int value) {
  switch (value) {
    case 1:
      return '😞';
    case 2:
      return '🙁';
    case 3:
      return '😐';
    case 4:
      return '🙂';
    case 5:
      return '😄';
    default:
      return '😐';
  }
}

/// Seletor de humor via Slider com 5 posições (1=Muito difícil … 5=Muito bom).
/// Exibe o emoticon e o rótulo do valor atual com animação ao trocar.
class MoodSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const MoodSelector({required this.value, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Tabela de opções: (valor, emoji, rótulo localizado)
    final options = [
      (1, '😞', loc.moodVeryDifficult),
      (2, '🙁', loc.moodDifficult),
      (3, '😐', loc.moodNeutral),
      (4, '🙂', loc.moodGood),
      (5, '😄', loc.moodVeryGood),
    ];

    // Índice seguro (0–4)
    final idx = (value - 1).clamp(0, 4);
    final (_, emoji, label) = options[idx];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Emoticon animado + rótulo do valor atual
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          ),
          child: Column(
            key: ValueKey(value),
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 36, height: 1.1)),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        // Slider
        Slider(
          min: 1,
          max: 5,
          divisions: 4,
          value: value.toDouble().clamp(1.0, 5.0),
          onChanged: (v) => onChanged(v.round()),
        ),
        // Rótulos dos extremos
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '😞 ${loc.moodVeryDifficult}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${loc.moodVeryGood} 😄',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Seletor de energia com três opções: Baixa, Normal, Alta
class EnergySelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const EnergySelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final options = [
      (1, '🔋', loc.energyLow),
      (2, '🔋🔋', loc.energyNormal),
      (3, '🔋🔋🔋', loc.energyHigh),
    ];
    return SegmentedOptions<int>(
      options: options,
      selected: value,
      onChanged: onChanged,
    );
  }
}

/// Widget genérico de seleção segmentada com emoji + rótulo
class SegmentedOptions<T> extends StatelessWidget {
  final List<(T, String, String)> options; // (valor, emoji, rótulo)
  final T selected;
  final ValueChanged<T> onChanged;

  const SegmentedOptions({
    required this.options,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: options.map((opt) {
        final (val, emoji, label) = opt;
        final isSelected = val == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: InkWell(
              onTap: () => onChanged(val),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
