import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/customer_provider.dart';
import 'customer_form_screen.dart';
import 'customer_detail_screen.dart';

/// Customer List Screen
/// Displays all customers with search and balance information
class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customers),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(ThemeTokens.spacingMd),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchCustomers,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<CustomerProvider>().clearSearch();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                context.read<CustomerProvider>().searchCustomers(value);
              },
            ),
          ),

          // Customer List
          Expanded(
            child: Consumer<CustomerProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: ThemeTokens.errorColor),
                        SizedBox(height: ThemeTokens.spacingMd),
                        Text(provider.error!),
                        SizedBox(height: ThemeTokens.spacingMd),
                        ElevatedButton(
                          onPressed: () => provider.loadCustomers(),
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.customers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: theme.colorScheme.outline),
                        SizedBox(height: ThemeTokens.spacingMd),
                        Text(
                          l10n.noCustomersFound,
                          style: theme.textTheme.titleMedium,
                        ),
                        SizedBox(height: ThemeTokens.spacingSm),
                        Text(
                          l10n.addFirstCustomer,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: provider.customers.length,
                  padding: EdgeInsets.symmetric(horizontal: ThemeTokens.spacingMd),
                  itemBuilder: (context, index) {
                    final customer = provider.customers[index];
                    final hasBalance = customer.outstandingBalance > 0;

                    return Card(
                      margin: EdgeInsets.only(bottom: ThemeTokens.spacingSm),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: hasBalance
                              ? ThemeTokens.warningColor.withValues(alpha: 0.2)
                              : ThemeTokens.successColor.withValues(alpha: 0.2),
                          child: Icon(
                            Icons.person,
                            color: hasBalance ? ThemeTokens.warningColor : ThemeTokens.successColor,
                          ),
                        ),
                        title: Text(
                          customer.name,
                          style: theme.textTheme.titleMedium,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (customer.phone != null)
                              Text(customer.phone!),
                            SizedBox(height: ThemeTokens.spacingXs),
                            Row(
                              children: [
                                Text(
                                  '${l10n.balance}: ',
                                  style: theme.textTheme.bodySmall,
                                ),
                                Text(
                                  '₹${customer.outstandingBalance.toStringAsFixed(2)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: hasBalance ? ThemeTokens.errorColor : ThemeTokens.successColor,
                                    fontWeight: ThemeTokens.fontWeightSemiBold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomerDetailScreen(customer: customer),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CustomerFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
