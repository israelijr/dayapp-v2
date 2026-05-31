import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BackupSuggestionDialog extends StatelessWidget {
  final int pendingCount;
  final VoidCallback onPerformBackup;

  const BackupSuggestionDialog({
    required this.pendingCount,
    required this.onPerformBackup,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/image/Fazendo backup de maneira amigável.png',
            height: 140,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.unsavedBackups(pendingCount),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.backupRecommendation,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.45,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: onPerformBackup,
          child: Text(l10n.performBackup),
        ),
      ],
    );
  }
}
