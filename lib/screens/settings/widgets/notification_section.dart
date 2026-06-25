import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/notification_preferences_provider.dart';
import '../../../services/notification_preferences_service.dart';
import '../../background_restrictions_info_screen.dart';
import 'shared_widgets.dart';

class NotificationSection extends StatelessWidget {
  const NotificationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(child: SectionTitle(title: loc.notifications)),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                ),
                icon: const Icon(Icons.info_outline, size: 20),
                label: Text(
                  loc.information,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () => _openBackgroundRestrictionsInfoScreen(context),
              ),
            ],
          ),
        ),
        Consumer<NotificationPreferencesProvider>(
          builder: (context, notificationProvider, child) {
            if (notificationProvider.isLoading &&
                !notificationProvider.isLoaded) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(loc.entryNotifications),
                  subtitle: Text(
                    notificationProvider.notificationEnabled
                        ? loc.enabled
                        : loc.disabled,
                  ),
                  trailing: Switch(
                    value: notificationProvider.notificationEnabled,
                    onChanged: (value) {
                      unawaited(
                        notificationProvider.setNotificationEnabled(value),
                      );
                    },
                  ),
                ),
                if (notificationProvider.notificationEnabled)
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(loc.defaultAdvanceTitle),
                    subtitle: Text(
                      NotificationPreferencesService.getLocalizedAdvanceLabel(
                        notificationProvider.notificationAdvance,
                        loc,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showNotificationAdvanceDialog(context),
                    dense: true,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _openBackgroundRestrictionsInfoScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const BackgroundRestrictionsInfoScreen(),
      ),
    );
  }

  Future<void> _showNotificationAdvanceDialog(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final notificationProvider = context
        .read<NotificationPreferencesProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final value = await showDialog<int>(
      context: context,
      builder: (context) => NotificationAdvanceDialog(
        selectedMinutes: notificationProvider.notificationAdvance,
      ),
    );
    if (value == null) return;

    await notificationProvider.setNotificationAdvance(value);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '${loc.notificationAdvanceDefault}: '
          '${NotificationPreferencesService.getLocalizedAdvanceLabel(value, loc)}',
        ),
      ),
    );
  }
}

class NotificationAdvanceDialog extends StatelessWidget {
  const NotificationAdvanceDialog({required this.selectedMinutes, super.key});

  final int selectedMinutes;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(loc.notificationAdvanceTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(loc.notificationAdvancePrompt),
          const SizedBox(height: 16),
          RadioGroup<int>(
            groupValue: selectedMinutes,
            onChanged: (value) {
              if (value == null) return;
              Navigator.of(context).pop(value);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final minutes
                    in NotificationPreferencesService.advanceOptions)
                  RadioListTile<int>(
                    title: Text(
                      NotificationPreferencesService.getLocalizedAdvanceLabel(
                        minutes,
                        loc,
                      ),
                    ),
                    value: minutes,
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.close),
        ),
      ],
    );
  }
}
