import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../providers/language_provider.dart';

class LanguageTile extends StatelessWidget {
  const LanguageTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = context.watch<LanguageProvider>();

    return ListTile(
      title: Text(l10n.language),
      subtitle: Text(languageProvider.currentLocale.languageCode == 'en' ? l10n.english : l10n.tamil),
      leading: Icon(Icons.language, color: theme.colorScheme.primary),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguageDialog(context, l10n, languageProvider),
    );
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations l10n, LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.languageSelection),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              context,
              title: l10n.english,
              subtitle: 'English',
              isSelected: languageProvider.currentLocale.languageCode == 'en',
              onTap: () {
                languageProvider.setEnglish();
                Navigator.pop(context);
              },
            ),
            const Divider(),
            _buildLanguageOption(
              context,
              title: l10n.tamil,
              subtitle: 'தமிழ்',
              isSelected: languageProvider.currentLocale.languageCode == 'ta',
              onTap: () {
                languageProvider.setTamil();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      tileColor: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : null,
    );
  }
}
