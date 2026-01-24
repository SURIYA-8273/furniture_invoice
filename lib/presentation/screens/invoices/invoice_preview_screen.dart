import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/services/whatsapp_service.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/entities/business_profile_entity.dart';
import '../../providers/business_profile_provider.dart';
import '../../providers/billing_calculation_provider.dart';
import '../home/home_screen.dart';

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
    final phoneNumberController = TextEditingController();
    
    // Pre-fill if customer has phone (simple heuristic, can be improved)
    // if (widget.invoice.customerPhone != null) phoneNumberController.text = widget.invoice.customerPhone!; 

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Invoice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter WhatsApp number to send directly, or leave empty to select a chat.'),
            const SizedBox(height: 16),
            TextField(
              controller: phoneNumberController,
              decoration: const InputDecoration(
                labelText: 'WhatsApp Number (Optional)',
                hintText: 'e.g., 9876543210',
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
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAndSharePdf({bool share = false, bool print = false, String? phoneNumber}) async {
    var businessProfile = context.read<BusinessProfileProvider>().profile;
    
    // If profile is missing, try to reload it just in case
    if (businessProfile == null) {
      await context.read<BusinessProfileProvider>().loadProfile();
      businessProfile = context.read<BusinessProfileProvider>().profile;
    }

    if (businessProfile == null) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Business Profile Missing'),
            content: const Text('Please set up your business profile (Name, Address, Logo) in Settings before generating invoices.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }
    
    // Continue with existing logic...
    setState(() => _isLoading = true);

    try {
      final file = await PdfService.instance.generateInvoicePdf(
        invoice: widget.invoice,
        businessProfile: businessProfile,
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
              SnackBar(content: Text('PDF Generated at ${file.path}')),
            );
         }
      } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('PDF Generated at ${file.path}')),
            );
          }
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final businessProfile = context.watch<BusinessProfileProvider>().profile;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Invoice Preview'),
        actions: [
          IconButton(
            icon: SizedBox(
               width: 24,
               height: 24,
               child: Image.asset('assets/images/whatsapp.png', color: null),
            ),
            onPressed: () => _showWhatsAppDialog(),
            tooltip: 'Share via WhatsApp',
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            children: [
              // Invoice Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header Section
                    _buildHeader(businessProfile),
                    const Divider(height: 1),
                    
                    // Invoice Details
                    _buildInvoiceDetails(),
                    const Divider(height: 1),

                    // Items Table
                    _buildItemsTable(),
                    const Divider(height: 1),

                    // Footer Totals
                    _buildFooterTotals(),
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
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
              label: const Text('BACK TO DASHBOARD'),
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

  Widget _buildHeader(BusinessProfileEntity? businessProfile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // Logo
          if (businessProfile?.logoPath != null)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(File(businessProfile!.logoPath!)),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                // color: Colors.black, // Removed black background
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('assets/images/logo.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          
          const SizedBox(height: 2),
          
          // Business Name
          Text(
            businessProfile?.businessName.toUpperCase() ?? 'BUSINESS NAME',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 2),
          
          // Contact Details
          Text(
              businessProfile?.primaryPhone != null 
                ? '+91 ${businessProfile!.primaryPhone}' 
                : 'Contact Information',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
              textAlign: TextAlign.center,
          ),
          if (businessProfile?.businessAddress != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                businessProfile!.businessAddress!,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0,vertical:10
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side: Bill To
          if (widget.invoice.customerName != null && widget.invoice.customerName!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  'BILL TO',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.invoice.customerName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            )
          else
            const SizedBox(), // Empty if no customer name

          // Right Side: Bill No & Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'BILL NO : ${widget.invoice.invoiceNumber.split('-').last}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'DATE : ${DateFormat('dd-MM-yyyy').format(widget.invoice.invoiceDate)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1.0),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Table Header
            Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(flex: 3, child: _buildTableHeaderText('DESCRIPTION')), 
                  Expanded(flex: 1, child: _buildTableHeaderText('LENGTH', align: TextAlign.center)),
                  Expanded(flex: 1, child: _buildTableHeaderText('QTY', align: TextAlign.center)),
                  Expanded(flex: 1, child: _buildTableHeaderText('TOT.LEN', align: TextAlign.center)),
                  Expanded(flex: 2, child: _buildTableHeaderText('RATE', align: TextAlign.right)),
                  Expanded(flex: 2, child: _buildTableHeaderText('TOTAL', align: TextAlign.right)),
                ],
              ),
            ),
             Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
            
            // Items
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.invoice.items.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final item = widget.invoice.items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3, 
                        child: (item.productName.isEmpty && item.size.isEmpty)
                          ? const Center(
                              child: Text(
                                '-',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                              ),
                            )
                          : Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: item.productName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                                  ),
                                  if (item.size.isNotEmpty)
                                    TextSpan(
                                      text: '  ${item.size}',
                                      style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                ],
                              ),
                            ),
                      ),
                      Expanded(
                        flex: 1, 
                        child: Text(
                          item.squareFeet == 0 ? '-' : item.squareFeet.toStringAsFixed(2),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
                        )
                      ),
                      Expanded(
                        flex: 1, 
                        child: Text(
                          item.quantity == 0 ? '-' : '${item.quantity}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
                        )
                      ),
                      Expanded(
                        flex: 1, 
                        child: Text(
                          item.totalQuantity == 0 ? '-' : item.totalQuantity.toStringAsFixed(2),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
                        )
                      ),
                      Expanded(
                        flex: 2, 
                        child: Text(
                          NumberFormat('#,##0').format(item.mrp),
                           textAlign: TextAlign.right,
                           style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
                        )
                      ),
                      Expanded(
                        flex: 2, 
                        child: Text(
                           NumberFormat('#,##0').format(item.totalAmount),
                           textAlign: TextAlign.right,
                           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
                        )
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeaderText(String text, {TextAlign align = TextAlign.left}) {
    return Text(
      text,
      textAlign: align,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
        color: Colors.black,
      ),
    );
  }

  Widget _buildFooterTotals() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
      child: Column(
        children: [
          _buildTotalRow('Total Amount', widget.invoice.grandTotal),
          const SizedBox(height: 6),
          _buildTotalRow('Advance Paid', -widget.invoice.paidAmount, isGreen: true),
          const SizedBox(height: 6),
                  _buildTotalRow('BALANCE DUE', widget.invoice.balanceAmount),
          const SizedBox(height: 6),
         
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: SizedBox()), // Push to right
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                '${isGreen ? '-' : ''}₹${NumberFormat('#,##0.00').format(amount.abs())}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isGreen ? const Color(0xFF25D366) : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
