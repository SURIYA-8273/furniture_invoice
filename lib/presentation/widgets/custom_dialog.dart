import 'package:flutter/material.dart';
import '../../core/theme/theme_tokens.dart';

enum CustomDialogType { info, success, warning, error, custom }

class CustomDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final dynamic primaryActionValue;
  final dynamic secondaryActionValue;
  final CustomDialogType type;

  const CustomDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.primaryActionValue,
    this.secondaryActionValue,
    this.type = CustomDialogType.custom,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    String? message,
    Widget? content,
    IconData? icon,
    Color? iconColor,
    Color? iconBackgroundColor,
    String? primaryActionLabel,
    VoidCallback? onPrimaryAction,
    String? secondaryActionLabel,
    VoidCallback? onSecondaryAction,
    CustomDialogType type = CustomDialogType.custom,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        content: content,
        icon: icon,
        iconColor: iconColor,
        iconBackgroundColor: iconBackgroundColor,
        primaryActionLabel: primaryActionLabel,
        onPrimaryAction: onPrimaryAction,
        secondaryActionLabel: secondaryActionLabel,
        onSecondaryAction: onSecondaryAction,
        primaryActionValue: T == bool ? true : null,
        secondaryActionValue: T == bool ? false : null,
        type: type,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final effectiveIcon = icon ?? _getDefaultIcon();
    final effectiveIconColor = iconColor ?? _getDefaultIconColor(theme);
    final effectiveIconBgColor = iconBackgroundColor ?? _getDefaultIconBgColor(theme);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeTokens.radiusXLarge),
      ),
      icon: effectiveIcon != null
          ? Container(
              padding: const EdgeInsets.all(ThemeTokens.spacingMd),
              decoration: BoxDecoration(
                color: effectiveIconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                effectiveIcon,
                color: effectiveIconColor,
                size: 32,
              ),
            )
          : null,
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: ThemeTokens.spacingSm),
        child: content ?? (message != null ? Text(
          message!,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ) : null),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        ThemeTokens.spacingMd,
        0,
        ThemeTokens.spacingMd,
        ThemeTokens.spacingMd,
      ),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (primaryActionLabel != null) ...[
              ElevatedButton(
                onPressed: onPrimaryAction ?? () => Navigator.of(context).pop(primaryActionValue),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getPrimaryButtonBgColor(theme),
                  foregroundColor: _getPrimaryButtonFgColor(theme),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: ThemeTokens.spacingMd,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall),
                  ),
                ),
                child: Text(
                  primaryActionLabel!.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              if (secondaryActionLabel != null)
                const SizedBox(height: ThemeTokens.spacingSm),
            ],
            if (secondaryActionLabel != null)
              OutlinedButton(
                onPressed: onSecondaryAction ?? () => Navigator.of(context).pop(secondaryActionValue),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: ThemeTokens.spacingMd,
                  ),
                  side: BorderSide(color: theme.colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall),
                  ),
                ),
                child: Text(
                  secondaryActionLabel!.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  IconData? _getDefaultIcon() {
    switch (type) {
      case CustomDialogType.success:
        return Icons.check_circle_rounded;
      case CustomDialogType.error:
        return Icons.error_rounded;
      case CustomDialogType.warning:
        return Icons.warning_rounded;
      case CustomDialogType.info:
        return Icons.info_rounded;
      case CustomDialogType.custom:
        return null;
    }
  }

  Color _getDefaultIconColor(ThemeData theme) {
    return theme.colorScheme.primary;
  }

  Color _getDefaultIconBgColor(ThemeData theme) {
    final color = _getDefaultIconColor(theme);
    return color.withValues(alpha: 0.1);
  }

  Color _getPrimaryButtonBgColor(ThemeData theme) {
    return theme.colorScheme.primary;
  }

  Color _getPrimaryButtonFgColor(ThemeData theme) {
    return theme.colorScheme.onPrimary;
  }
}
