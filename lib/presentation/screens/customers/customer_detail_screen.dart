import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../core/utils/calculation_utils.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/payment_history_entity.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/payment_history_provider.dart';
import '../../providers/customer_provider.dart';

class CustomerDetailScreen extends StatefulWidget {
  final CustomerEntity customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late CustomerEntity _currentCustomer;

  @override
  void initState() {
    super.initState();
    _currentCustomer = widget.customer;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentHistoryProvider>().loadPayments(_currentCustomer.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    // Listen to customer provider to get updates on customer data (like balance changes)
    final customerProvider = context.watch<CustomerProvider>();
    final updatedCustomer = customerProvider.customers.firstWhere(
      (c) => c.id == widget.customer.id, 
      orElse: () => _currentCustomer,
    );
    _currentCustomer = updatedCustomer;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customerDetails),
        elevation: 0,
      ),
      body: Consumer<PaymentHistoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadPayments(_currentCustomer.id);
            },
            child: ListView(
              padding: EdgeInsets.all(ThemeTokens.spacingMd),
              children: [
                // Summary Card
                _buildSummaryCard(theme, l10n),
                
                SizedBox(height: ThemeTokens.spacingLg),
                
                // History Section Header
                Text(
                  l10n.paymentHistory,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: ThemeTokens.spacingSm),
                
                // History List
                if (provider.payments.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(ThemeTokens.spacingXl),
                      child: Text(
                        'No payment history found', // TODO: Localize
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  ...provider.payments.map((payment) => _buildPaymentItem(payment, theme, l10n)),
                  
                SizedBox(height: 80), // Fab spacing
              ],
            ),
          );
        },
      ),
      floatingActionButton: _currentCustomer.hasPendingDues
          ? FloatingActionButton.extended(
              onPressed: () => _showRecordPaymentDialog(context),
              label: Text(l10n.recordPayment),
              icon: const Icon(Icons.payment),
            )
          : null,
    );
  }

  Widget _buildSummaryCard(ThemeData theme, AppLocalizations l10n) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(ThemeTokens.spacingMd),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    _currentCustomer.name.substring(0, 1).toUpperCase(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                SizedBox(width: ThemeTokens.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentCustomer.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_currentCustomer.phone != null)
                        Text(
                          _currentCustomer.phone!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      if (_currentCustomer.address != null)
                        Text(
                          _currentCustomer.address!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  theme,
                  'Total Billed', // TODO: Localize
                  CalculationUtils.formatCurrency(_currentCustomer.totalBilled),
                  Colors.blue,
                ),
                _buildStatItem(
                  theme,
                  l10n.totalPaid,
                  CalculationUtils.formatCurrency(_currentCustomer.totalPaid),
                  Colors.green,
                ),
                _buildStatItem(
                  theme,
                  l10n.pendingDues,
                  CalculationUtils.formatCurrency(_currentCustomer.outstandingBalance),
                  _currentCustomer.hasPendingDues ? Colors.red : Colors.grey,
                  isLarge: true,
                ),
              ],
            ),
            if (_currentCustomer.isDueCleared)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'Due Cleared', // TODO: Localize
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String label, String value, Color color, {bool isLarge = false}) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: isLarge ? 18 : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentItem(PaymentHistoryEntity payment, ThemeData theme, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getPaymentModeIcon(payment.paymentMode),
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          CalculationUtils.formatCurrency(payment.paidAmount),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        subtitle: Text(
          DateFormat('MMM d, yyyy • h:mm a').format(payment.paymentDate),
          style: theme.textTheme.bodySmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(),
                _buildDetailRow(theme, 'Previous Due', CalculationUtils.formatCurrency(payment.previousDue)), // TODO: Localize
                const SizedBox(height: 4),
                _buildDetailRow(theme, 'Remaining Due', CalculationUtils.formatCurrency(payment.remainingDue)), // TODO: Localize
                const SizedBox(height: 4),
                _buildDetailRow(theme, l10n.paymentMode, payment.paymentMode),
                if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Notes:', // TODO: Localize
                    style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    payment.notes!,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getPaymentModeIcon(String mode) {
    switch (mode.toLowerCase()) {
      case 'cash': return Icons.money;
      case 'upi': return Icons.qr_code;
      case 'card': return Icons.credit_card;
      case 'bank': return Icons.account_balance;
      default: return Icons.payment;
    }
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showRecordPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _RecordPaymentDialog(
        currentDue: _currentCustomer.outstandingBalance,
        onSave: (amount, mode, notes) async {
          final payment = PaymentHistoryEntity(
            id: const Uuid().v4(),
            customerId: _currentCustomer.id,
            paymentDate: DateTime.now(),
            paidAmount: amount,
            paymentMode: mode,
            previousDue: _currentCustomer.outstandingBalance,
            remainingDue: _currentCustomer.outstandingBalance - amount,
            notes: notes,
            createdAt: DateTime.now(),
          );
          
          final success = await context.read<PaymentHistoryProvider>().recordPayment(payment);
          
          if (success && mounted) {
            // Refresh customer data
             await context.read<CustomerProvider>().loadCustomers(); // Reload to get updated balance
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment recorded successfully')), // TODO: Localize
            );
          }
        },
      ),
    );
  }
}

class _RecordPaymentDialog extends StatefulWidget {
  final double currentDue;
  final Function(double, String, String?) onSave;

  const _RecordPaymentDialog({
    required this.currentDue,
    required this.onSave,
  });

  @override
  State<_RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends State<_RecordPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedMode = 'Cash';

  @override
  void initState() {
    super.initState();
    // Pre-fill with full amount? No, let user type.
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Text(l10n.recordPayment),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Due: ${CalculationUtils.formatCurrency(widget.currentDue)}', // TODO: Localize
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: l10n.paymentAmount,
                prefixText: '₹ ',
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.validationRequired;
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Invalid amount'; // TODO: Localize
                }
                if (amount > widget.currentDue) {
                  return 'Amount exceeds due'; // TODO: Localize
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedMode,
              decoration: InputDecoration(
                labelText: l10n.paymentMode,
                border: const OutlineInputBorder(),
              ),
              items: ['Cash', 'UPI', 'Card', 'Bank Transfer', 'Cheque']
                  .map((mode) => DropdownMenuItem(
                        value: mode,
                        child: Text(mode),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedMode = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.notes + ' (${l10n.optional})',
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                double.parse(_amountController.text),
                _selectedMode,
                _notesController.text.isEmpty ? null : _notesController.text,
              );
              Navigator.pop(context);
            }
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
