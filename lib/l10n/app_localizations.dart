import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ta'),
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'Furniture Billing'**
  String get appName;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Production-Ready Billing Software'**
  String get appSubtitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomer;

  /// No description provided for @editCustomer.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer'**
  String get editCustomer;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// No description provided for @enterCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Enter customer name'**
  String get enterCustomerName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @searchCustomers.
  ///
  /// In en, this message translates to:
  /// **'Search customers by name or phone'**
  String get searchCustomers;

  /// No description provided for @noCustomersFound.
  ///
  /// In en, this message translates to:
  /// **'No customers found'**
  String get noCustomersFound;

  /// No description provided for @addFirstCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add your first customer to get started'**
  String get addFirstCustomer;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @billing.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get billing;

  /// No description provided for @invoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @businessProfile.
  ///
  /// In en, this message translates to:
  /// **'Business Profile'**
  String get businessProfile;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @customerPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get customerPhone;

  /// No description provided for @customerAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get customerAddress;

  /// No description provided for @customerBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get customerBalance;

  /// No description provided for @customerDetails.
  ///
  /// In en, this message translates to:
  /// **'Customer Details'**
  String get customerDetails;

  /// No description provided for @customerList.
  ///
  /// In en, this message translates to:
  /// **'Customer List'**
  String get customerList;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @productPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get productPrice;

  /// No description provided for @productSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get productSize;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @updateProduct.
  ///
  /// In en, this message translates to:
  /// **'Update Product'**
  String get updateProduct;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// No description provided for @productList.
  ///
  /// In en, this message translates to:
  /// **'Product List'**
  String get productList;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products by name'**
  String get searchProducts;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @addYourFirstProduct.
  ///
  /// In en, this message translates to:
  /// **'Add your first product to get started'**
  String get addYourFirstProduct;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptions.
  ///
  /// In en, this message translates to:
  /// **'Descriptions'**
  String get descriptions;

  /// No description provided for @manageDescriptions.
  ///
  /// In en, this message translates to:
  /// **'Manage Descriptions'**
  String get manageDescriptions;

  /// No description provided for @addDescription.
  ///
  /// In en, this message translates to:
  /// **'Add Description'**
  String get addDescription;

  /// No description provided for @editDescription.
  ///
  /// In en, this message translates to:
  /// **'Edit Description'**
  String get editDescription;

  /// No description provided for @deleteDescription.
  ///
  /// In en, this message translates to:
  /// **'Delete Description'**
  String get deleteDescription;

  /// No description provided for @noDescriptionsYet.
  ///
  /// In en, this message translates to:
  /// **'No descriptions added yet'**
  String get noDescriptionsYet;

  /// No description provided for @enterDescriptionText.
  ///
  /// In en, this message translates to:
  /// **'Enter description text'**
  String get enterDescriptionText;

  /// No description provided for @deleteDescriptionConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{text}\"?'**
  String deleteDescriptionConfirmation(String text);

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @enterProductName.
  ///
  /// In en, this message translates to:
  /// **'Enter product name'**
  String get enterProductName;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get enterDescription;

  /// No description provided for @enterMRP.
  ///
  /// In en, this message translates to:
  /// **'Enter MRP'**
  String get enterMRP;

  /// No description provided for @enterSize.
  ///
  /// In en, this message translates to:
  /// **'Enter size (e.g., 3×5, 4×6)'**
  String get enterSize;

  /// No description provided for @enterCategory.
  ///
  /// In en, this message translates to:
  /// **'Enter category'**
  String get enterCategory;

  /// No description provided for @productNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Product name is required'**
  String get productNameRequired;

  /// No description provided for @rateRequired.
  ///
  /// In en, this message translates to:
  /// **'Rate is required'**
  String get rateRequired;

  /// No description provided for @invalidMRP.
  ///
  /// In en, this message translates to:
  /// **'Invalid MRP. Must be greater than 0'**
  String get invalidMRP;

  /// No description provided for @productAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product added successfully'**
  String get productAddedSuccessfully;

  /// No description provided for @productUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully'**
  String get productUpdatedSuccessfully;

  /// No description provided for @productDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully'**
  String get productDeletedSuccessfully;

  /// No description provided for @errorSavingProduct.
  ///
  /// In en, this message translates to:
  /// **'Error saving product'**
  String get errorSavingProduct;

  /// No description provided for @errorDeletingProduct.
  ///
  /// In en, this message translates to:
  /// **'Error deleting product'**
  String get errorDeletingProduct;

  /// No description provided for @deleteProductConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this product?'**
  String get deleteProductConfirmation;

  /// No description provided for @invoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice Number'**
  String get invoiceNumber;

  /// No description provided for @invoiceDate.
  ///
  /// In en, this message translates to:
  /// **'Invoice Date'**
  String get invoiceDate;

  /// No description provided for @invoiceTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get invoiceTotal;

  /// No description provided for @invoiceStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get invoiceStatus;

  /// No description provided for @createInvoice.
  ///
  /// In en, this message translates to:
  /// **'Create Invoice'**
  String get createInvoice;

  /// No description provided for @invoiceDetails.
  ///
  /// In en, this message translates to:
  /// **'Invoice Details'**
  String get invoiceDetails;

  /// No description provided for @serialNumber.
  ///
  /// In en, this message translates to:
  /// **'S.No'**
  String get serialNumber;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @length.
  ///
  /// In en, this message translates to:
  /// **'LEN'**
  String get length;

  /// No description provided for @totalLength.
  ///
  /// In en, this message translates to:
  /// **'Total Length'**
  String get totalLength;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'RATE'**
  String get rate;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get grandTotal;

  /// No description provided for @paidAmount.
  ///
  /// In en, this message translates to:
  /// **'Paid Amount'**
  String get paidAmount;

  /// No description provided for @balanceAmount.
  ///
  /// In en, this message translates to:
  /// **'Balance Amount'**
  String get balanceAmount;

  /// No description provided for @remainingBalance.
  ///
  /// In en, this message translates to:
  /// **'REMAINING BALANCE'**
  String get remainingBalance;

  /// No description provided for @editBillAndPayment.
  ///
  /// In en, this message translates to:
  /// **'Edit Bill & Payment'**
  String get editBillAndPayment;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// No description provided for @noPreviousPayments.
  ///
  /// In en, this message translates to:
  /// **'No previous payments'**
  String get noPreviousPayments;

  /// No description provided for @enterPaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Payment Amount'**
  String get enterPaymentAmount;

  /// No description provided for @updatePayment.
  ///
  /// In en, this message translates to:
  /// **'Update Payment'**
  String get updatePayment;

  /// No description provided for @paymentUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Payment updated and saved successfully!'**
  String get paymentUpdatedSuccessfully;

  /// No description provided for @shareInvoice.
  ///
  /// In en, this message translates to:
  /// **'Share Invoice'**
  String get shareInvoice;

  /// No description provided for @whatsappNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Number (Optional)'**
  String get whatsappNumberOptional;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @businessProfileMissing.
  ///
  /// In en, this message translates to:
  /// **'Business Profile Missing'**
  String get businessProfileMissing;

  /// No description provided for @businessProfileSetupMessage.
  ///
  /// In en, this message translates to:
  /// **'Please set up your business profile (Name, Address, Logo) in Settings before generating invoices.'**
  String get businessProfileSetupMessage;

  /// No description provided for @businessNameTamil.
  ///
  /// In en, this message translates to:
  /// **'Business Name (Tamil)'**
  String get businessNameTamil;

  /// No description provided for @businessAddressTamil.
  ///
  /// In en, this message translates to:
  /// **'Address (Tamil)'**
  String get businessAddressTamil;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @languageSelection.
  ///
  /// In en, this message translates to:
  /// **'Language Selection'**
  String get languageSelection;

  /// No description provided for @pdfGeneratedAt.
  ///
  /// In en, this message translates to:
  /// **'PDF Generated at {path}'**
  String pdfGeneratedAt(Object path);

  /// No description provided for @invoicePreview.
  ///
  /// In en, this message translates to:
  /// **'Invoice Preview'**
  String get invoicePreview;

  /// No description provided for @shareViaWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Share via WhatsApp'**
  String get shareViaWhatsApp;

  /// No description provided for @backToDashboard.
  ///
  /// In en, this message translates to:
  /// **'BACK TO DASHBOARD'**
  String get backToDashboard;

  /// No description provided for @newBill.
  ///
  /// In en, this message translates to:
  /// **'NEW BILL'**
  String get newBill;

  /// No description provided for @generateBill.
  ///
  /// In en, this message translates to:
  /// **'Generate Bill'**
  String get generateBill;

  /// No description provided for @allDataCleared.
  ///
  /// In en, this message translates to:
  /// **'All data cleared'**
  String get allDataCleared;

  /// No description provided for @pleaseAddItems.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one item to the bill'**
  String get pleaseAddItems;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'ADD ITEM'**
  String get addItem;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get next;

  /// No description provided for @balanceDue.
  ///
  /// In en, this message translates to:
  /// **'Balance Due'**
  String get balanceDue;

  /// No description provided for @desc.
  ///
  /// In en, this message translates to:
  /// **'Desc'**
  String get desc;

  /// No description provided for @noItemsAdded.
  ///
  /// In en, this message translates to:
  /// **'No items added'**
  String get noItemsAdded;

  /// No description provided for @clearAllDataQuestion.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data?'**
  String get clearAllDataQuestion;

  /// No description provided for @clearAllDataWarning.
  ///
  /// In en, this message translates to:
  /// **'This will reset all billing items and payment details. This action cannot be undone.'**
  String get clearAllDataWarning;

  /// No description provided for @clearAllAction.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAllAction;

  /// No description provided for @paymentMode.
  ///
  /// In en, this message translates to:
  /// **'Payment Mode'**
  String get paymentMode;

  /// No description provided for @paymentDate.
  ///
  /// In en, this message translates to:
  /// **'Payment Date'**
  String get paymentDate;

  /// No description provided for @paymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Payment Amount'**
  String get paymentAmount;

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get recordPayment;

  /// No description provided for @partialPayment.
  ///
  /// In en, this message translates to:
  /// **'Partial Payment'**
  String get partialPayment;

  /// No description provided for @fullPayment.
  ///
  /// In en, this message translates to:
  /// **'Full Payment'**
  String get fullPayment;

  /// No description provided for @pendingDues.
  ///
  /// In en, this message translates to:
  /// **'Pending Dues'**
  String get pendingDues;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// No description provided for @upi.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get upi;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// No description provided for @cheque.
  ///
  /// In en, this message translates to:
  /// **'Cheque'**
  String get cheque;

  /// No description provided for @dailyReport.
  ///
  /// In en, this message translates to:
  /// **'Daily Report'**
  String get dailyReport;

  /// No description provided for @weeklyReport.
  ///
  /// In en, this message translates to:
  /// **'Weekly Report'**
  String get weeklyReport;

  /// No description provided for @monthlyReport.
  ///
  /// In en, this message translates to:
  /// **'Monthly Report'**
  String get monthlyReport;

  /// No description provided for @customReport.
  ///
  /// In en, this message translates to:
  /// **'Custom Report'**
  String get customReport;

  /// No description provided for @totalSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get totalSales;

  /// No description provided for @totalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get totalPaid;

  /// No description provided for @totalPending.
  ///
  /// In en, this message translates to:
  /// **'Total Pending'**
  String get totalPending;

  /// No description provided for @customerWiseDue.
  ///
  /// In en, this message translates to:
  /// **'Customer-wise Due'**
  String get customerWiseDue;

  /// No description provided for @productWiseSales.
  ///
  /// In en, this message translates to:
  /// **'Product-wise Sales'**
  String get productWiseSales;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get businessName;

  /// No description provided for @businessLogo.
  ///
  /// In en, this message translates to:
  /// **'Business Logo'**
  String get businessLogo;

  /// No description provided for @whatsappNumber.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Number'**
  String get whatsappNumber;

  /// No description provided for @primaryPhone.
  ///
  /// In en, this message translates to:
  /// **'Primary Phone'**
  String get primaryPhone;

  /// No description provided for @additionalPhone.
  ///
  /// In en, this message translates to:
  /// **'Additional Phone'**
  String get additionalPhone;

  /// No description provided for @instagramId.
  ///
  /// In en, this message translates to:
  /// **'Instagram ID'**
  String get instagramId;

  /// No description provided for @websiteUrl.
  ///
  /// In en, this message translates to:
  /// **'Website URL'**
  String get websiteUrl;

  /// No description provided for @gstNumber.
  ///
  /// In en, this message translates to:
  /// **'GST Number'**
  String get gstNumber;

  /// No description provided for @businessAddress.
  ///
  /// In en, this message translates to:
  /// **'Business Address'**
  String get businessAddress;

  /// No description provided for @uploadLogo.
  ///
  /// In en, this message translates to:
  /// **'Upload Logo'**
  String get uploadLogo;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get tamil;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @cloudBackup.
  ///
  /// In en, this message translates to:
  /// **'Cloud Backup'**
  String get cloudBackup;

  /// No description provided for @driveBackup.
  ///
  /// In en, this message translates to:
  /// **'Drive Backup'**
  String get driveBackup;

  /// No description provided for @lastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last backup: {time}'**
  String lastBackup(String time);

  /// No description provided for @backupNow.
  ///
  /// In en, this message translates to:
  /// **'Backup Now'**
  String get backupNow;

  /// No description provided for @restoreFromBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from Backup'**
  String get restoreFromBackup;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @darkModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode Enabled'**
  String get darkModeEnabled;

  /// No description provided for @lightModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Light Mode Enabled'**
  String get lightModeEnabled;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @manageBusinessDetails.
  ///
  /// In en, this message translates to:
  /// **'Manage your business details'**
  String get manageBusinessDetails;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @backupYourData.
  ///
  /// In en, this message translates to:
  /// **'Backup your data'**
  String get backupYourData;

  /// No description provided for @backupFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Backup feature coming soon'**
  String get backupFeatureComingSoon;

  /// No description provided for @restoreFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Restore feature coming soon'**
  String get restoreFeatureComingSoon;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'1.0.0'**
  String get appVersion;

  /// No description provided for @backupSettings.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupSettings;

  /// No description provided for @connectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Cloud Connection'**
  String get connectionStatus;

  /// No description provided for @connectedToSupabase.
  ///
  /// In en, this message translates to:
  /// **'Connected to Cloud'**
  String get connectedToSupabase;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// No description provided for @supabaseNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Cloud Backup Not Configured'**
  String get supabaseNotConfigured;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test Connection'**
  String get testConnection;

  /// No description provided for @manualBackup.
  ///
  /// In en, this message translates to:
  /// **'Manual Cloud Backup'**
  String get manualBackup;

  /// No description provided for @manualBackupDescription.
  ///
  /// In en, this message translates to:
  /// **'Backup your bills and payment data to the secure cloud manually.'**
  String get manualBackupDescription;

  /// No description provided for @automaticBackup.
  ///
  /// In en, this message translates to:
  /// **'Automatic Cloud Backup'**
  String get automaticBackup;

  /// No description provided for @automaticBackupDescription.
  ///
  /// In en, this message translates to:
  /// **'Your data is automatically backed up to the cloud daily at 12:00 AM.'**
  String get automaticBackupDescription;

  /// No description provided for @enableAutomaticBackup.
  ///
  /// In en, this message translates to:
  /// **'Enable Automatic Backup'**
  String get enableAutomaticBackup;

  /// No description provided for @backupTime.
  ///
  /// In en, this message translates to:
  /// **'Backup Time'**
  String get backupTime;

  /// No description provided for @dailyBackupTime.
  ///
  /// In en, this message translates to:
  /// **'Daily Backup Time'**
  String get dailyBackupTime;

  /// No description provided for @lastImport.
  ///
  /// In en, this message translates to:
  /// **'Last restore: {time}'**
  String lastImport(Object time);

  /// No description provided for @automaticImport.
  ///
  /// In en, this message translates to:
  /// **'Automatic Restore'**
  String get automaticImport;

  /// No description provided for @automaticImportDescription.
  ///
  /// In en, this message translates to:
  /// **'Your data is automatically restored from the cloud daily at 1:00 AM.'**
  String get automaticImportDescription;

  /// No description provided for @enableAutomaticImport.
  ///
  /// In en, this message translates to:
  /// **'Enable Automatic Restore'**
  String get enableAutomaticImport;

  /// No description provided for @dailyImportTime.
  ///
  /// In en, this message translates to:
  /// **'Daily Restore Time'**
  String get dailyImportTime;

  /// No description provided for @aboutImport.
  ///
  /// In en, this message translates to:
  /// **'About Restore'**
  String get aboutImport;

  /// No description provided for @aboutImportDescription.
  ///
  /// In en, this message translates to:
  /// **'Data is automatically restored from the cloud to ensure all devices are in sync.'**
  String get aboutImportDescription;

  /// No description provided for @aboutBackups.
  ///
  /// In en, this message translates to:
  /// **'About Backups'**
  String get aboutBackups;

  /// No description provided for @aboutBackupsDescription.
  ///
  /// In en, this message translates to:
  /// **'Your data is securely backed up to cloud storage. Both new and updated bills are automatically synced.'**
  String get aboutBackupsDescription;

  /// No description provided for @startingBackup.
  ///
  /// In en, this message translates to:
  /// **'Starting backup...'**
  String get startingBackup;

  /// No description provided for @backupSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Backup Successful'**
  String get backupSuccessful;

  /// No description provided for @dataBackedUpSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your data has been backed up successfully!'**
  String get dataBackedUpSuccessfully;

  /// No description provided for @billsSynced.
  ///
  /// In en, this message translates to:
  /// **'Bills synced:'**
  String get billsSynced;

  /// No description provided for @billsFailed.
  ///
  /// In en, this message translates to:
  /// **'Bills failed:'**
  String get billsFailed;

  /// No description provided for @paymentsSynced.
  ///
  /// In en, this message translates to:
  /// **'Payments synced:'**
  String get paymentsSynced;

  /// No description provided for @paymentsFailed.
  ///
  /// In en, this message translates to:
  /// **'Payments failed:'**
  String get paymentsFailed;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @importFromSupabase.
  ///
  /// In en, this message translates to:
  /// **'Restore from Cloud'**
  String get importFromSupabase;

  /// No description provided for @importFromSupabaseDescription.
  ///
  /// In en, this message translates to:
  /// **'Fetch all bills and payments from the cloud and save them locally.'**
  String get importFromSupabaseDescription;

  /// No description provided for @importNow.
  ///
  /// In en, this message translates to:
  /// **'Restore Now'**
  String get importNow;

  /// No description provided for @importFromCloudConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from Cloud?'**
  String get importFromCloudConfirmTitle;

  /// No description provided for @importFromCloudConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will fetch all data from the cloud and merge it with your local data.'**
  String get importFromCloudConfirmMessage;

  /// No description provided for @importSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Restore Successful'**
  String get importSuccessful;

  /// No description provided for @dataImportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Data successfully restored from cloud.'**
  String get dataImportedSuccessfully;

  /// No description provided for @billsRestored.
  ///
  /// In en, this message translates to:
  /// **'Bills Restored'**
  String get billsRestored;

  /// No description provided for @paymentsRestored.
  ///
  /// In en, this message translates to:
  /// **'Payments Restored'**
  String get paymentsRestored;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore Failed'**
  String get importFailed;

  /// No description provided for @importError.
  ///
  /// In en, this message translates to:
  /// **'Restore Error'**
  String get importError;

  /// No description provided for @excelSyncSettings.
  ///
  /// In en, this message translates to:
  /// **'Excel Report Settings'**
  String get excelSyncSettings;

  /// No description provided for @enableExcelSync.
  ///
  /// In en, this message translates to:
  /// **'Enable Weekly Excel Report'**
  String get enableExcelSync;

  /// No description provided for @excelSyncDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically export data to an Excel file in your Documents folder.'**
  String get excelSyncDescription;

  /// No description provided for @syncFrequency.
  ///
  /// In en, this message translates to:
  /// **'Export Frequency'**
  String get syncFrequency;

  /// No description provided for @everyDays.
  ///
  /// In en, this message translates to:
  /// **'Every {days} days'**
  String everyDays(Object days);

  /// No description provided for @manualExcelSync.
  ///
  /// In en, this message translates to:
  /// **'Manual Excel Export'**
  String get manualExcelSync;

  /// No description provided for @manualExcelSyncDescription.
  ///
  /// In en, this message translates to:
  /// **'Export your data to an Excel file immediately.'**
  String get manualExcelSyncDescription;

  /// No description provided for @exportNow.
  ///
  /// In en, this message translates to:
  /// **'Export Now'**
  String get exportNow;

  /// No description provided for @exporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting...'**
  String get exporting;

  /// No description provided for @excelSyncStatus.
  ///
  /// In en, this message translates to:
  /// **'Excel Export Status'**
  String get excelSyncStatus;

  /// No description provided for @lastExport.
  ///
  /// In en, this message translates to:
  /// **'Last export: {time}'**
  String lastExport(Object time);

  /// No description provided for @noExportHistory.
  ///
  /// In en, this message translates to:
  /// **'No export history available'**
  String get noExportHistory;

  /// No description provided for @excelExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Excel Export Successful'**
  String get excelExportSuccess;

  /// No description provided for @excelExportSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Data exported to Documents/FurnitureBillingData'**
  String get excelExportSuccessMessage;

  /// No description provided for @excelExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Excel Export Failed'**
  String get excelExportFailed;

  /// No description provided for @backupToCloudConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup to Cloud?'**
  String get backupToCloudConfirmTitle;

  /// No description provided for @backupToCloudConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will backup all your data to the cloud.'**
  String get backupToCloudConfirmMessage;

  /// No description provided for @exitConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit?'**
  String get exitConfirmationTitle;

  /// No description provided for @exitConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to go back?'**
  String get exitConfirmationMessage;

  /// No description provided for @exitApp.
  ///
  /// In en, this message translates to:
  /// **'Exit App?'**
  String get exitApp;

  /// No description provided for @exitAppConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit the application?'**
  String get exitAppConfirmation;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @connectedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Connected successfully ({latency}ms)'**
  String connectedSuccessfully(String latency);

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed: {message}'**
  String connectionFailed(String message);

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup Failed'**
  String get backupFailed;

  /// No description provided for @backupError.
  ///
  /// In en, this message translates to:
  /// **'Backup Error'**
  String get backupError;

  /// No description provided for @generatePdf.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF'**
  String get generatePdf;

  /// No description provided for @shareOnWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Share on WhatsApp'**
  String get shareOnWhatsapp;

  /// No description provided for @customerDetailsRequired.
  ///
  /// In en, this message translates to:
  /// **'Customer details required to generate PDF'**
  String get customerDetailsRequired;

  /// No description provided for @pleaseProvideCustomerDetails.
  ///
  /// In en, this message translates to:
  /// **'Please provide customer name, address, and phone number'**
  String get pleaseProvideCustomerDetails;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationMinLength.
  ///
  /// In en, this message translates to:
  /// **'Minimum {length} characters required'**
  String validationMinLength(int length);

  /// No description provided for @validationInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get validationInvalidPhone;

  /// No description provided for @validationInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get validationInvalidEmail;

  /// No description provided for @validationInvalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL'**
  String get validationInvalidUrl;

  /// No description provided for @validationInvalidGst.
  ///
  /// In en, this message translates to:
  /// **'Invalid GST number'**
  String get validationInvalidGst;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete?'**
  String get confirmDelete;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get noDataFound;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @paymentTerms.
  ///
  /// In en, this message translates to:
  /// **'Payment Terms'**
  String get paymentTerms;

  /// No description provided for @shippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping Address'**
  String get shippingAddress;

  /// No description provided for @sameAsBilling.
  ///
  /// In en, this message translates to:
  /// **'Same as Billing Address'**
  String get sameAsBilling;

  /// No description provided for @advancePayment.
  ///
  /// In en, this message translates to:
  /// **'Advance Payment'**
  String get advancePayment;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @deliveryDate.
  ///
  /// In en, this message translates to:
  /// **'Delivery Date'**
  String get deliveryDate;

  /// No description provided for @referenceNumber.
  ///
  /// In en, this message translates to:
  /// **'Reference Number'**
  String get referenceNumber;

  /// No description provided for @saveAsDraft.
  ///
  /// In en, this message translates to:
  /// **'Save as Draft'**
  String get saveAsDraft;

  /// No description provided for @generateInvoice.
  ///
  /// In en, this message translates to:
  /// **'Generate Invoice'**
  String get generateInvoice;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @invoiceMetadata.
  ///
  /// In en, this message translates to:
  /// **'Invoice Information'**
  String get invoiceMetadata;

  /// No description provided for @paymentDetails.
  ///
  /// In en, this message translates to:
  /// **'Payment Details'**
  String get paymentDetails;

  /// No description provided for @additionalDetails.
  ///
  /// In en, this message translates to:
  /// **'Additional Details'**
  String get additionalDetails;

  /// No description provided for @selectCustomer.
  ///
  /// In en, this message translates to:
  /// **'Select Customer'**
  String get selectCustomer;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPaymentMethod;

  /// No description provided for @enterNotes.
  ///
  /// In en, this message translates to:
  /// **'Enter notes or remarks'**
  String get enterNotes;

  /// No description provided for @enterTerms.
  ///
  /// In en, this message translates to:
  /// **'Enter terms and conditions'**
  String get enterTerms;

  /// No description provided for @enterReferenceNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter reference number'**
  String get enterReferenceNumber;

  /// No description provided for @customerRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a customer'**
  String get customerRequired;

  /// No description provided for @itemsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one item'**
  String get itemsRequired;

  /// No description provided for @invalidDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date must be after invoice date'**
  String get invalidDueDate;

  /// No description provided for @invalidAdvancePayment.
  ///
  /// In en, this message translates to:
  /// **'Advance payment cannot exceed grand total'**
  String get invalidAdvancePayment;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved successfully'**
  String get draftSaved;

  /// No description provided for @invoiceGenerated.
  ///
  /// In en, this message translates to:
  /// **'Invoice generated successfully'**
  String get invoiceGenerated;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @billingAddress.
  ///
  /// In en, this message translates to:
  /// **'Billing Address'**
  String get billingAddress;

  /// No description provided for @paymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get paymentStatus;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @unpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaid;

  /// No description provided for @partiallyPaid.
  ///
  /// In en, this message translates to:
  /// **'Partially Paid'**
  String get partiallyPaid;

  /// No description provided for @salesSummary.
  ///
  /// In en, this message translates to:
  /// **'Sales Summary'**
  String get salesSummary;

  /// No description provided for @recentInvoices.
  ///
  /// In en, this message translates to:
  /// **'Recent Invoices'**
  String get recentInvoices;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @totalBills.
  ///
  /// In en, this message translates to:
  /// **'Total Bills'**
  String get totalBills;

  /// No description provided for @unpaidBills.
  ///
  /// In en, this message translates to:
  /// **'Unpaid Bills'**
  String get unpaidBills;

  /// No description provided for @noReportsData.
  ///
  /// In en, this message translates to:
  /// **'No data available for the selected period'**
  String get noReportsData;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'CLEAR ALL'**
  String get clearAll;

  /// No description provided for @clearAllConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all items?'**
  String get clearAllConfirmation;

  /// No description provided for @tapToAddItems.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add items'**
  String get tapToAddItems;

  /// No description provided for @width.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get width;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @deleteItemConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get deleteItemConfirmation;

  /// No description provided for @billNo.
  ///
  /// In en, this message translates to:
  /// **'BILL NO'**
  String get billNo;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'DATE'**
  String get date;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'CUS'**
  String get customer;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get total;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'DUE'**
  String get due;

  /// No description provided for @billPayments.
  ///
  /// In en, this message translates to:
  /// **'Bill Payments'**
  String get billPayments;

  /// No description provided for @unpaidPartial.
  ///
  /// In en, this message translates to:
  /// **'Unpaid/Partial'**
  String get unpaidPartial;

  /// No description provided for @searchBillNumber.
  ///
  /// In en, this message translates to:
  /// **'Search bill number'**
  String get searchBillNumber;

  /// No description provided for @noInvoicesFound.
  ///
  /// In en, this message translates to:
  /// **'No invoices found'**
  String get noInvoicesFound;

  /// No description provided for @deleteBill.
  ///
  /// In en, this message translates to:
  /// **'Delete Bill'**
  String get deleteBill;

  /// No description provided for @deleteBillConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete Bill #{number}? This action cannot be undone.'**
  String deleteBillConfirmation(String number);

  /// No description provided for @billDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Bill deleted successfully'**
  String get billDeletedSuccessfully;

  /// No description provided for @failedToDeleteBill.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete bill'**
  String get failedToDeleteBill;

  /// No description provided for @reviewAndSave.
  ///
  /// In en, this message translates to:
  /// **'REVIEW & SAVE'**
  String get reviewAndSave;

  /// No description provided for @reviewAndFinalize.
  ///
  /// In en, this message translates to:
  /// **'Review & Finalize'**
  String get reviewAndFinalize;

  /// No description provided for @billGenerated.
  ///
  /// In en, this message translates to:
  /// **'Bill Generated'**
  String get billGenerated;

  /// No description provided for @billSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Bill Saved Successfully'**
  String get billSavedSuccessfully;

  /// No description provided for @confirmAndGenerate.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM & GENERATE'**
  String get confirmAndGenerate;

  /// No description provided for @invoiceGeneratedAndSaved.
  ///
  /// In en, this message translates to:
  /// **'Invoice Generated & Saved Successfully!'**
  String get invoiceGeneratedAndSaved;

  /// No description provided for @invoiceUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Invoice Updated Successfully!'**
  String get invoiceUpdatedSuccessfully;

  /// No description provided for @failedToSaveInvoice.
  ///
  /// In en, this message translates to:
  /// **'Failed to save invoice'**
  String get failedToSaveInvoice;

  /// No description provided for @maxPaymentError.
  ///
  /// In en, this message translates to:
  /// **'Max: {amount}'**
  String maxPaymentError(String amount);

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data?'**
  String get clearAllData;

  /// No description provided for @clearAllDataConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will reset all billing items and payment details. This action cannot be undone.'**
  String get clearAllDataConfirmation;

  /// No description provided for @billSummary.
  ///
  /// In en, this message translates to:
  /// **'BILL SUMMARY'**
  String get billSummary;

  /// No description provided for @advancePaid.
  ///
  /// In en, this message translates to:
  /// **'Advance Paid'**
  String get advancePaid;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get pending;

  /// No description provided for @partial.
  ///
  /// In en, this message translates to:
  /// **'PARTIAL'**
  String get partial;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'QTY'**
  String get qty;

  /// No description provided for @totLen.
  ///
  /// In en, this message translates to:
  /// **'TOT.LEN'**
  String get totLen;

  /// No description provided for @thankYouMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your business!'**
  String get thankYouMessage;

  /// No description provided for @enterWhatsappNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter WhatsApp number to send directly, or leave empty to select a chat.'**
  String get enterWhatsappNumberHint;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'NAME'**
  String get nameLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'DATE'**
  String get dateLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @descriptionShort.
  ///
  /// In en, this message translates to:
  /// **'DESCRIPTION'**
  String get descriptionShort;

  /// No description provided for @lengthShort.
  ///
  /// In en, this message translates to:
  /// **'LENGTH'**
  String get lengthShort;

  /// No description provided for @qtyShort.
  ///
  /// In en, this message translates to:
  /// **'QTY'**
  String get qtyShort;

  /// No description provided for @totalLenShort.
  ///
  /// In en, this message translates to:
  /// **'TOT.LEN'**
  String get totalLenShort;

  /// No description provided for @rateShort.
  ///
  /// In en, this message translates to:
  /// **'RATE'**
  String get rateShort;

  /// No description provided for @totalShort.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get totalShort;

  /// No description provided for @balanceDueUpper.
  ///
  /// In en, this message translates to:
  /// **'BALANCE DUE'**
  String get balanceDueUpper;

  /// No description provided for @defaultBusinessName.
  ///
  /// In en, this message translates to:
  /// **'BUSINESS NAME'**
  String get defaultBusinessName;

  /// No description provided for @whatsappNumberHintExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., 9876543210'**
  String get whatsappNumberHintExample;

  /// No description provided for @billNumberPrefix.
  ///
  /// In en, this message translates to:
  /// **'BILL #'**
  String get billNumberPrefix;

  /// No description provided for @totalAmountCaps.
  ///
  /// In en, this message translates to:
  /// **'TOTAL AMOUNT'**
  String get totalAmountCaps;

  /// No description provided for @initialPaymentNote.
  ///
  /// In en, this message translates to:
  /// **'Initial payment for bill {number}'**
  String initialPaymentNote(String number);

  /// No description provided for @failedToSaveInvoiceWithDetail.
  ///
  /// In en, this message translates to:
  /// **'Failed to save invoice: {error}'**
  String failedToSaveInvoiceWithDetail(String error);

  /// No description provided for @internetConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Internet connection failed. Please check your data or Wi-Fi connection and try again.'**
  String get internetConnectionFailed;

  /// No description provided for @connectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'The connection timed out. Please try again when you have a better network.'**
  String get connectionTimeout;

  /// No description provided for @cloudConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the cloud server. Please try again in a few minutes.'**
  String get cloudConnectionError;

  /// No description provided for @paymentHistoryNote.
  ///
  /// In en, this message translates to:
  /// **'Payment for Invoice #{number}'**
  String paymentHistoryNote(Object number);

  /// No description provided for @supabaseCredentialsMissing.
  ///
  /// In en, this message translates to:
  /// **'Supabase credentials not found'**
  String get supabaseCredentialsMissing;

  /// No description provided for @configureSupabaseMessage.
  ///
  /// In en, this message translates to:
  /// **'Please configure your Supabase credentials in the app settings.'**
  String get configureSupabaseMessage;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @initializingBackup.
  ///
  /// In en, this message translates to:
  /// **'Initializing backup...'**
  String get initializingBackup;

  /// No description provided for @backingUpBills.
  ///
  /// In en, this message translates to:
  /// **'Backing up bills...'**
  String get backingUpBills;

  /// No description provided for @backingUpPayments.
  ///
  /// In en, this message translates to:
  /// **'Backing up payments...'**
  String get backingUpPayments;

  /// No description provided for @fetchingBills.
  ///
  /// In en, this message translates to:
  /// **'Fetching bills from cloud...'**
  String get fetchingBills;

  /// No description provided for @fetchingPayments.
  ///
  /// In en, this message translates to:
  /// **'Fetching payments from cloud...'**
  String get fetchingPayments;

  /// No description provided for @checkingDeleted.
  ///
  /// In en, this message translates to:
  /// **'Checking for deleted records...'**
  String get checkingDeleted;

  /// No description provided for @removingDeleted.
  ///
  /// In en, this message translates to:
  /// **'Removing deleted records locally...'**
  String get removingDeleted;

  /// No description provided for @restoringBill.
  ///
  /// In en, this message translates to:
  /// **'Restoring bill {current}/{total}...'**
  String restoringBill(int current, int total);

  /// No description provided for @restoringPayment.
  ///
  /// In en, this message translates to:
  /// **'Restoring payment {current}/{total}...'**
  String restoringPayment(int current, int total);

  /// No description provided for @restorationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Restoration completed!'**
  String get restorationCompleted;

  /// No description provided for @backupCompleted.
  ///
  /// In en, this message translates to:
  /// **'Backup completed!'**
  String get backupCompleted;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @supabaseNotInitialized.
  ///
  /// In en, this message translates to:
  /// **'Supabase not initialized'**
  String get supabaseNotInitialized;

  /// No description provided for @checkingConnectionProgress.
  ///
  /// In en, this message translates to:
  /// **'Checking connection...'**
  String get checkingConnectionProgress;

  /// No description provided for @backingUpBill.
  ///
  /// In en, this message translates to:
  /// **'Backing up bill {current}/{total}...'**
  String backingUpBill(int current, int total);

  /// No description provided for @backingUpPayment.
  ///
  /// In en, this message translates to:
  /// **'Backing up payment {current}/{total}...'**
  String backingUpPayment(int current, int total);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
