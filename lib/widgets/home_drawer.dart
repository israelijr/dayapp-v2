import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/pin_provider.dart';
import '../providers/premium_provider.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/groups_maintenance_screen.dart';
import '../widgets/user_profile_avatar.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = Provider.of<AuthProvider>(context).user;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final pinProvider = Provider.of<PinProvider>(context, listen: false);
    final premium = context.watch<PremiumProvider>();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Row(
              children: [
                Image.asset('assets/icon/icon.png', width: 48, height: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'DayApp',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (premium.isPremium) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'PREMIUM',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        user?.nome ?? '',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                UserProfileAvatar(
                  fotoPerfil: user?.fotoPerfil,
                  radius: 24,
                  onTap: () => _showProfileDialog(context, user?.fotoPerfil),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(l10n.editProfile),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium, color: Colors.amber),
            title: Text(l10n.premiumVersion),
            subtitle: Text(
              premium.isPremium ? l10n.premiumPlan : l10n.freePlan,
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/premium');
            },
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: Text(l10n.manageGroups),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const GroupsMaintenanceScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history_outlined),
            title: Text(l10n.insightHistoryTitle),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/insight-history');
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(l10n.trash),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/trash');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(l10n.help),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/help');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l10n.settings),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.about),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/about');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n.logout),
            onTap: () async {
              final navigator = Navigator.of(context);
              navigator.pop();

              await auth.logout();
              pinProvider.updateUserLoginStatus(false);

              if (!context.mounted) return;
              navigator.pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context, String? fotoPerfil) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        Widget imageWidget;
        if (fotoPerfil != null && fotoPerfil.isNotEmpty) {
          if (fotoPerfil.startsWith('http')) {
            imageWidget = Image.network(
              fotoPerfil,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) {
                return Image.asset(
                  'assets/image/icon.png',
                  fit: BoxFit.contain,
                );
              },
            );
          } else {
            imageWidget = Image.file(
              File(fotoPerfil),
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) {
                return Image.asset(
                  'assets/image/icon.png',
                  fit: BoxFit.contain,
                );
              },
            );
          }
        } else {
          imageWidget = Image.asset(
            'assets/image/icon.png',
            fit: BoxFit.contain,
          );
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageWidget,
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 30,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
