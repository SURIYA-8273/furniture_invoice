import 'package:flutter/material.dart';
import '../../../../core/theme/theme_tokens.dart';
import '../../../../l10n/app_localizations.dart';

class ExitConfirmationDialog extends StatelessWidget {
  const ExitConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeTokens.radiusXLarge),
      ),
      icon: Container(
        padding: const EdgeInsets.all(ThemeTokens.spacingMd),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.logout_rounded,
          color: theme.colorScheme.error,
          size: 32,
        ),
      ),
      title: Text(
        l10n.exitApp,
        textAlign: TextAlign.center,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: ThemeTokens.spacingSm),
        child: Text(
          l10n.exitAppConfirmation,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.all(ThemeTokens.spacingMd),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeTokens.spacingLg,
              vertical: ThemeTokens.spacingMd,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
            ),
          ),
          child: Text(
            l10n.cancel.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeTokens.spacingLg,
              vertical: ThemeTokens.spacingMd,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
            ),
          ),
          child: Text(
            l10n.exit.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
