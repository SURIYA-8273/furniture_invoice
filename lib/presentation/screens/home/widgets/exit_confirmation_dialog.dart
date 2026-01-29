import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../widgets/custom_dialog.dart';

class ExitConfirmationDialog extends StatelessWidget {
  const ExitConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CustomDialog(
      type: CustomDialogType.error,
      title: l10n.exitApp,
      message: l10n.exitAppConfirmation,
      primaryActionLabel: l10n.exit,
      secondaryActionLabel: l10n.cancel,
      onPrimaryAction: () => Navigator.of(context).pop(true),
      onSecondaryAction: () => Navigator.of(context).pop(false),
    );
  }
}
