import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../core/utils/calculation_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/invoice_provider.dart';
import '../../../domain/entities/invoice_entity.dart';
import 'widgets/date_range_filter_card.dart';
import 'widgets/report_summary_card.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reports),
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
                DateRangeFilterCard(
                  selectedPeriod: _selectedPeriod,
                  selectedDateRange: _selectedDateRange,
                  onPeriodChanged: _setDateRangeForPeriod,
                  onCustomDateSelected: _selectCustomDateRange,
                ),
                SizedBox(height: ThemeTokens.spacingMd),

                // Summary Grid
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: ThemeTokens.spacingMd,
                  mainAxisSpacing: ThemeTokens.spacingMd,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.2,
                  children: [
                    ReportSummaryCard(
                      title: l10n.totalSales,
                      value: CalculationUtils.formatCurrency(totalSales),
                      icon: Icons.trending_up,
                      color: ThemeTokens.summaryCardSales,
                    ),
                    ReportSummaryCard(
                      title: l10n.totalPending,
                      value: CalculationUtils.formatCurrency(totalPending),
                      icon: Icons.pending,
                      color: ThemeTokens.summaryCardPending,
                    ),
                    ReportSummaryCard(
                      title: l10n.totalBills,
                      value: totalDetails.toString(),
                      icon: Icons.receipt_long,
                      color: ThemeTokens.summaryCardBills,
                    ),
                    ReportSummaryCard(
                      title: l10n.unpaidBills,
                      value: totalUnpaidBills.toString(),
                      icon: Icons.error_outline,
                      color: ThemeTokens.summaryCardUnpaid,
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
}





