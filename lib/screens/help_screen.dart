import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

import '../theme/m3_expressive_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.help),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Introdução
          _buildSection(
            context,
            loc.helpAboutTitle,
            loc.helpAboutDescription,
            Icons.info_outline,
          ),

          const SizedBox(height: 24),

          // Navegação Principal
          _buildSection(
            context,
            loc.helpNavigationTitle,
            '',
            Icons.navigation,
            children: [
              _buildBulletHelpItem(context, loc.home, [
                (icon: null, text: loc.helpHomeItemDesc),
                (icon: null, text: loc.helpHomeDoubleTapDesc),
                (icon: null, text: loc.helpHomeAttachmentsDesc),
                (icon: null, text: loc.helpHomeSwipeRightDesc),
                (icon: null, text: loc.helpHomeSwipeLeftDesc),
                (
                  icon: Icons.calendar_month_rounded,
                  text: loc.helpHomeCalendarIconDesc,
                ),
                (
                  icon: Icons.auto_stories_outlined,
                  text: loc.helpHomeChapterIconDesc,
                ),
              ]),
              _buildHelpItem(context, loc.groups, loc.helpGroupsNavDesc),
              _buildHelpItem(context, loc.search, loc.helpSearchItemDesc),
            ],
          ),

          const SizedBox(height: 24),

          // Criando Histórias
          _buildSection(
            context,
            loc.helpCreatingTitle,
            '',
            Icons.create,
            children: [
              _buildHelpItem(context, loc.newStory, loc.helpNewStoryDesc),
              _buildHelpItem(
                context,
                loc.helpTextEditorTitle,
                loc.helpTextEditorDesc,
              ),
              _buildHelpItem(context, loc.mediaLabel, loc.helpMediaDesc),
            ],
          ),

          const SizedBox(height: 24),

          // Calendário
          _buildSection(
            context,
            loc.calendarTitle,
            loc.helpCalendarDesc,
            Icons.calendar_today,
          ),

          const SizedBox(height: 24),

          // Grupos
          _buildSection(
            context,
            loc.manageGroups,
            '',
            Icons.group,
            children: [
              _buildHelpItem(
                context,
                loc.helpCreateGroupTitle,
                loc.helpCreateGroupDesc,
              ),
              _buildHelpItem(
                context,
                loc.helpEditGroupTitle,
                loc.helpEditGroupDesc,
              ),
              _buildHelpItem(
                context,
                loc.helpGroupsAssocTitle,
                loc.helpGroupsAssocDesc,
              ),
              _buildHelpItem(
                context,
                loc.helpDeleteGroupTitle,
                loc.helpDeleteGroupDesc,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Insights
          _buildSection(
            context,
            loc.helpInsightsTitle,
            loc.helpInsightsDesc,
            Icons.lightbulb_outline,
          ),

          const SizedBox(height: 24),

          // Backup e Segurança
          _buildSection(
            context,
            loc.helpBackupSecurityTitle,
            '',
            Icons.security,
            children: [
              _buildHelpItem(
                context,
                loc.helpManualBackupTitle,
                loc.helpManualBackupDesc,
              ),
              _buildHelpItem(
                context,
                loc.helpRestoreTitle,
                loc.helpRestoreDesc,
              ),
              _buildHelpItem(
                context,
                loc.helpPinSecurityTitle,
                loc.helpPinSecurityDesc,
              ),
              _buildHelpItem(context, loc.biometrics, loc.helpBiometricsDesc),
              _buildHelpItem(
                context,
                loc.helpPasswordUnlockTitle,
                loc.helpPasswordUnlockDesc,
              ),
              _buildHelpItem(
                context,
                loc.backgroundLock,
                loc.helpBackgroundLockDesc,
              ),
              _buildHelpItem(
                context,
                loc.helpLockExceptionsTitle,
                loc.helpLockExceptionsDesc,
              ),
              _buildHelpItem(
                context,
                loc.helpPinRecoveryTitle,
                loc.helpPinRecoveryDesc,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Configurações
          _buildSection(
            context,
            loc.settings,
            '',
            Icons.settings,
            children: [
              _buildHelpItem(context, loc.theme, loc.helpThemeDesc),
              _buildHelpItem(
                context,
                loc.notifications,
                loc.helpNotificationsSettingsDesc,
              ),
              _buildHelpItem(
                context,
                loc.backgroundLock,
                loc.helpBackgroundLockSettingsDesc,
              ),
              _buildHelpItem(
                context,
                loc.helpBackupSettingTitle,
                loc.helpBackupSettingDesc,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Lixeira
          _buildSection(
            context,
            loc.trash,
            loc.helpTrashDesc,
            Icons.delete_outline,
          ),

          const SizedBox(height: 24),

          // Dicas de Uso
          _buildSection(
            context,
            loc.helpTipsTitle,
            '',
            Icons.lightbulb,
            children: [
              _buildHelpItem(
                context,
                loc.helpOrganizationTipTitle,
                loc.helpOrganizationTipDesc,
              ),
              _buildHelpItem(
                context,
                loc.helpSearchTipTitle,
                loc.helpSearchTipDesc,
              ),
              _buildHelpItem(
                context,
                loc.helpBackupTipTitle,
                loc.helpBackupTipDesc,
              ),
              _buildHelpItem(
                context,
                loc.helpPrivacyTipTitle,
                loc.helpPrivacyTipDesc,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Suporte
          _buildSection(
            context,
            loc.helpSupportTitle,
            loc.helpSupportDesc,
            Icons.support,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String description,
    IconData icon, {
    List<Widget>? children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.labelColor(context),
                    ),
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                ),
              ),
            ],
            if (children != null) ...[const SizedBox(height: 16), ...children],
          ],
        ),
      ),
    );
  }

  Widget _buildBulletHelpItem(
    BuildContext context,
    String title,
    List<({IconData? icon, String text})> bullets,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.labelColor(context),
            ),
          ),
          const SizedBox(height: 6),
          ...bullets.map(
            (bullet) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (bullet.icon != null) ...[
                    Icon(bullet.icon, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 6),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      bullet.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.labelColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(
    BuildContext context,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.labelColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.labelColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
