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

  Future<void> _generateAndSharePdf({bool share = false, bool print = false}) async {
    final businessProfile = context.read<BusinessProfileProvider>().profile;
    if (businessProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business profile not found')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final file = await PdfService.instance.generateInvoicePdf(
        invoice: widget.invoice,
        businessProfile: businessProfile,
      );

      if (share && mounted) {
           await WhatsAppService.instance.shareInvoice(
            phoneNumber: '', // No customer phone
            invoice: widget.invoice,
            pdfFile: file,
          );
      } else if (print) {
        // Implement print logic here if needed, or just open the file
        // For now, we rely on PDF viewer or OS to handle printing from the file
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF Generated at ${file.path}')),
          );
      } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF Generated at ${file.path}')),
          );
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
            icon: const Icon(Icons.share),
            onPressed: () => _generateAndSharePdf(share: true),
            tooltip: 'Share via WhatsApp',
          ),
          IconButton(
            icon: const Icon(Icons.print),
             onPressed: () => _generateAndSharePdf(print: true),
             tooltip: 'Print',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _generateAndSharePdf(),
            tooltip: 'Save PDF',
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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
              
              // Action Buttons (Bottom)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _generateAndSharePdf(),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('PDF'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _generateAndSharePdf(print: true),
                      icon: const Icon(Icons.print),
                      label: const Text('PRINT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _generateAndSharePdf(share: true),
                      icon: const Icon(Icons.chat),
                      label: const Text('WHATSAPP'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'BACK TO DASHBOARD',
                  style: TextStyle(
                    color: Colors.grey,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildHeader(BusinessProfileEntity? businessProfile) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
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
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.business, color: Colors.white, size: 30),
            ),
          
          const SizedBox(height: 16),
          
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
          
          const SizedBox(height: 8),
          
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
        ],
      ),
    );
  }

  Widget _buildInvoiceDetails() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'INVOICE',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    '#${widget.invoice.invoiceNumber}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'DATE',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yyyy').format(widget.invoice.invoiceDate),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          // Table Header
          Row(
            children: [
              Expanded(flex: 4, child: _buildTableHeaderText('DESCRIPTION')),
              Expanded(flex: 2, child: _buildTableHeaderText('L', align: TextAlign.center)),
              Expanded(flex: 1, child: _buildTableHeaderText('QTY', align: TextAlign.center)),
              Expanded(flex: 2, child: _buildTableHeaderText('RATE', align: TextAlign.right)),
              Expanded(flex: 2, child: _buildTableHeaderText('AMOUNT', align: TextAlign.right)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
           const SizedBox(height: 12),

          // Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.invoice.items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = widget.invoice.items[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4, 
                    child: Text(
                      item.productName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    )
                  ),
                  Expanded(
                    flex: 2, 
                    child: Text(
                      item.size,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    )
                  ),
                  Expanded(
                    flex: 1, 
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    )
                  ),
                  Expanded(
                    flex: 2, 
                    child: Text(
                      NumberFormat('#,##0').format(item.mrp),
                       textAlign: TextAlign.right,
                       style: TextStyle(color: Colors.grey[600]),
                    )
                  ),
                  Expanded(
                    flex: 2, 
                    child: Text(
                       NumberFormat('#,##0').format(item.totalAmount),
                       textAlign: TextAlign.right,
                       style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  ),
                ],
              );
            },
          ),
        ],
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
      ),
    );
  }

  Widget _buildFooterTotals() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildTotalRow('Total Amount', widget.invoice.grandTotal),
          const SizedBox(height: 12),
          _buildTotalRow('Advance Paid', -widget.invoice.paidAmount, isGreen: true),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 2, color: Colors.black),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'BALANCE DUE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '₹${NumberFormat('#,##0.00').format(widget.invoice.balanceAmount)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
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
