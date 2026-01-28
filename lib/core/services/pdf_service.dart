import 'dart:io';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; // For PdfGoogleFonts
import 'package:path_provider/path_provider.dart';
import '../utils/tamil_print_utils.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/business_profile_entity.dart';
import '../../l10n/app_localizations.dart';

/// Service for generating PDF invoices
class PdfService {
  PdfService._();
  static final PdfService instance = PdfService._();

  /// Generate PDF invoice
  Future<File> generateInvoicePdf({
    required InvoiceEntity invoice,
    required BusinessProfileEntity businessProfile,
    required AppLocalizations l10n,
  }) async {
    final pdf = pw.Document();

    // Load Logo
    pw.MemoryImage? profileImage;
    if (businessProfile.logoPath != null) {
      final file = File(businessProfile.logoPath!);
      if (await file.exists()) {
        profileImage = pw.MemoryImage(await file.readAsBytes());
      }
    }
    
    if (profileImage == null) {
       try {
         final logoBytes = await rootBundle.load('assets/images/logo.png');
         profileImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
       } catch (e) {
         // Fallback if asset missing
         debugPrint('Error loading default logo: $e');
       }
    }

    // Load Header Icon (Optional/Permanent)
    pw.MemoryImage? headerIcon;
    try {
      final headerIconBytes = await rootBundle.load('assets/images/invoice_header_icon.jpg');
      headerIcon = pw.MemoryImage(headerIconBytes.buffer.asUint8List());
    } catch (e) {
      debugPrint('Error loading header icon: $e');
    }

    // Load Font (with fallback)
    pw.ThemeData theme;
    pw.Font? tamilFont; // Declare outside try block
    
    try {
      final isTamil = l10n.localeName == 'ta';
      
      // Always load Custom Tamil Font (Legacy Encoding)
      final fontData = await rootBundle.load('assets/fonts/custom_Anand_MuktaMalar.ttf');
      tamilFont = pw.Font.ttf(fontData);

      if (isTamil) {
        theme = pw.ThemeData.withFont(
          base: tamilFont,
          bold: tamilFont,
        );
      } else {
        // Default Google Font for English with Tamil Fallback
        final font = await PdfGoogleFonts.notoSansRegular();
        final fontBold = await PdfGoogleFonts.notoSansBold();
        theme = pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
          fontFallback: [tamilFont],
        );
      }
    } catch (e) {
      debugPrint('Error loading fonts: $e');
      // Fallback to default font
      theme = pw.ThemeData.withFont(base: await PdfGoogleFonts.notoSansRegular());
    }

