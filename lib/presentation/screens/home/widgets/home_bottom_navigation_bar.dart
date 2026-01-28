import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'bottom_nav_item.dart';

class HomeBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const HomeBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BottomAppBar(
      color: theme.cardColor,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 10,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 72, 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          // Left Side
          Flexible(
            child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                BottomNavItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long,
                  label: l10n.billing,
                  isSelected: selectedIndex == 0,
                  onTap: () => onItemTapped(0),
                ),
                 const SizedBox(width: 4),
                BottomNavItem(
                  icon: Icons.analytics_outlined,
                  activeIcon: Icons.analytics,
                  label: l10n.reports,
                  isSelected: selectedIndex == 1,
                  onTap: () => onItemTapped(1),
                ),
              ],
            ),
          ),

          const SizedBox(width: 60),
          
          // Right Side
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                BottomNavItem(
                  icon: Icons.description_outlined,
                  activeIcon: Icons.description,
                  label: l10n.descriptions,
                  isSelected: selectedIndex == 2,
                  onTap: () => onItemTapped(2),
                ),
                const SizedBox(width: 4),
                BottomNavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: l10n.settings,
                  isSelected: selectedIndex == 3,
                  onTap: () => onItemTapped(3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
