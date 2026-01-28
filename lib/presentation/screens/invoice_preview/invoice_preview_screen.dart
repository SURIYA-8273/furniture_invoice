import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/services/whatsapp_service.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../providers/business_profile_provider.dart';
import '../../providers/billing_calculation_provider.dart';
import '../../widgets/invoice_items_table.dart';
import 'widgets/invoice_preview_details.dart';
import 'widgets/invoice_preview_footer.dart';
import 'widgets/invoice_preview_header.dart';

class InvoicePreviewScreen extends StatefulWidget {
  final InvoiceEntity invoice;
  const InvoicePreviewScreen({
    super.key,
    required this.invoice,
  });

  @override
  State<InvoicePreviewScreen> createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends State<InvoicePreviewScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  // Removed _loadCustomer

  Future<void> _showWhatsAppDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final phoneNumberController = TextEditingController();
    
    // Pre-fill if customer has phone (simple heuristic, can be improved)
    // if (widget.invoice.customerPhone != null) phoneNumberController.text = widget.invoice.customerPhone!; 



    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.shareInvoice),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.enterWhatsappNumberHint),
            const SizedBox(height: 16),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(
                labelText: l10n.whatsappNumberOptional,
                hintText: l10n.whatsappNumberHintExample,
                prefixText: '+91 ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // If text is empty, passing empty string triggers 'Select Chat' logic in WhatsAppService (updated previously)
              _generateAndSharePdf(share: true, phoneNumber: phoneNumberController.text.trim());
            },
            child: Text(l10n.send),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAndSharePdf({bool share = false, bool print = false, String? phoneNumber}) async {


    final l10n = AppLocalizations.of(context)!;
    var businessProfile = context.read<BusinessProfileProvider>().profile;
    
    if (businessProfile == null) {
      if (!context.mounted) return;
      showDialog(
        context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.businessProfileMissing),
            content: Text(l10n.businessProfileSetupMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel.toUpperCase()),
              ),
            ],
          ),
        );
      return;
    }
    
    // Continue with existing logic...
    setState(() => _isLoading = true);

    try {
      final file = await PdfService.instance.generateInvoicePdf(
        invoice: widget.invoice,
        businessProfile: businessProfile,
        l10n: l10n,
      );

      if (share && mounted) {
           // If phoneNumber is explicit (empty or provided), use it.
           // Note: WhatsAppService.shareInvoice might imply using url_launcher with 'whatsapp://send?phone=...'.
           // If phone is empty, it might fail or just open app. 
           // Let's pass what we have.
           await WhatsAppService.instance.shareInvoice(
            phoneNumber: phoneNumber ?? '', 
            invoice: widget.invoice,
            file: file,
          );
      } else if (print) {
        // ... (existing print logic)
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.pdfGeneratedAt(file.path))),
            );
         }
      } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.pdfGeneratedAt(file.path))),
            );
          }
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final businessProfile = context.watch<BusinessProfileProvider>().profile;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.invoicePreview),
        actions: [
          IconButton(
            icon: SizedBox(
               width: 24,
               height: 24,
               child: Image.asset('assets/images/whatsapp.png', color: null),
            ),
            onPressed: () => _showWhatsAppDialog(),
            tooltip: l10n.shareViaWhatsApp,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          child: Column(
            children: [
              // Invoice Card
              Container(
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: ThemeTokens.getScaffoldBackground(context) == ThemeTokens.darkBackground ? ThemeTokens.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header Section
                    InvoicePreviewHeader(businessProfile: businessProfile),
                    const Divider(height: 1),
                    
                    // Invoice Details
                    InvoicePreviewDetails(invoice: widget.invoice),
                    const Divider(height: 1),

                    // Items Table
                    InvoiceItemsTable(items: widget.invoice.items),
                    const Divider(height: 1),

                    // Footer Totals
                    InvoicePreviewFooter(invoice: widget.invoice),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<BillingCalculationProvider>().clear();
                // Navigate to Dashboard (Home Screen)
                // Us popUntil to go back to the root route (HomeScreen) safely.
                // This prevents "Black Screen" issues caused by recreating HomeScreen improperly.
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.dashboard, size: 16),
              label: Text(l10n.backToDashboard),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                elevation: 8,
                shadowColor: Colors.black45,
                textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.0),
              ),
            ),
          ),
        ),
      ),
    );
  }


}
