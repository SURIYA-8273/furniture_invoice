import 'package:flutter/material.dart';
import '../../../../core/theme/theme_tokens.dart';

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const BottomNavItem({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Using a simple Column for tap target
    // Mimic NavigationDestination style roughly but smaller or fitting BottomAppBar
    final theme = Theme.of(context);
    final color = isSelected ? ThemeTokens.primaryColor : theme.hintColor;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10, 
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
