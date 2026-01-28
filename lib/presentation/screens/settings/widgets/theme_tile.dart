import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../l10n/app_localizations.dart';

class ThemeTile extends StatelessWidget {
  const ThemeTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = context.watch<ThemeProvider>();

    return SwitchListTile(
      title: Text(l10n.darkTheme),
      subtitle: Text(themeProvider.isDarkMode ? l10n.darkModeEnabled : l10n.lightModeEnabled),
      secondary: Icon(
        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: theme.colorScheme.primary,
      ),
      value: themeProvider.isDarkMode,
      onChanged: (_) => themeProvider.toggleTheme(),
    );
  }
}
