import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../../domain/entities/invoice_entity.dart';
import '../../providers/invoice_provider.dart';
import '../../../core/services/backup_service.dart';
import 'widgets/bill_list_view.dart';
import 'widgets/bill_payments_search_bar.dart';
import 'widgets/bill_payments_tab_bar.dart';
import '../../widgets/custom_dialog.dart';

class BillPaymentsScreen extends StatefulWidget {
  const BillPaymentsScreen({super.key});

  @override
  State<BillPaymentsScreen> createState() => _BillPaymentsScreenState();
}

class _BillPaymentsScreenState extends State<BillPaymentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load invoices when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceProvider>().loadInvoices();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.billPayments,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        // backgroundColor: Colors.white, // Inherit Blue
        // foregroundColor: Colors.black, // Inherit White
        actions: [
          _isExporting
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.cloud_upload),
                  tooltip: l10n.backup,
                  onPressed: () => _confirmExport(context, l10n),
                ),
          _isImporting
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.cloud_download),
                  tooltip: l10n.restore,
                  onPressed: () => _confirmImport(context, l10n),
                ),
        ],
      ),
      body: Column(
        children: [
          // Custom Tab Bar
          BillPaymentsTabBar(tabController: _tabController),

          // Search Bar
          BillPaymentsSearchBar(controller: _searchController),

          // Tab View Content
          Expanded(
            child: Consumer<InvoiceProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(child: Text(provider.error!));
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    BillListView(
                      invoices: provider.unpaidInvoices,
                      onDelete: (invoice) => _showDeleteConfirmationDialog(context, invoice, l10n),
                    ),
                    BillListView(
                      invoices: provider.paidInvoices,
                      onDelete: (invoice) => _showDeleteConfirmationDialog(context, invoice, l10n),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }






  Future<void> _showDeleteConfirmationDialog(BuildContext context, InvoiceEntity invoice, AppLocalizations l10n) async {
    final confirmed = await CustomDialog.show<bool>(
      context,
      type: CustomDialogType.warning,
      title: l10n.deleteBill,
      message: l10n.deleteBillConfirmation(invoice.invoiceNumber),
      primaryActionLabel: l10n.delete,
      secondaryActionLabel: l10n.cancel,
    );

    if (confirmed == true && context.mounted) {
      try {
        final provider = context.read<InvoiceProvider>();
        await provider.deleteInvoice(invoice.id);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.billDeletedSuccessfully),
              backgroundColor: ThemeTokens.successColor,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          CustomDialog.show(
            context,
            type: CustomDialogType.error,
            title: l10n.connectionStatus,
            message: _getPrettyErrorMessage(e.toString(), l10n),
            primaryActionLabel: l10n.ok,
            onPrimaryAction: () => Navigator.pop(context),
          );
        }
      }
    }
  }

  Future<void> _confirmExport(BuildContext context, AppLocalizations l10n) async {
    final confirmed = await CustomDialog.show<bool>(
      context,
      type: CustomDialogType.info,
      title: l10n.backupToCloudConfirmTitle,
      message: l10n.backupToCloudConfirmMessage,
      primaryActionLabel: l10n.backupNow,
      secondaryActionLabel: l10n.cancel,
    );

    if (confirmed == true && context.mounted) {
      setState(() {
        _isExporting = true;
      });
      
      final result = await BackupService.instance.performFullBackup(backupType: 'manual');
      
      if (context.mounted) {
        setState(() {
          _isExporting = false;
        });
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.backupSuccessful),
              backgroundColor: ThemeTokens.successColor,
            ),
          );
        } else {
          CustomDialog.show(
            context,
            type: CustomDialogType.error,
            title: l10n.backupFailed,
            message: _getPrettyErrorMessage(result.errorMessage ?? l10n.backupError, l10n),
            primaryActionLabel: l10n.ok,
            onPrimaryAction: () => Navigator.pop(context),
          );
        }
      }
    }
  }

  Future<void> _confirmImport(BuildContext context, AppLocalizations l10n) async {
    final confirmed = await CustomDialog.show<bool>(
      context,
      type: CustomDialogType.info,
      title: l10n.importFromCloudConfirmTitle,
      message: l10n.importFromCloudConfirmMessage,
      primaryActionLabel: l10n.importNow,
      secondaryActionLabel: l10n.cancel,
    );

    if (confirmed == true && context.mounted) {
      setState(() {
        _isImporting = true;
      });

      final result = await BackupService.instance.restoreData();

      if (context.mounted) {
        setState(() {
          _isImporting = false;
        });
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.importSuccessful),
              backgroundColor: ThemeTokens.successColor,
            ),
          );
          // Refresh list
          context.read<InvoiceProvider>().loadInvoices();
        } else {
          CustomDialog.show(
            context,
            type: CustomDialogType.error,
            title: l10n.importFailed,
            message: _getPrettyErrorMessage(result.errorMessage ?? l10n.importError, l10n),
            primaryActionLabel: l10n.ok,
            onPrimaryAction: () => Navigator.pop(context),
          );
        }
      }
    }
  }

  String _getPrettyErrorMessage(String error, AppLocalizations l10n) {
    final cleanError = error.toLowerCase();
    
    if (cleanError.contains('host lookup') || 
        cleanError.contains('socketexception') || 
        cleanError.contains('network') ||
        cleanError.contains('offline')) {
      return l10n.internetConnectionFailed;
    }
    
    if (cleanError.contains('timeout')) {
      return l10n.connectionTimeout;
    }

    if (cleanError.contains('supabase') || cleanError.contains('clientexception')) {
      return l10n.cloudConnectionError;
    }

    // Default cleanup for other errors
    return error.replaceAll('Exception:', '').replaceAll('Exception', '').trim();
  }
}
