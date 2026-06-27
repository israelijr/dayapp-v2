import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/pin_provider.dart';
import '../providers/settings_security_provider.dart';
import 'settings/widgets/backup_section.dart';
import 'settings/widgets/language_section.dart';
import 'settings/widgets/notification_section.dart';
import 'settings/widgets/premium_section.dart';
import 'settings/widgets/security_section.dart';
import 'settings/widgets/theme_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.securityProvider});

  final SettingsSecurityProvider? securityProvider;

  @override
  Widget build(BuildContext context) {
    final providedSecurityProvider = securityProvider;
    if (providedSecurityProvider != null) {
      return ChangeNotifierProvider.value(
        value: providedSecurityProvider,
        child: const _SettingsView(),
      );
    }

    final auth = context.read<AuthProvider>();

    return ChangeNotifierProvider(
      create: (context) => SettingsSecurityProvider(
        pinProvider: context.read<PinProvider>(),
        userId: auth.user?.id,
      )..load(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenTheme = theme.copyWith(
      textTheme: GoogleFonts.plusJakartaSansTextTheme(theme.textTheme),
      primaryTextTheme: GoogleFonts.plusJakartaSansTextTheme(
        theme.primaryTextTheme,
      ),
    );

    return Theme(
      data: screenTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            loc.settings,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              color:
                  theme.appBarTheme.foregroundColor ??
                  theme.colorScheme.primary,
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            children: const [
              SizedBox(height: 16),
              PremiumSection(),
              Divider(),
              ThemeSection(),
              Divider(),
              LanguageSection(),
              Divider(),
              SecuritySection(),
              Divider(),
              NotificationSection(),
              Divider(),
              BackupSection(),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
