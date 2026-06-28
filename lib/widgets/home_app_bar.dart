import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:dayapp/providers/chapter_filter_provider.dart';
import 'package:dayapp/providers/home_layout_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/refresh_provider.dart';
import '../services/backup_service.dart';
import '../theme/animation_durations.dart';
import 'pulse_animation.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final VoidCallback onCalendarTap;

  const HomeAppBar({
    required this.selectedIndex,
    required this.onCalendarTap,
    this.collectionsTabIndex = 0,
    super.key,
  });

  final int collectionsTabIndex;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCardView = context.select<HomeLayoutProvider, bool>(
      (provider) => provider.isCardView,
    );
    final layoutProvider = Provider.of<HomeLayoutProvider>(
      context,
      listen: false,
    );
    final filterProvider = Provider.of<ChapterFilterProvider>(context);

    return AppBar(
      automaticallyImplyLeading: true,
      title: Text(
        selectedIndex == 0
            ? l10n.appTitle
            : selectedIndex == 1
            ? l10n.collectionsTitle
            : l10n.search,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.plusJakartaSans(fontSize: 24, height: 1.3),
      ),
      actions: [
        Consumer<RefreshProvider>(
          builder: (context, refreshProvider, child) {
            return FutureBuilder<int>(
              future: BackupService().countPendingBackupStories(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data! > 0) {
                  final pendingCount = snapshot.data!;
                  return PulseAnimation(
                    scaleTarget: 1.15,
                    child: IconButton(
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            Icons.cloud_upload_rounded,
                            color: Theme.of(context).colorScheme.error,
                            size: 24,
                          ),
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 8,
                                minHeight: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      tooltip: l10n.unsavedBackups(pendingCount),
                      onPressed: () {
                        Navigator.pushNamed(context, '/backup-manager');
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
        if (selectedIndex == 0)
          Builder(
            builder: (context) {
              const duration = AppDurations.listSwitch;
              return Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: IconButton(
                      onPressed: layoutProvider.toggleCardView,
                      icon: Icon(
                        isCardView
                            ? Icons.grid_view_rounded
                            : Icons.view_agenda_rounded,
                        size: 22,
                      ),
                      tooltip: isCardView
                          ? l10n.homeHeaderCompactCards
                          : l10n.homeHeaderLargeCards,
                      splashRadius: 24,
                      constraints: const BoxConstraints(
                        minWidth: 38,
                        minHeight: 38,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: onCalendarTap,
                      child: Tooltip(
                        message: l10n.homeHeaderOpenCalendarTooltip,
                        child: AnimatedContainer(
                          duration: duration,
                          curve: Curves.easeInOut,
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.calendar_month_rounded,
                              size: 22,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        if (selectedIndex == 1 && collectionsTabIndex == 0)
          PopupMenuButton<String>(
            icon: const Icon(Icons.tune_rounded),
            onSelected: (value) {
              if (value == 'sort_date') {
                filterProvider.setSortOrder('date');
              } else if (value == 'sort_title') {
                filterProvider.setSortOrder('title');
              } else if (value == 'limit_all') {
                filterProvider.setItemLimit(null);
              } else if (value.startsWith('limit_')) {
                filterProvider.setItemLimit(int.parse(value.split('_')[1]));
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                enabled: false,
                child: Text(
                  'Ordenação',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              CheckedPopupMenuItem(
                value: 'sort_date',
                checked: filterProvider.sortOrder == 'date',
                child: const Text('Data (Update)'),
              ),
              CheckedPopupMenuItem(
                value: 'sort_title',
                checked: filterProvider.sortOrder == 'title',
                child: const Text('Título'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                enabled: false,
                child: Text(
                  'Visualização',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              CheckedPopupMenuItem(
                value: 'limit_all',
                checked: filterProvider.itemLimit == null,
                child: const Text('Ver todos'),
              ),
              CheckedPopupMenuItem(
                value: 'limit_10',
                checked: filterProvider.itemLimit == 10,
                child: const Text('Ver 10'),
              ),
              CheckedPopupMenuItem(
                value: 'limit_20',
                checked: filterProvider.itemLimit == 20,
                child: const Text('Ver 20'),
              ),
              CheckedPopupMenuItem(
                value: 'limit_50',
                checked: filterProvider.itemLimit == 50,
                child: const Text('Ver 50'),
              ),
            ],
          ),
      ],
    );
  }
}
