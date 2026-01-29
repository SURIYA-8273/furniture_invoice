import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/description_provider.dart';
import '../../../domain/entities/description_entity.dart';
import 'widgets/description_search_bar.dart';
import 'widgets/description_list_item.dart';
import '../../widgets/custom_dialog.dart';

class DescriptionListScreen extends StatefulWidget {
  const DescriptionListScreen({super.key});

  @override
  State<DescriptionListScreen> createState() => _DescriptionListScreenState();
}

class _DescriptionListScreenState extends State<DescriptionListScreen> {
  final _textController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  void _showAddEditDialog({DescriptionEntity? description}) {
    final l10n = AppLocalizations.of(context)!;
    _textController.text = description?.text ?? '';
    final isEditing = description != null;

    CustomDialog.show(
      context,
      title: isEditing ? l10n.editDescription : l10n.addDescription,
      content: TextField(
        controller: _textController,
        decoration: InputDecoration(
          hintText: l10n.enterDescriptionText,
          border: const OutlineInputBorder(),
        ),
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
      ),
      primaryActionLabel: l10n.save,
      secondaryActionLabel: l10n.cancel,
      onPrimaryAction: () {
        final text = _textController.text.trim();
        if (text.isNotEmpty) {
          final provider = context.read<DescriptionProvider>();
          if (isEditing) {
            provider.updateDescription(DescriptionEntity(
              id: description.id,
              text: text,
            ));
          } else {
            provider.addDescription(text);
          }
          Navigator.pop(context);
        }
      },
      onSecondaryAction: () => Navigator.pop(context),
    );
  }

  void _confirmDelete(DescriptionEntity description) {
    final l10n = AppLocalizations.of(context)!;
    CustomDialog.show(
      context,
      type: CustomDialogType.warning,
      title: l10n.deleteDescription,
      message: l10n.deleteDescriptionConfirmation(description.text),
      primaryActionLabel: l10n.delete,
      secondaryActionLabel: l10n.cancel,
      onPrimaryAction: () {
        context.read<DescriptionProvider>().deleteDescription(description.id);
        Navigator.pop(context);
      },
      onSecondaryAction: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageDescriptions),
      ),
      body: Column(
        children: [
          // Search Bar
          DescriptionSearchBar(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
          Expanded(
            child: Consumer<DescriptionProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredDescriptions = provider.descriptions
                    .where((d) => d.text.toLowerCase().contains(_searchQuery))
                    .toList();

                if (filteredDescriptions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.description_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? l10n.noDescriptionsYet : l10n.noInvoicesFound, // Reuse no items hint
                          style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemCount: filteredDescriptions.length,
                  itemBuilder: (context, index) {
                    final description = filteredDescriptions[index];
                    return DescriptionListItem(
                      description: description,
                      onEdit: () => _showAddEditDialog(description: description),
                      onDelete: () => _confirmDelete(description),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'desc_list_fab',
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

