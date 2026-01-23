import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../core/utils/calculation_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/invoice_provider.dart';
import '../../../domain/entities/invoice_entity.dart';

/// Reports Screen with comprehensive analytics
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTimeRange? _selectedDateRange;
  String _selectedPeriod = 'today'; // today, week, month, custom

  @override
  void initState() {
    super.initState();
    _setDateRangeForPeriod('today');
    // Ensure invoices are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceProvider>().loadInvoices();
    });
  }

  void _setDateRangeForPeriod(String period) {
    final now = DateTime.now();
    setState(() {
      _selectedPeriod = period;
      switch (period) {
        case 'today':
          _selectedDateRange = DateTimeRange(
            start: DateTime(now.year, now.month, now.day),
            end: DateTime(now.year, now.month, now.day, 23, 59, 59),
          );
          break;
        case 'week':
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          _selectedDateRange = DateTimeRange(
            start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
            end: DateTime(now.year, now.month, now.day, 23, 59, 59),
          );
          break;
        case 'month':
          _selectedDateRange = DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: DateTime(now.year, now.month, now.day, 23, 59, 59),
          );
          break;
      }
    });
  }

  Future<void> _selectCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() {
        _selectedPeriod = 'custom';
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reports),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${l10n.export} - Coming Soon')),
              );
            },
            tooltip: l10n.export,
          ),
        ],
      ),
      body: Consumer<InvoiceProvider>(
        builder: (context, invoiceProvider, child) {
          if (invoiceProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (invoiceProvider.error != null) {
            return Center(child: Text(invoiceProvider.error!));
          }

          // Filter invoices based on date range
          final filteredInvoices = _filterInvoices(invoiceProvider.invoices);

          // Calculate summary metrics
          final totalSales = filteredInvoices.fold(0.0, (sum, inv) => sum + inv.grandTotal);
          final totalPending = filteredInvoices.fold(0.0, (sum, inv) => sum + inv.balanceAmount);
          final totalDetails = filteredInvoices.length; // Total Bill count
          final totalUnpaidBills = filteredInvoices.where((inv) => inv.hasPendingBalance).length;

          return SingleChildScrollView(
            padding: EdgeInsets.all(ThemeTokens.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Range Filter
                _buildDateRangeFilter(l10n, theme),
                SizedBox(height: ThemeTokens.spacingMd),

                // Summary Grid
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: ThemeTokens.spacingMd,
                  mainAxisSpacing: ThemeTokens.spacingMd,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  children: [
                    _buildSummaryCard(
                      l10n.totalSales,
                      CalculationUtils.formatCurrency(totalSales),
                      Icons.trending_up,
                      const Color(0xFF10B981),
                      theme,
                    ),
                    _buildSummaryCard(
                      l10n.totalPending,
                      CalculationUtils.formatCurrency(totalPending),
                      Icons.pending,
                      const Color(0xFFEF4444), // Red for pending/alert
                      theme,
                    ),
                    _buildSummaryCard(
                      'Total Bill', // l10n.totalBills if available, else string
                      totalDetails.toString(),
                      Icons.receipt_long,
                      const Color(0xFF6366F1),
                      theme,
                    ),
                    _buildSummaryCard(
                      'Total Unpaid Bills', // l10n.unpaidBills if available
                      totalUnpaidBills.toString(),
                      Icons.error_outline,
                      const Color(0xFFF59E0B),
                      theme,
                    ),
                  ],
                ),
                
                // Recent Invoices Removed
              ],
            ),
          );
        },
      ),
    );
  }

  List<InvoiceEntity> _filterInvoices(List<InvoiceEntity> invoices) {
    if (_selectedDateRange == null) return invoices;
    
    return invoices.where((invoice) {
      return invoice.invoiceDate.isAfter(_selectedDateRange!.start.subtract(const Duration(seconds: 1))) &&
             invoice.invoiceDate.isBefore(_selectedDateRange!.end.add(const Duration(seconds: 1)));
    }).toList();
  }

  Widget _buildDateRangeFilter(AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ThemeTokens.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.dateRange.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.grey[600],
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          SizedBox(height: ThemeTokens.spacingMd),
          Wrap(
            spacing: ThemeTokens.spacingSm,
            runSpacing: ThemeTokens.spacingSm,
            children: [
              _buildPeriodChip('today', 'Today', theme),
              _buildPeriodChip('week', 'This Week', theme),
              _buildPeriodChip('month', 'This Month', theme),
              FilterChip(
                label: Text(_selectedPeriod == 'custom' && _selectedDateRange != null
                    ? '${DateFormat('dd/MM').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM').format(_selectedDateRange!.end)}'
                    : 'Custom'),
                selected: _selectedPeriod == 'custom',
                onSelected: (selected) => _selectCustomDateRange(),
                backgroundColor: Colors.grey[100],
                selectedColor: theme.colorScheme.primaryContainer,
                checkmarkColor: theme.colorScheme.primary,
                labelStyle: TextStyle(
                  color: _selectedPeriod == 'custom' ? theme.colorScheme.primary : Colors.black87,
                  fontWeight: _selectedPeriod == 'custom' ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: _selectedPeriod == 'custom' ? theme.colorScheme.primary.withOpacity(0.5) : Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String period, String label, ThemeData theme) {
    final isSelected = _selectedPeriod == period;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) _setDateRangeForPeriod(period);
      },
      backgroundColor: Colors.grey[100],
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.5) : Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ThemeTokens.spacingMd),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisSize: MainAxisSize.min,
             children: [
               FittedBox(
                 fit: BoxFit.scaleDown,
                 alignment: Alignment.centerLeft,
                 child: Text(
                   value,
                   style: theme.textTheme.headlineSmall?.copyWith(
                     fontWeight: ThemeTokens.fontWeightBold,
                     color: theme.colorScheme.onSurface,
                     fontSize: 22,
                   ),
                 ),
               ),
               const SizedBox(height: 4),
               Text(
                 title,
                 style: theme.textTheme.bodyMedium?.copyWith(
                   color: theme.colorScheme.onSurfaceVariant,
                   fontSize: 12,
                 ),
                 maxLines: 2,
                 overflow: TextOverflow.ellipsis,
               ),
             ],
          ),
        ],
      ),
    );
  }




}
