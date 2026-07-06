import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/generated/app_localizations.dart';

class ContinuaSelectionModal extends StatelessWidget {
  final int? initialValue;

  const ContinuaSelectionModal({
    this.initialValue,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    // Cores e texturas mapeadas do padrão de pessoas, local, tags e energia do app
    final options = [
      (
        1,
        '❌',
        loc.continuaNo,
        isDark ? const Color(0xFFC85A32).withValues(alpha: 0.15) : const Color(0xFFFFE0D3), // Laranja/Vermelho sutil
        isDark ? const Color(0xFFFFE0D3) : const Color(0xFFC85A32)
      ),
      (
        2,
        '🤷',
        loc.continuaDontKnow,
        isDark ? const Color(0xFF4A69B8).withValues(alpha: 0.15) : const Color(0xFFDCE6FF), // Azul sutil
        isDark ? const Color(0xFFDCE6FF) : const Color(0xFF4A69B8)
      ),
      (
        3,
        '⏳',
        loc.continuaMaybe,
        isDark ? const Color(0xFF904F9F).withValues(alpha: 0.15) : const Color(0xFFF0D6F5), // Roxo sutil
        isDark ? const Color(0xFFF0D6F5) : const Color(0xFF904F9F)
      ),
      (
        4,
        '✅',
        loc.continuaYes,
        isDark ? const Color(0xFF2E7D32).withValues(alpha: 0.15) : const Color(0xFFE8F5E9), // Verde sutil
        isDark ? const Color(0xFFE8F5E9) : const Color(0xFF2E7D32)
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header super leve
            Row(
              children: [
                Icon(
                  Icons.arrow_forward_rounded,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    loc.continuaQuestion,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w500, // Título leve, sem bold
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Opções compactas e delicadas
            ...options.map((opt) {
              final (val, emoji, label, bgColor, textColor) = opt;
              final isSelected = val == initialValue;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Material(
                  color: isSelected ? bgColor : theme.colorScheme.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isSelected
                          ? textColor
                          : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => Navigator.pop(context, val),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), // Mais compacto
                      child: Row(
                        children: [
                          Text(
                            emoji,
                            style: const TextStyle(fontSize: 20), // Emoji menor
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              label,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? textColor : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: textColor,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
