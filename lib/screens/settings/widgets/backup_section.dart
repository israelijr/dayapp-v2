import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'shared_widgets.dart';

class BackupSection extends StatelessWidget {
  const BackupSection({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: loc.backup),
        ListTile(
          leading: const Icon(Icons.folder_zip),
          title: Text(loc.manageCompleteBackup),
          subtitle: loc.backupWithVideosZip.isEmpty
              ? null
              : Text(loc.backupWithVideosZip),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => Navigator.pushNamed(context, '/backup-manager'),
        ),
      ],
    );
  }
}
