import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/hive_service.dart';
import 'core/services/supabase_service.dart';
import 'core/background/backup_scheduler.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/language_provider.dart';
import 'presentation/providers/business_profile_provider.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/providers/billing_calculation_provider.dart';
import 'data/repositories/business_profile_repository_impl.dart';
import 'data/repositories/product_repository_impl.dart';
import 'data/repositories/invoice_repository_impl.dart';
import 'domain/usecases/business_profile/get_business_profile.dart';
import 'domain/usecases/business_profile/save_business_profile.dart';
import 'domain/usecases/business_profile/update_business_logo.dart';
import 'domain/usecases/product/get_all_products.dart';
import 'domain/usecases/product/search_products.dart';
import 'domain/usecases/product/add_product.dart';
import 'domain/usecases/product/update_product.dart';
import 'domain/usecases/product/delete_product.dart';
import 'domain/usecases/product/get_products_by_category.dart';
import 'domain/usecases/payment_history/add_payment.dart';
import 'domain/usecases/payment_history/get_invoice_payments.dart';
import 'data/repositories/payment_history_repository_impl.dart';
import 'presentation/providers/payment_history_provider.dart';
import 'presentation/providers/invoice_provider.dart';
import 'presentation/providers/description_provider.dart';
import 'data/repositories/description_repository_impl.dart';
import 'data/models/description_model.dart';
import 'core/constants/hive_box_names.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'l10n/app_localizations.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await HiveService.instance.initialize();
  await HiveService.instance.openBoxes();
  
  // Initialize environment variables from .env
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('.env file loaded successfully');
  } catch (e) {
    debugPrint('Could not load .env file: $e');
  }

  // Initialize Supabase (load from .env or environment variables)
  final supabaseUrl = dotenv.get('SUPABASE_URL', fallback: const String.fromEnvironment('SUPABASE_URL', defaultValue: ''));
  final supabaseKey = dotenv.get('SUPABASE_ANON_KEY', fallback: const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: ''));
  
  if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
    try {
      await SupabaseService.instance.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
      );
      
      // Initialize backup scheduler for automatic backups at 12:00 AM
      await BackupSchedulerService.instance.initialize(
        supabaseUrl: supabaseUrl,
        supabaseKey: supabaseKey,
      );
      
      debugPrint('Supabase and backup scheduler initialized');
    } catch (e) {
      debugPrint('Failed to initialize Supabase: $e');
    }
  } else {
    debugPrint('Supabase credentials not provided - backup features disabled');
  }
  
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
    ),
    getInvoicePaymentsUseCase: GetInvoicePayments(paymentHistoryRepository),
  );
  
  // Initialize invoice dependencies
  final invoiceRepository = InvoiceRepositoryImpl();
  final invoiceProvider = InvoiceProvider(invoiceRepository: invoiceRepository);
  
  // Initialize description dependencies
  final descriptionRepository = DescriptionRepositoryImpl(HiveService.instance.getBox<DescriptionModel>(HiveBoxNames.descriptions));
  final descriptionProvider = DescriptionProvider(repository: descriptionRepository);

  // Initialize billing calculation provider
  final billingCalculationProvider = BillingCalculationProvider();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: languageProvider),
        ChangeNotifierProvider.value(value: businessProfileProvider),
        ChangeNotifierProvider.value(value: productProvider),
        ChangeNotifierProvider.value(value: billingCalculationProvider),
        ChangeNotifierProvider.value(value: paymentHistoryProvider),
        ChangeNotifierProvider.value(value: invoiceProvider),
        ChangeNotifierProvider.value(value: descriptionProvider),
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
          home: const OnboardingScreen(),
        );
      },
    );
  }
}

