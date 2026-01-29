// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Furniture Billing';

  @override
  String get appSubtitle => 'Production-Ready Billing Software';

  @override
  String get home => 'Home';

  @override
  String get customers => 'Customers';

  @override
  String get addCustomer => 'Add Customer';

  @override
  String get editCustomer => 'Edit Customer';

  @override
  String get customerName => 'Customer Name';

  @override
  String get enterCustomerName => 'Enter customer name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get email => 'Email';

  @override
  String get address => 'Address';

  @override
  String get balance => 'Balance';

  @override
  String get searchCustomers => 'Search customers by name or phone';

  @override
  String get noCustomersFound => 'No customers found';

  @override
  String get addFirstCustomer => 'Add your first customer to get started';

  @override
  String get retry => 'Retry';

  @override
  String get products => 'Products';

  @override
  String get billing => 'Billing';

  @override
  String get invoices => 'Invoices';

  @override
  String get payments => 'Payments';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get businessProfile => 'Business Profile';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get export => 'Export';

  @override
  String get print => 'Print';

  @override
  String get share => 'Share';

  @override
  String get customerPhone => 'Phone Number';

  @override
  String get customerAddress => 'Address';

  @override
  String get customerBalance => 'Balance';

  @override
  String get customerDetails => 'Customer Details';

  @override
  String get customerList => 'Customer List';

  @override
  String get itemName => 'Item Name';

  @override
  String get productName => 'Product Name';

  @override
  String get productPrice => 'Price';

  @override
  String get productSize => 'Size';

  @override
  String get addProduct => 'Add Product';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get updateProduct => 'Update Product';

  @override
  String get deleteProduct => 'Delete Product';

  @override
  String get productList => 'Product List';

  @override
  String get searchProducts => 'Search products by name';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get addYourFirstProduct => 'Add your first product to get started';

  @override
  String get size => 'Size';

  @override
  String get description => 'Description';

  @override
  String get descriptions => 'Descriptions';

  @override
  String get manageDescriptions => 'Manage Descriptions';

  @override
  String get addDescription => 'Add Description';

  @override
  String get editDescription => 'Edit Description';

  @override
  String get deleteDescription => 'Delete Description';

  @override
  String get noDescriptionsYet => 'No descriptions added yet';

  @override
  String get enterDescriptionText => 'Enter description text';

  @override
  String deleteDescriptionConfirmation(String text) {
    return 'Are you sure you want to delete \"$text\"?';
  }

  @override
  String get category => 'Category';

  @override
  String get enterProductName => 'Enter product name';

  @override
  String get enterDescription => 'Enter description';

  @override
  String get enterMRP => 'Enter MRP';

  @override
  String get enterSize => 'Enter size (e.g., 3×5, 4×6)';

  @override
  String get enterCategory => 'Enter category';

  @override
  String get productNameRequired => 'Product name is required';

  @override
  String get rateRequired => 'Rate is required';

  @override
  String get invalidMRP => 'Invalid MRP. Must be greater than 0';

  @override
  String get productAddedSuccessfully => 'Product added successfully';

  @override
  String get productUpdatedSuccessfully => 'Product updated successfully';

  @override
  String get productDeletedSuccessfully => 'Product deleted successfully';

  @override
  String get errorSavingProduct => 'Error saving product';

  @override
  String get errorDeletingProduct => 'Error deleting product';

  @override
  String get deleteProductConfirmation =>
      'Are you sure you want to delete this product?';

  @override
  String get invoiceNumber => 'Invoice Number';

  @override
  String get invoiceDate => 'Invoice Date';

  @override
  String get invoiceTotal => 'Total Amount';

  @override
  String get invoiceStatus => 'Status';

  @override
  String get createInvoice => 'Create Invoice';

  @override
  String get invoiceDetails => 'Invoice Details';

  @override
  String get serialNumber => 'S.No';

  @override
  String get quantity => 'Quantity';

  @override
  String get length => 'LEN';

  @override
  String get totalLength => 'Total Length';

  @override
  String get rate => 'RATE';

  @override
  String get amount => 'Amount';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get discount => 'Discount';

  @override
  String get grandTotal => 'Grand Total';

  @override
  String get paidAmount => 'Paid Amount';

  @override
  String get balanceAmount => 'Balance Amount';

  @override
  String get remainingBalance => 'REMAINING BALANCE';

  @override
  String get editBillAndPayment => 'Edit Bill & Payment';

  @override
  String get paymentHistory => 'Payment History';

  @override
  String get noPreviousPayments => 'No previous payments';

  @override
  String get enterPaymentAmount => 'Enter Payment Amount';

  @override
  String get updatePayment => 'Update Payment';

  @override
  String get paymentUpdatedSuccessfully =>
      'Payment updated and saved successfully!';

  @override
  String get shareInvoice => 'Share Invoice';

  @override
  String get whatsappNumberOptional => 'WhatsApp Number (Optional)';

  @override
  String get send => 'Send';

  @override
  String get businessProfileMissing => 'Business Profile Missing';

  @override
  String get businessProfileSetupMessage =>
      'Please set up your business profile (Name, Address, Logo) in Settings before generating invoices.';

  @override
  String get businessNameTamil => 'Business Name (Tamil)';

  @override
  String get businessAddressTamil => 'Address (Tamil)';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get languageSelection => 'Language Selection';

  @override
  String pdfGeneratedAt(Object path) {
    return 'PDF Generated at $path';
  }

  @override
  String get invoicePreview => 'Invoice Preview';

  @override
  String get shareViaWhatsApp => 'Share via WhatsApp';

  @override
  String get backToDashboard => 'BACK TO DASHBOARD';

  @override
  String get newBill => 'NEW BILL';

  @override
  String get generateBill => 'Generate Bill';

  @override
  String get allDataCleared => 'All data cleared';

  @override
  String get pleaseAddItems => 'Please add at least one item to the bill';

  @override
  String get addItem => 'ADD ITEM';

  @override
  String get next => 'NEXT';

  @override
  String get balanceDue => 'Balance Due';

  @override
  String get desc => 'Desc';

  @override
  String get noItemsAdded => 'No items added';

  @override
  String get clearAllDataQuestion => 'Clear All Data?';

  @override
  String get clearAllDataWarning =>
      'This will reset all billing items and payment details. This action cannot be undone.';

  @override
  String get clearAllAction => 'Clear All';

  @override
  String get paymentMode => 'Payment Mode';

  @override
  String get paymentDate => 'Payment Date';

  @override
  String get paymentAmount => 'Payment Amount';

  @override
  String get recordPayment => 'Record Payment';

  @override
  String get partialPayment => 'Partial Payment';

  @override
  String get fullPayment => 'Full Payment';

  @override
  String get pendingDues => 'Pending Dues';

  @override
  String get cash => 'Cash';

  @override
  String get card => 'Card';

  @override
  String get upi => 'UPI';

  @override
  String get bankTransfer => 'Bank Transfer';

  @override
  String get cheque => 'Cheque';

  @override
  String get dailyReport => 'Daily Report';

  @override
  String get weeklyReport => 'Weekly Report';

  @override
  String get monthlyReport => 'Monthly Report';

  @override
  String get customReport => 'Custom Report';

  @override
  String get totalSales => 'Total Sales';

  @override
  String get totalPaid => 'Total Paid';

  @override
  String get totalPending => 'Total Pending';

  @override
  String get customerWiseDue => 'Customer-wise Due';

  @override
  String get productWiseSales => 'Product-wise Sales';

  @override
  String get dateRange => 'Date Range';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get businessName => 'Business Name';

  @override
  String get businessLogo => 'Business Logo';

  @override
  String get whatsappNumber => 'WhatsApp Number';

  @override
  String get primaryPhone => 'Primary Phone';

  @override
  String get additionalPhone => 'Additional Phone';

  @override
  String get instagramId => 'Instagram ID';

  @override
  String get websiteUrl => 'Website URL';

  @override
  String get gstNumber => 'GST Number';

  @override
  String get businessAddress => 'Business Address';

  @override
  String get uploadLogo => 'Upload Logo';

  @override
  String get optional => 'Optional';

  @override
  String get required => 'Required';

  @override
  String get theme => 'Theme';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get tamil => 'Tamil';

  @override
  String get backup => 'Backup';

  @override
  String get restore => 'Restore';

  @override
  String get cloudBackup => 'Cloud Backup';

  @override
  String get driveBackup => 'Drive Backup';

  @override
  String lastBackup(String time) {
    return 'Last backup: $time';
  }

  @override
  String get backupNow => 'Backup Now';

  @override
  String get restoreFromBackup => 'Restore from Backup';

  @override
  String get general => 'General';

  @override
  String get darkModeEnabled => 'Dark Mode Enabled';

  @override
  String get lightModeEnabled => 'Light Mode Enabled';

  @override
  String get business => 'Business';

  @override
  String get manageBusinessDetails => 'Manage your business details';

  @override
  String get data => 'Data';

  @override
  String get backupYourData => 'Backup your data';

  @override
  String get backupFeatureComingSoon => 'Backup feature coming soon';

  @override
  String get restoreFeatureComingSoon => 'Restore feature coming soon';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get appVersion => '1.0.0';

  @override
  String get backupSettings => 'Backup & Restore';

  @override
  String get connectionStatus => 'Cloud Connection';

  @override
  String get connectedToSupabase => 'Connected to Cloud';

  @override
  String get notConnected => 'Not connected';

  @override
  String get supabaseNotConfigured => 'Cloud Backup Not Configured';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get manualBackup => 'Manual Cloud Backup';

  @override
  String get manualBackupDescription =>
      'Backup your bills and payment data to the secure cloud manually.';

  @override
  String get automaticBackup => 'Automatic Cloud Backup';

  @override
  String get automaticBackupDescription =>
      'Your data is automatically backed up to the cloud daily at 12:00 AM.';

  @override
  String get enableAutomaticBackup => 'Enable Automatic Backup';

  @override
  String get backupTime => 'Backup Time';

  @override
  String get dailyBackupTime => 'Daily Backup Time';

  @override
  String lastImport(Object time) {
    return 'Last restore: $time';
  }

  @override
  String get automaticImport => 'Automatic Restore';

  @override
  String get automaticImportDescription =>
      'Your data is automatically restored from the cloud daily at 1:00 AM.';

  @override
  String get enableAutomaticImport => 'Enable Automatic Restore';

  @override
  String get dailyImportTime => 'Daily Restore Time';

  @override
  String get aboutImport => 'About Restore';

  @override
  String get aboutImportDescription =>
      'Data is automatically restored from the cloud to ensure all devices are in sync.';

  @override
  String get aboutBackups => 'About Backups';

  @override
  String get aboutBackupsDescription =>
      'Your data is securely backed up to cloud storage. Both new and updated bills are automatically synced.';

  @override
  String get startingBackup => 'Starting backup...';

  @override
  String get backupSuccessful => 'Backup Successful';

  @override
  String get dataBackedUpSuccessfully =>
      'Your data has been backed up successfully!';

  @override
  String get billsSynced => 'Bills synced:';

  @override
  String get billsFailed => 'Bills failed:';

  @override
  String get paymentsSynced => 'Payments synced:';

  @override
  String get paymentsFailed => 'Payments failed:';

  @override
  String get ok => 'OK';

  @override
  String get importFromSupabase => 'Restore from Cloud';

  @override
  String get importFromSupabaseDescription =>
      'Fetch all bills and payments from the cloud and save them locally.';

  @override
  String get importNow => 'Restore Now';

  @override
  String get importFromCloudConfirmTitle => 'Restore from Cloud?';

  @override
  String get importFromCloudConfirmMessage =>
      'This will fetch all data from the cloud and merge it with your local data.';

  @override
  String get importSuccessful => 'Restore Successful';

  @override
  String get dataImportedSuccessfully =>
      'Data successfully restored from cloud.';

  @override
  String get billsRestored => 'Bills Restored';

  @override
  String get paymentsRestored => 'Payments Restored';

  @override
  String get importFailed => 'Restore Failed';

  @override
  String get importError => 'Restore Error';

  @override
  String get excelSyncSettings => 'Excel Report Settings';

  @override
  String get enableExcelSync => 'Enable Weekly Excel Report';

  @override
  String get excelSyncDescription =>
      'Automatically export data to an Excel file in your Documents folder.';

  @override
  String get syncFrequency => 'Export Frequency';

  @override
  String everyDays(Object days) {
    return 'Every $days days';
  }

  @override
  String get manualExcelSync => 'Manual Excel Export';

  @override
  String get manualExcelSyncDescription =>
      'Export your data to an Excel file immediately.';

  @override
  String get exportNow => 'Export Now';

  @override
  String get exporting => 'Exporting...';

  @override
  String get excelSyncStatus => 'Excel Export Status';

  @override
  String lastExport(Object time) {
    return 'Last export: $time';
  }

  @override
  String get noExportHistory => 'No export history available';

  @override
  String get excelExportSuccess => 'Excel Export Successful';

  @override
  String get excelExportSuccessMessage =>
      'Data exported to Documents/FurnitureBillingData';

  @override
  String get excelExportFailed => 'Excel Export Failed';

  @override
  String get excelExportConfirmTitle => 'Export to Excel?';

  @override
  String get excelExportConfirmMessage =>
      'This will generate an Excel report of all your data in the Documents folder.';

  @override
  String get backupToCloudConfirmTitle => 'Backup to Cloud?';

  @override
  String get backupToCloudConfirmMessage =>
      'This will backup all your data to the cloud.';

  @override
  String get exitConfirmationTitle => 'Exit?';

  @override
  String get exitConfirmationMessage => 'Are you sure you want to go back?';

  @override
  String get exitApp => 'Exit App?';

  @override
  String get exitAppConfirmation =>
      'Are you sure you want to exit the application?';

  @override
  String get exit => 'Exit';

  @override
  String connectedSuccessfully(String latency) {
    return 'Connected successfully (${latency}ms)';
  }

  @override
  String connectionFailed(String message) {
    return 'Connection failed: $message';
  }

  @override
  String get backupFailed => 'Backup Failed';

  @override
  String get backupError => 'Backup Error';

  @override
  String get generatePdf => 'Generate PDF';

  @override
  String get shareOnWhatsapp => 'Share on WhatsApp';

  @override
  String get customerDetailsRequired =>
      'Customer details required to generate PDF';

  @override
  String get pleaseProvideCustomerDetails =>
      'Please provide customer name, address, and phone number';

  @override
  String get validationRequired => 'This field is required';

  @override
  String validationMinLength(int length) {
    return 'Minimum $length characters required';
  }

  @override
  String get validationInvalidPhone => 'Invalid phone number';

  @override
  String get validationInvalidEmail => 'Invalid email address';

  @override
  String get validationInvalidUrl => 'Invalid URL';

  @override
  String get validationInvalidGst => 'Invalid GST number';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Info';

  @override
  String get confirmDelete => 'Are you sure you want to delete?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get noDataFound => 'No data found';

  @override
  String get loading => 'Loading...';

  @override
  String get close => 'Close';

  @override
  String get dueDate => 'Due Date';

  @override
  String get paymentTerms => 'Payment Terms';

  @override
  String get shippingAddress => 'Shipping Address';

  @override
  String get sameAsBilling => 'Same as Billing Address';

  @override
  String get advancePayment => 'Advance Payment';

  @override
  String get notes => 'Notes';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get deliveryDate => 'Delivery Date';

  @override
  String get referenceNumber => 'Reference Number';

  @override
  String get saveAsDraft => 'Save as Draft';

  @override
  String get generateInvoice => 'Generate Invoice';

  @override
  String get preview => 'Preview';

  @override
  String get invoiceMetadata => 'Invoice Information';

  @override
  String get paymentDetails => 'Payment Details';

  @override
  String get additionalDetails => 'Additional Details';

  @override
  String get selectCustomer => 'Select Customer';

  @override
  String get selectPaymentMethod => 'Select Payment Method';

  @override
  String get enterNotes => 'Enter notes or remarks';

  @override
  String get enterTerms => 'Enter terms and conditions';

  @override
  String get enterReferenceNumber => 'Enter reference number';

  @override
  String get customerRequired => 'Please select a customer';

  @override
  String get itemsRequired => 'Please add at least one item';

  @override
  String get invalidDueDate => 'Due date must be after invoice date';

  @override
  String get invalidAdvancePayment =>
      'Advance payment cannot exceed grand total';

  @override
  String get draftSaved => 'Draft saved successfully';

  @override
  String get invoiceGenerated => 'Invoice generated successfully';

  @override
  String get selectDate => 'Select Date';

  @override
  String get billingAddress => 'Billing Address';

  @override
  String get paymentStatus => 'Payment Status';

  @override
  String get paid => 'Paid';

  @override
  String get unpaid => 'Unpaid';

  @override
  String get partiallyPaid => 'Partially Paid';

  @override
  String get salesSummary => 'Sales Summary';

  @override
  String get recentInvoices => 'Recent Invoices';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get custom => 'Custom';

  @override
  String get totalBills => 'Total Bills';

  @override
  String get unpaidBills => 'Unpaid Bills';

  @override
  String get noReportsData => 'No data available for the selected period';

  @override
  String get clearAll => 'CLEAR ALL';

  @override
  String get clearAllConfirmation =>
      'Are you sure you want to clear all items?';

  @override
  String get tapToAddItems => 'Tap + to add items';

  @override
  String get width => 'Width';

  @override
  String get height => 'Height';

  @override
  String get deleteItemConfirmation =>
      'Are you sure you want to delete this item?';

  @override
  String get billNo => 'BILL NO';

  @override
  String get date => 'DATE';

  @override
  String get customer => 'CUS';

  @override
  String get total => 'TOTAL';

  @override
  String get due => 'DUE';

  @override
  String get billPayments => 'Bill Payments';

  @override
  String get unpaidPartial => 'Unpaid/Partial';

  @override
  String get searchBillNumber => 'Search bill number';

  @override
  String get noInvoicesFound => 'No invoices found';

  @override
  String get deleteBill => 'Delete Bill';

  @override
  String deleteBillConfirmation(String number) {
    return 'Are you sure you want to delete Bill #$number? This action cannot be undone.';
  }

  @override
  String get billDeletedSuccessfully => 'Bill deleted successfully';

  @override
  String get failedToDeleteBill => 'Failed to delete bill';

  @override
  String get reviewAndSave => 'REVIEW & SAVE';

  @override
  String get reviewAndFinalize => 'Review & Finalize';

  @override
  String get billGenerated => 'Bill Generated';

  @override
  String get billSavedSuccessfully => 'Bill Saved Successfully';

  @override
  String get confirmAndGenerate => 'CONFIRM & GENERATE';

  @override
  String get invoiceGeneratedAndSaved =>
      'Invoice Generated & Saved Successfully!';

  @override
  String get invoiceUpdatedSuccessfully => 'Invoice Updated Successfully!';

  @override
  String get failedToSaveInvoice => 'Failed to save invoice';

  @override
  String maxPaymentError(String amount) {
    return 'Max: $amount';
  }

  @override
  String get clearAllData => 'Clear All Data?';

  @override
  String get clearAllDataConfirmation =>
      'This will reset all billing items and payment details. This action cannot be undone.';

  @override
  String get billSummary => 'BILL SUMMARY';

  @override
  String get advancePaid => 'Advance Paid';

  @override
  String get pending => 'PENDING';

  @override
  String get partial => 'PARTIAL';

  @override
  String get qty => 'QTY';

  @override
  String get totLen => 'TOT.LEN';

  @override
  String get thankYouMessage => 'Thank you for your business!';

  @override
  String get enterWhatsappNumberHint =>
      'Enter WhatsApp number to send directly, or leave empty to select a chat.';

  @override
  String get nameLabel => 'NAME';

  @override
  String get dateLabel => 'DATE';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get descriptionShort => 'DESCRIPTION';

  @override
  String get lengthShort => 'LENGTH';

  @override
  String get qtyShort => 'QTY';

  @override
  String get totalLenShort => 'TOT.LEN';

  @override
  String get rateShort => 'RATE';

  @override
  String get totalShort => 'TOTAL';

  @override
  String get balanceDueUpper => 'BALANCE DUE';

  @override
  String get defaultBusinessName => 'BUSINESS NAME';

  @override
  String get whatsappNumberHintExample => 'e.g., 9876543210';

  @override
  String get billNumberPrefix => 'BILL #';

  @override
  String get totalAmountCaps => 'TOTAL AMOUNT';

  @override
  String initialPaymentNote(String number) {
    return 'Initial payment for bill $number';
  }

  @override
  String failedToSaveInvoiceWithDetail(String error) {
    return 'Failed to save invoice: $error';
  }

  @override
  String get internetConnectionFailed =>
      'Internet connection failed. Please check your data or Wi-Fi connection and try again.';

  @override
  String get connectionTimeout =>
      'The connection timed out. Please try again when you have a better network.';

  @override
  String get cloudConnectionError =>
      'Could not connect to the cloud server. Please try again in a few minutes.';

  @override
  String paymentHistoryNote(Object number) {
    return 'Payment for Invoice #$number';
  }

  @override
  String get supabaseCredentialsMissing => 'Supabase credentials not found';

  @override
  String get configureSupabaseMessage =>
      'Please configure your Supabase credentials in the app settings.';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get initializingBackup => 'Initializing backup...';

  @override
  String get backingUpBills => 'Backing up bills...';

  @override
  String get backingUpPayments => 'Backing up payments...';

  @override
  String get fetchingBills => 'Fetching bills from cloud...';

  @override
  String get fetchingPayments => 'Fetching payments from cloud...';

  @override
  String get checkingDeleted => 'Checking for deleted records...';

  @override
  String get removingDeleted => 'Removing deleted records locally...';

  @override
  String restoringBill(int current, int total) {
    return 'Restoring bill $current/$total...';
  }

  @override
  String restoringPayment(int current, int total) {
    return 'Restoring payment $current/$total...';
  }

  @override
  String get restorationCompleted => 'Restoration completed!';

  @override
  String get backupCompleted => 'Backup completed!';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get supabaseNotInitialized => 'Supabase not initialized';

  @override
  String get checkingConnectionProgress => 'Checking connection...';

  @override
  String backingUpBill(int current, int total) {
    return 'Backing up bill $current/$total...';
  }

  @override
  String backingUpPayment(int current, int total) {
    return 'Backing up payment $current/$total...';
  }
}
