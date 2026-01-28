import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/theme_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../providers/payment_history_provider.dart';

class PaymentHistoryList extends StatelessWidget {
  const PaymentHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.paymentHistory.toUpperCase(), style: const TextStyle( fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              const Icon(Icons.history, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Consumer<PaymentHistoryProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator(strokeWidth: 2));
              }
              
              final payments = provider.payments.toList();
              if (payments.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                  child: Text(l10n.noPreviousPayments, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  final p = payments[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: ThemeTokens.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.payment, size: 20, color: ThemeTokens.primaryColor),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('dd MMM yyyy').format(p.paymentDate),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    _getLocalizedPaymentMode(p.paymentMode, l10n),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            '₹${p.paidAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900, 
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _getLocalizedPaymentMode(String mode, AppLocalizations l10n) {
    switch (mode.toLowerCase()) {
      case 'cash':
        return l10n.cash;
      case 'card':
        return l10n.card;
      case 'upi':
        return l10n.upi;
      case 'bank transfer':
      case 'banktransfer':
        return l10n.bankTransfer;
      case 'cheque':
        return l10n.cheque;
      default:
        return mode;
    }
  }
}