    final pageTheme = pw.PageTheme(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      buildBackground: profileImage != null ? (pw.Context context) => _buildWatermark(profileImage!) : null,
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        build: (pw.Context context) {
          return [
            // Header
            _buildHeader(businessProfile, profileImage, headerIcon, l10n),
            pw.SizedBox(height: 1),
            pw.Divider(),
            pw.SizedBox(height: 1),

            // Invoice Details
            _buildInvoiceDetails(invoice, l10n, tamilFont ?? theme.defaultTextStyle.font!),
            pw.SizedBox(height: 3),

            // Items Table
            _buildItemsTable(invoice, l10n, tamilFont ?? theme.defaultTextStyle.font!),
            pw.SizedBox(height: 5),

            // Totals
            _buildTotals(invoice, l10n),
            
            // Thank you note (appears after all items)
            _buildThankYouNote(l10n),
          ];
        },
      ),
    );

    // Save PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/invoice_${invoice.invoiceNumber}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  /// Generate Image from Invoice (for WhatsApp sharing)
  Future<File> generateInvoiceImage({
    required InvoiceEntity invoice,
    required BusinessProfileEntity businessProfile,
    required AppLocalizations l10n,
  }) async {
    // 1. Generate PDF document (in memory)
    final pdfFile = await generateInvoicePdf(invoice: invoice, businessProfile: businessProfile, l10n: l10n);
    final pdfBytes = await pdfFile.readAsBytes();

    // 2. Rasterize first page to Image
    // We assume single page invoice for image sharing usually, or we could stitch them.
    // For now, let's just take the first page which covers most billing cases.
    try {
      await for (final page in Printing.raster(pdfBytes, pages: [0], dpi: 200)) {
        final imageBytes = await page.toPng();
        final output = await getTemporaryDirectory();
        final imageFile = File('${output.path}/invoice_${invoice.invoiceNumber}.png');
        await imageFile.writeAsBytes(imageBytes);
        return imageFile; // Return immediately after first page
      }
    } catch (e) {
      debugPrint('Error rasterizing PDF: $e');
    }
    
    // Fallback? Return PDF if raster fails? 
    // For now, just return PDF file contextually treated as image might fail. 
    // Let's rely on the try block succeeding.
    return pdfFile; // Fallback to PDF if image gen fails (better than nothing)
  }

  pw.Widget _buildHeader(BusinessProfileEntity business, pw.MemoryImage? logo, pw.MemoryImage? headerIcon, AppLocalizations l10n) {
    final isTamil = l10n.localeName == 'ta';
    final name = isTamil && business.businessNameTamil != null && business.businessNameTamil!.isNotEmpty
        ? business.businessNameTamil!
        : business.businessName;
    final address = isTamil && business.businessAddressTamil != null && business.businessAddressTamil!.isNotEmpty
        ? business.businessAddressTamil!
        : (business.businessAddress ?? '');

    return pw.SizedBox(
      width: double.infinity,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (headerIcon != null)
            pw.Container(
              width: 20,
              height: 20,
              child: pw.Image(headerIcon),
            ),
          if (logo != null)
            pw.Container(
              width: 60,
              height: 60,
              child: pw.Image(logo),
            ),
        
        pw.RichText(
          text: pw.TextSpan(
            style:isTamil ? const pw.TextStyle(lineSpacing: -2) : const pw.TextStyle(lineSpacing: -1), // Even tighter vertical spacing
            children: [
              pw.TextSpan(
                text: '${name.toPrintPdf}\n',
                style: pw.TextStyle(
                  fontSize: 18, 
                  fontWeight: pw.FontWeight.bold, 
                  color: PdfColors.brown800,
                ),
              ),
              if (business.primaryPhone != null)
                pw.TextSpan(
                  text: '${l10n.phoneLabel.toPrintPdf}: ${business.primaryPhone!}\n',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
              if (address.isNotEmpty)
                pw.TextSpan(
                  text: address.toPrintPdf,
                  style: const pw.TextStyle(fontSize: 10),
                ),
            ],
          ),
          textAlign: pw.TextAlign.center,
        ),
       
      ],
      ),
    );
  }

  pw.Widget _buildInvoiceDetails(InvoiceEntity invoice, AppLocalizations l10n, pw.Font tamilFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 24.0, vertical: 0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '${l10n.nameLabel.toPrintPdf} : ${invoice.customerName?.toPrintPdf ?? '-'}',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 16,
              color: PdfColors.black,
              font: tamilFont, // Use Tamil font for user content name
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                '${l10n.dateLabel.toPrintPdf} : ${_formatDate(invoice.invoiceDate)}',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                  color: PdfColors.black,
                ),
                textAlign: pw.TextAlign.right,
              ),
            
              pw.Text(
                '${l10n.billNo.toPrintPdf} : ${invoice.invoiceNumber}',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                  color: PdfColors.black,
                ),
                textAlign: pw.TextAlign.right,
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildItemsTable(InvoiceEntity invoice, AppLocalizations l10n, pw.Font tamilFont) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.brown200, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2), // Description
        1: const pw.FlexColumnWidth(1), // Length
        2: const pw.FlexColumnWidth(1), // Qty
        3: const pw.FlexColumnWidth(1), // Total Length
        4: const pw.FlexColumnWidth(1), // Rate
        5: const pw.FlexColumnWidth(1), // Total
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.brown),
          children: [
            _buildTableCell(l10n.descriptionShort.toPrintPdf, isHeader: true, headerTextColor: PdfColors.white),
            _buildTableCell(l10n.lengthShort.toPrintPdf, isHeader: true, align: pw.TextAlign.center, headerTextColor: PdfColors.white),
            _buildTableCell(l10n.qtyShort.toPrintPdf, isHeader: true, align: pw.TextAlign.center, headerTextColor: PdfColors.white),
            _buildTableCell(l10n.totalLenShort.toPrintPdf, isHeader: true, align: pw.TextAlign.center, headerTextColor: PdfColors.white),
            _buildTableCell(l10n.rateShort.toPrintPdf, isHeader: true, align: pw.TextAlign.right, headerTextColor: PdfColors.white),
            _buildTableCell(l10n.totalShort.toPrintPdf, isHeader: true, align: pw.TextAlign.right, headerTextColor: PdfColors.white),
          ],
        ),
        // Items with alternating row colors
        ...invoice.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isEvenRow = index % 2 == 0;
          
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEvenRow ? PdfColors.orange50 : PdfColors.white,
            ),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2), // Reduced padding
                child: pw.Text(
                  '${item.productName}${item.size.isNotEmpty ? item.productName.isNotEmpty ? " - ${item.size}" : item.size : ""}'.toPrintPdf,
                  style: pw.TextStyle(
                      fontSize: 10, 
                      lineSpacing: 1.0, 
                      font: tamilFont // FORCE TAMIL FONT for Description
                  ), 
                ),
              ),
              _buildTableCell(item.length == 0 ? '-' : item.length.toStringAsFixed(2), align: pw.TextAlign.center),
              _buildTableCell(item.quantity == 0 ? '-' : item.quantity.toString(), align: pw.TextAlign.center),
              _buildTableCell(item.totalLength == 0 ? '-' : item.totalLength.toStringAsFixed(2), align: pw.TextAlign.center),
              _buildTableCell('\u20B9${item.rate.toStringAsFixed(2)}', align: pw.TextAlign.right),
              _buildTableCell('\u20B9${item.totalAmount.toStringAsFixed(2)}', align: pw.TextAlign.right),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false, pw.TextAlign align = pw.TextAlign.left, PdfColor? headerTextColor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(2),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: isHeader ? 10 : 9,
          color: isHeader && headerTextColor != null ? headerTextColor : PdfColors.black,
        ),
      ),
    );
  }

  pw.Widget _buildTotals(InvoiceEntity invoice, AppLocalizations l10n) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        
        _buildTotalRow('${l10n.grandTotal.toPrintPdf}:', '\u20B9${invoice.grandTotal.toStringAsFixed(2)}', isBold: true),
        if (invoice.paidAmount > 0)
          _buildTotalRow('${l10n.paidAmount.toPrintPdf}:', '\u20B9${invoice.paidAmount.toStringAsFixed(2)}'),
        if (invoice.balanceAmount > 0)
          _buildTotalRow('${l10n.balanceAmount.toPrintPdf}:', '\u20B9${invoice.balanceAmount.toStringAsFixed(2)}', isBold: true),
      ],
    );
  }

  pw.Widget _buildTotalRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.SizedBox(width: 5),
          pw.Container(
            width: 100,
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }


  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Build watermark with company logo
  pw.Widget _buildWatermark(pw.MemoryImage logo) {
    return pw.Center(
      child: pw.Opacity(
        opacity: 0.1,
        child: pw.Container(
          width: 350,
          height: 350,
          child: pw.Image(logo, fit: pw.BoxFit.contain),
        ),
      ),
    );
  }

  /// Build thank you note at bottom of invoice
  pw.Widget _buildThankYouNote(AppLocalizations l10n) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 12),
        pw.Center(
          child: pw.Text(
            l10n.thankYouMessage.toPrintPdf,
            style: pw.TextStyle(
              fontSize: 18,
              color: PdfColors.black,
              lineSpacing: 2.0,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
