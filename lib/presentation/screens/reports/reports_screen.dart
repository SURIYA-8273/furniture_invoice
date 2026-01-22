import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../core/utils/calculation_utils.dart';
import '../../../l10n/app_localizations.dart';

/// Reports Screen with comprehensive analytics
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _selectedDateRange;
  String _selectedPeriod = 'today'; // today, week, month, custom

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _setDateRangeForPeriod('today');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: theme.textTheme.titleSmall?.copyWith(
            fontWeight: ThemeTokens.fontWeightBold,
          ),
          unselectedLabelStyle: theme.textTheme.titleSmall,
          tabs: [
            Tab(
              icon: const Icon(Icons.trending_up),
              text: l10n.totalSales,
            ),
            Tab(
              icon: const Icon(Icons.assignment_ind),
              text: l10n.customerWiseDue,
            ),
            Tab(
              icon: const Icon(Icons.history),
              text: l10n.paymentHistory,
            ),
            Tab(
              icon: const Icon(Icons.inventory),
              text: l10n.productWiseSales,
            ),
          ],
        ),
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
      body: Column(
        children: [
          // Date Range Filter
          _buildDateRangeFilter(l10n, theme),
          
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSalesSummaryTab(l10n, theme),
                _buildCustomerDuesTab(l10n, theme),
                _buildPaymentHistoryTab(l10n, theme),
                _buildProductSalesTab(l10n, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeFilter(AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ThemeTokens.spacingMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dateRange,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: ThemeTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: ThemeTokens.spacingSm),
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String period, String label, ThemeData theme) {
    return FilterChip(
      label: Text(label),
      selected: _selectedPeriod == period,
      onSelected: (selected) {
        if (selected) _setDateRangeForPeriod(period);
      },
    );
  }

  Widget _buildSalesSummaryTab(AppLocalizations l10n, ThemeData theme) {
    // Mock data - replace with actual data from provider
    final totalSales = 125000.0;
    final totalPaid = 95000.0;
    final totalPending = 30000.0;
    final invoiceCount = 15;

    return SingleChildScrollView(
      padding: EdgeInsets.all(ThemeTokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  l10n.totalSales,
                  CalculationUtils.formatCurrency(totalSales),
                  Icons.trending_up,
                  const Color(0xFF10B981),
                  theme,
                ),
              ),
              SizedBox(width: ThemeTokens.spacingMd),
              Expanded(
                child: _buildSummaryCard(
                  l10n.invoices,
                  invoiceCount.toString(),
                  Icons.receipt_long,
                  const Color(0xFF6366F1),
                  theme,
                ),
              ),
            ],
          ),
          SizedBox(height: ThemeTokens.spacingMd),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  l10n.totalPaid,
                  CalculationUtils.formatCurrency(totalPaid),
                  Icons.check_circle,
                  const Color(0xFF3B82F6),
                  theme,
                ),
              ),
              SizedBox(width: ThemeTokens.spacingMd),
              Expanded(
                child: _buildSummaryCard(
                  l10n.totalPending,
                  CalculationUtils.formatCurrency(totalPending),
                  Icons.pending,
                  const Color(0xFFF59E0B),
                  theme,
                ),
              ),
            ],
          ),
          SizedBox(height: ThemeTokens.spacingLg),
          
          // Recent Invoices
          Text(
            'Recent Invoices',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: ThemeTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: ThemeTokens.spacingMd),
          _buildRecentInvoicesList(l10n, theme),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ThemeTokens.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          SizedBox(height: ThemeTokens.spacingSm),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: ThemeTokens.spacingXs),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: ThemeTokens.fontWeightBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentInvoicesList(AppLocalizations l10n, ThemeData theme) {
    // Mock data - replace with actual data
    final invoices = [
      {'number': 'INV-001', 'customer': 'John Doe', 'amount': 15000.0, 'status': 'paid'},
      {'number': 'INV-002', 'customer': 'Jane Smith', 'amount': 25000.0, 'status': 'pending'},
      {'number': 'INV-003', 'customer': 'Bob Johnson', 'amount': 18000.0, 'status': 'partially_paid'},
    ];

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: invoices.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(invoice['status'] as String).withValues(alpha: 0.2),
              child: Icon(
                Icons.receipt,
                color: _getStatusColor(invoice['status'] as String),
              ),
            ),
            title: Text(invoice['number'] as String),
            subtitle: Text(invoice['customer'] as String),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CalculationUtils.formatCurrency(invoice['amount'] as double),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: ThemeTokens.fontWeightBold,
                  ),
                ),
                Text(
                  _getStatusLabel(invoice['status'] as String, l10n),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getStatusColor(invoice['status'] as String),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomerDuesTab(AppLocalizations l10n, ThemeData theme) {
    // Mock data - replace with actual data
    final customers = [
      {'name': 'John Doe', 'phone': '9876543210', 'due': 15000.0},
      {'name': 'Jane Smith', 'phone': '9876543211', 'due': 25000.0},
      {'name': 'Bob Johnson', 'phone': '9876543212', 'due': 8000.0},
    ];

    final totalDues = customers.fold<double>(0, (sum, c) => sum + (c['due'] as double));

    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(ThemeTokens.spacingMd),
          padding: EdgeInsets.all(ThemeTokens.spacingMd),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.totalPending,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              Text(
                CalculationUtils.formatCurrency(totalDues),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: ThemeTokens.fontWeightBold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: ThemeTokens.spacingMd),
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return Card(
                margin: EdgeInsets.only(bottom: ThemeTokens.spacingMd),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(customer['name'] as String),
                  subtitle: Text(customer['phone'] as String),
                  trailing: Text(
                    CalculationUtils.formatCurrency(customer['due'] as double),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFFEF4444),
                      fontWeight: ThemeTokens.fontWeightBold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistoryTab(AppLocalizations l10n, ThemeData theme) {
    // Mock data - replace with actual data
    final payments = [
      {
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'customer': 'John Doe',
        'amount': 5000.0,
        'mode': 'cash',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'customer': 'Jane Smith',
        'amount': 15000.0,
        'mode': 'upi',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'customer': 'Bob Johnson',
        'amount': 10000.0,
        'mode': 'card',
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(ThemeTokens.spacingMd),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return Card(
          margin: EdgeInsets.only(bottom: ThemeTokens.spacingMd),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.2),
              child: const Icon(
                Icons.payment,
                color: Color(0xFF10B981),
              ),
            ),
            title: Text(payment['customer'] as String),
            subtitle: Text(
              '${DateFormat('dd MMM yyyy, hh:mm a').format(payment['date'] as DateTime)} • ${_getPaymentModeLabel(payment['mode'] as String, l10n)}',
            ),
            trailing: Text(
              CalculationUtils.formatCurrency(payment['amount'] as double),
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF10B981),
                fontWeight: ThemeTokens.fontWeightBold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductSalesTab(AppLocalizations l10n, ThemeData theme) {
    // Mock data - replace with actual data
    final products = [
      {'name': 'Sofa 3×5', 'quantity': 12, 'sales': 45000.0},
      {'name': 'Dining Table 4×6', 'quantity': 8, 'sales': 32000.0},
      {'name': 'Bed 5×7', 'quantity': 6, 'sales': 28000.0},
    ];

    return ListView.builder(
      padding: EdgeInsets.all(ThemeTokens.spacingMd),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: EdgeInsets.only(bottom: ThemeTokens.spacingMd),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Icon(
                Icons.inventory,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            title: Text(product['name'] as String),
            subtitle: Text('${l10n.quantity}: ${product['quantity']}'),
            trailing: Text(
              CalculationUtils.formatCurrency(product['sales'] as double),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: ThemeTokens.fontWeightBold,
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFEF4444);
      case 'partially_paid':
        return const Color(0xFFF59E0B);
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status, AppLocalizations l10n) {
    switch (status) {
      case 'paid':
        return l10n.paid;
      case 'pending':
        return l10n.unpaid;
      case 'partially_paid':
        return l10n.partiallyPaid;
      default:
        return status;
    }
  }

  String _getPaymentModeLabel(String mode, AppLocalizations l10n) {
    switch (mode) {
      case 'cash':
        return l10n.cash;
      case 'card':
        return l10n.card;
      case 'upi':
        return l10n.upi;
      case 'bank_transfer':
        return l10n.bankTransfer;
      case 'cheque':
        return l10n.cheque;
      default:
        return mode;
    }
  }
}
