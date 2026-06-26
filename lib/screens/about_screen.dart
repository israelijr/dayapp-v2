import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/pin_provider.dart';
import '../theme/m3_expressive_theme.dart';
import 'premium_debug_screen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '1.0.22';
  String _buildNumber = '29';

  // Contador para easter egg (7 toques na versão = abre PremiumDebugScreen)
  int _debugTapCount = 0;
  DateTime? _debugLastTap;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        if (packageInfo.version.isNotEmpty) {
          _version = packageInfo.version;
        }
        if (packageInfo.buildNumber.isNotEmpty) {
          _buildNumber = packageInfo.buildNumber;
        }
      });
    } catch (e) {
      // Mantém valores padrão em caso de erro
    }
  }

  /// Contabiliza toques na versão; ao 7.º toque (dentro de 3 s) abre o
  /// PremiumDebugScreen.
  void _handleVersionTap() {
    final now = DateTime.now();
    if (_debugLastTap != null &&
        now.difference(_debugLastTap!) > const Duration(seconds: 3)) {
      _debugTapCount = 0;
    }
    _debugLastTap = now;
    _debugTapCount++;

    if (_debugTapCount >= 7) {
      _debugTapCount = 0;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PremiumDebugScreen()),
      );
    } else {
      final restantes = 7 - _debugTapCount;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$restantes toques para o modo debug'),
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.about), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Logo e Nome do App
          _buildAppHeader(context),

          const SizedBox(height: 24),

          // Descrição do App
          _buildSection(
            context,
            l10n.aboutScreenAboutDayAppTitle,
            l10n.aboutScreenAboutDayAppDescription,
            Icons.description,
          ),

          const SizedBox(height: 24),

          // Funcionalidades Principais
          _buildSection(
            context,
            l10n.aboutScreenFeaturesTitle,
            '',
            Icons.star,
            children: [
              _buildFeatureItem(
                l10n.aboutScreenFeatureRichEditorTitle,
                l10n.aboutScreenFeatureRichEditorDescription,
              ),
              _buildFeatureItem(
                l10n.aboutScreenFeatureSmartOrganizationTitle,
                l10n.aboutScreenFeatureSmartOrganizationDescription,
              ),
              _buildFeatureItem(
                l10n.aboutScreenFeatureAdvancedSearchTitle,
                l10n.aboutScreenFeatureAdvancedSearchDescription,
              ),
              _buildFeatureItem(
                l10n.aboutScreenFeatureSecureBackupTitle,
                l10n.aboutScreenFeatureSecureBackupDescription,
              ),
              /* _buildFeatureItem(
                l10n.aboutScreenFeatureTotalPrivacyTitle,
                l10n.aboutScreenFeatureTotalPrivacyDescription,
              ), */
              _buildFeatureItem(
                l10n.aboutScreenFeatureAdaptiveInterfaceTitle,
                l10n.aboutScreenFeatureAdaptiveInterfaceDescription,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Versão e Build
          _buildSection(
            context,
            l10n.aboutScreenVersionTitle,
            l10n.aboutScreenVersionBuild(_version, _buildNumber),
            Icons.info,
          ),

          const SizedBox(height: 24),


          // Desenvolvedor
          _buildSection(
            context,
            l10n.aboutScreenDevelopmentTitle,
            l10n.aboutScreenDevelopmentDescription,
            Icons.person,
          ),

          const SizedBox(height: 24),

          // Privacidade e Segurança
          /* _buildSection(
            context,
            l10n.aboutScreenPrivacySecurityTitle,
            '',
            Icons.security,
            children: [
              _buildPrivacyItem(
                l10n.aboutScreenPrivacyLocalDataTitle,
                l10n.aboutScreenPrivacyLocalDataDescription,
              ),
              _buildPrivacyItem(
                l10n.aboutScreenPrivacyEncryptionTitle,
                l10n.aboutScreenPrivacyEncryptionDescription,
              ),
              _buildPrivacyItem(
                l10n.aboutScreenPrivacyNoTrackingTitle,
                l10n.aboutScreenPrivacyNoTrackingDescription,
              ),
              _buildPrivacyItem(
                l10n.aboutScreenPrivacyPinSecurityTitle,
                l10n.aboutScreenPrivacyPinSecurityDescription,
              ),
            ],
          ), */
          const SizedBox(height: 24),

          // Contato e Suporte
          _buildContactSection(context),

          const SizedBox(height: 24),

          // Agradecimentos
          _buildSection(
            context,
            l10n.aboutScreenAcknowledgementsTitle,
            l10n.aboutScreenAcknowledgementsDescription,
            Icons.favorite,
          ),

          const SizedBox(height: 32),

          // Copyright
          Center(
            child: Text(
              l10n.aboutScreenCopyright,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.support_agent,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.aboutScreenContactSupportTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.labelColor(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.aboutScreenContactSupportDescription,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final pinProvider = Provider.of<PinProvider>(
                  context,
                  listen: false,
                );
                final String query = [
                  'subject=${Uri.encodeComponent(l10n.aboutScreenSupportEmailSubject)}',
                  'body=${Uri.encodeComponent(l10n.aboutScreenSupportEmailBody('$_version+$_buildNumber'))}',
                ].join('&');
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'contato@iijrapp.com.br',
                  query: query,
                );
                if (await canLaunchUrl(emailUri)) {
                  pinProvider.isPickingExternalMedia = true;
                  try {
                    await launchUrl(emailUri);
                  } finally {
                    // Reseta após um breve delay para cobrir a transição
                    Future.delayed(const Duration(seconds: 2), () {
                      pinProvider.isPickingExternalMedia = false;
                    });
                  }
                }
              },
              child: Row(
                children: [
                  Icon(
                    Icons.email,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'contato@iijrapp.com.br',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      color: AppColors.labelColor(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final pinProvider = Provider.of<PinProvider>(
                  context,
                  listen: false,
                );
                const url = 'https://iijrapp.com.br/politica_de_privacidade';
                final Uri uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  pinProvider.isPickingExternalMedia = true;
                  try {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } finally {
                    // Reseta após um breve delay para cobrir a transição
                    Future.delayed(const Duration(seconds: 2), () {
                      pinProvider.isPickingExternalMedia = false;
                    });
                  }
                }
              },
              child: Row(
                children: [
                  Icon(
                    Icons.policy,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.privacyPolicy,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.open_in_new,
                    size: 16,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Image.asset('assets/icon/icon.png', width: 80, height: 80),
            const SizedBox(height: 16),
            const Text(
              'DayApp',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.aboutScreenHeaderSubtitle,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            // Easter egg: 7 toques abrem a tela de debug do Premium (somente em debug)
            GestureDetector(
              onTap: _handleVersionTap,
              child: Text(
                l10n.aboutScreenVersionShort(_version),
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.labelColor(context),
            ),
          ),
          Expanded(
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
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
