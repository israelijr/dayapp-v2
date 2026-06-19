import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:dayapp/providers/home_layout_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../theme/animation_durations.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final VoidCallback onCalendarTap;

  const HomeAppBar({
    required this.selectedIndex,
    required this.onCalendarTap,
    super.key,
  });

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

    return AppBar(
      automaticallyImplyLeading: selectedIndex != 1,
      title: Text(
        selectedIndex == 0
            ? l10n.appTitle
            : selectedIndex == 1
            ? l10n.collectionsTitle
            : l10n.search,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.notoSerif(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
      actions: [
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
      ],
    );
  }
}
