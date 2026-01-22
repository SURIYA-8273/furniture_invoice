import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/invoice_entity.dart';

/// Service for WhatsApp sharing integration
class WhatsAppService {
  WhatsAppService._();
  static final WhatsAppService instance = WhatsAppService._();

  /// Share invoice via WhatsApp
  Future<bool> shareInvoice({
    required String phoneNumber,
    required InvoiceEntity invoice,
    required File pdfFile,
  }) async {
    // Validate phone number
    if (phoneNumber.isEmpty) {
      throw Exception('Phone number is required for WhatsApp sharing');
    }

    // Clean phone number (remove +, spaces, etc.)
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Create message
    final message = _createInvoiceMessage(invoice);

    // Create WhatsApp URL
    final whatsappUrl = _createWhatsAppUrl(cleanPhone, message);

    // Try to launch WhatsApp
    final uri = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('WhatsApp is not installed on this device');
    }
  }

  /// Create pre-filled message for invoice
  String _createInvoiceMessage(InvoiceEntity invoice) {
    final buffer = StringBuffer();
    buffer.writeln('Dear ${invoice.customerName},');
    buffer.writeln();
    buffer.writeln('Your invoice ${invoice.invoiceNumber} details:');
    buffer.writeln('Amount: ₹${invoice.grandTotal.toStringAsFixed(2)}');
    
    if (invoice.paidAmount > 0) {
      buffer.writeln('Paid: ₹${invoice.paidAmount.toStringAsFixed(2)}');
    }
    
    if (invoice.balanceAmount > 0) {
      buffer.writeln('Balance: ₹${invoice.balanceAmount.toStringAsFixed(2)}');
    }
    
    buffer.writeln();
    buffer.writeln('Thank you for your business!');

    return buffer.toString();
  }

  /// Create WhatsApp URL
  String _createWhatsAppUrl(String phoneNumber, String message) {
    final encodedMessage = Uri.encodeComponent(message);
    
    // Use WhatsApp API URL
    // For web: https://wa.me/
    // For app: whatsapp://send
    if (Platform.isAndroid || Platform.isIOS) {
      return 'whatsapp://send?phone=$phoneNumber&text=$encodedMessage';
    } else {
      return 'https://wa.me/$phoneNumber?text=$encodedMessage';
    }
  }

  /// Check if WhatsApp is available
  Future<bool> isWhatsAppAvailable() async {
    final uri = Uri.parse('whatsapp://send');
    return await canLaunchUrl(uri);
  }

  /// Share text message via WhatsApp
  Future<bool> shareTextMessage({
    required String phoneNumber,
    required String message,
  }) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final whatsappUrl = _createWhatsAppUrl(cleanPhone, message);
    
    final uri = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('WhatsApp is not installed on this device');
    }
  }
}
