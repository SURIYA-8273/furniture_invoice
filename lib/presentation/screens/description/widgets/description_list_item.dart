import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../domain/entities/description_entity.dart';

class DescriptionListItem extends StatelessWidget {
  final DescriptionEntity description;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DescriptionListItem({
    super.key,
    required this.description,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        visualDensity: VisualDensity.compact,
        title: Text(
          description.text,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
              onPressed: onEdit,
              tooltip: l10n.edit,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
              onPressed: onDelete,
              tooltip: l10n.delete,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
          ],
        ),
      ),
    );
  }
}
