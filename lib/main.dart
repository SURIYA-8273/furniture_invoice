import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/services/hive_service.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/language_provider.dart';
import 'presentation/providers/business_profile_provider.dart';
import 'presentation/providers/customer_provider.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/providers/billing_calculation_provider.dart';
import 'data/repositories/business_profile_repository_impl.dart';
import 'data/repositories/customer_repository_impl.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/usecases/business_profile/get_business_profile.dart';
import 'domain/usecases/business_profile/save_business_profile.dart';
import 'domain/usecases/business_profile/update_business_logo.dart';
import 'domain/usecases/customer/get_all_customers.dart';
import 'domain/usecases/customer/search_customers.dart';
import 'domain/usecases/customer/add_customer.dart';
import 'domain/usecases/customer/update_customer.dart';
import 'domain/usecases/customer/delete_customer.dart';
import 'domain/usecases/customer/get_customers_with_dues.dart';
import 'domain/usecases/product/get_all_products.dart';
import 'domain/usecases/product/search_products.dart';
import 'domain/usecases/product/add_product.dart';
import 'domain/usecases/product/update_product.dart';
import 'domain/usecases/product/delete_product.dart';
import 'domain/usecases/product/get_products_by_category.dart';
import 'domain/usecases/product/get_products_by_category.dart';
import 'domain/usecases/payment_history/add_payment.dart';
import 'domain/usecases/payment_history/get_customer_payments.dart';
import 'data/repositories/payment_history_repository_impl.dart';
import 'presentation/providers/payment_history_provider.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/customers/customer_list_screen.dart';
import 'presentation/screens/products/product_list_screen.dart';
import 'presentation/screens/billing/billing_screen.dart';
import 'presentation/screens/reports/reports_screen.dart';
import 'l10n/app_localizations.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await HiveService.instance.initialize();
  await HiveService.instance.openBoxes();
  
  // Initialize providers
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();
  
  final languageProvider = LanguageProvider();
  await languageProvider.initialize();
  
  // Initialize business profile dependencies
  final businessProfileRepository = BusinessProfileRepositoryImpl();
  final businessProfileProvider = BusinessProfileProvider(
    getBusinessProfileUseCase: GetBusinessProfile(businessProfileRepository),
    saveBusinessProfileUseCase: SaveBusinessProfile(businessProfileRepository),
    updateBusinessLogoUseCase: UpdateBusinessLogo(businessProfileRepository),
  );
  await businessProfileProvider.initialize();
  
  // Initialize customer dependencies
  final customerRepository = CustomerRepositoryImpl();
  final customerProvider = CustomerProvider(
    getAllCustomersUseCase: GetAllCustomers(customerRepository),
    searchCustomersUseCase: SearchCustomers(customerRepository),
    addCustomerUseCase: AddCustomer(customerRepository),
    updateCustomerUseCase: UpdateCustomer(customerRepository),
    deleteCustomerUseCase: DeleteCustomer(customerRepository),
    getCustomersWithDuesUseCase: GetCustomersWithDues(customerRepository),
  );
  await customerProvider.initialize();
  
  // Initialize product dependencies
  final productRepository = ProductRepositoryImpl();
  final productProvider = ProductProvider(
    getAllProductsUseCase: GetAllProducts(productRepository),
    searchProductsUseCase: SearchProducts(productRepository),
    addProductUseCase: AddProduct(productRepository),
    updateProductUseCase: UpdateProduct(productRepository),
    deleteProductUseCase: DeleteProduct(productRepository),
    getProductsByCategoryUseCase: GetProductsByCategory(productRepository),
  );
  await productProvider.initialize();

  // Initialize payment history dependencies
  final paymentHistoryRepository = PaymentHistoryRepositoryImpl();
  final paymentHistoryProvider = PaymentHistoryProvider(
    addPaymentUseCase: AddPayment(
      paymentRepository: paymentHistoryRepository,
      customerRepository: customerRepository,
    ),
    getCustomerPaymentsUseCase: GetCustomerPayments(paymentHistoryRepository),
  );
  
  // Initialize billing calculation provider
  final billingCalculationProvider = BillingCalculationProvider();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: languageProvider),
        ChangeNotifierProvider.value(value: businessProfileProvider),
        ChangeNotifierProvider.value(value: customerProvider),
        ChangeNotifierProvider.value(value: productProvider),
        ChangeNotifierProvider.value(value: productProvider),
        ChangeNotifierProvider.value(value: billingCalculationProvider),
        ChangeNotifierProvider.value(value: paymentHistoryProvider),
      ],
      child: const FurnitureBillingApp(),
    ),
  );
}

class FurnitureBillingApp extends StatelessWidget {
  const FurnitureBillingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          
          // App Title
          title: 'Furniture Billing',
          
          // Theme Configuration
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          
          // Localization Configuration
          locale: languageProvider.currentLocale,
          supportedLocales: languageProvider.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          
          // Home Screen
          home: const HomeScreen(),
        );
      },
    );
  }
}

/// Enhanced Home Screen with Grid View
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Settings are now in the Settings screen
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appName,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Production-Ready Billing Software',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // Grid View Section
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildListDelegate([
                  _HomeCard(
                    title: l10n.billing,
                    icon: Icons.receipt_long,
                    gradientColors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BillingScreen(),
                        ),
                      );
                    },
                  ),
                  _HomeCard(
                    title: l10n.customers,
                    icon: Icons.people,
                    gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CustomerListScreen(),
                        ),
                      );
                    },
                  ),

                  _HomeCard(
                    title: l10n.reports,
                    icon: Icons.analytics,
                    gradientColors: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReportsScreen(),
                        ),
                      );
                    },
                  ),
                  _HomeCard(
                    title: l10n.settings,
                    icon: Icons.settings,
                    gradientColors: const [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),

                ]),
              ),
            ),
            
            // Bottom Spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),

    );
  }
}

/// Custom Home Card Widget with Gradient Background
class _HomeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _HomeCard({
    required this.title,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
