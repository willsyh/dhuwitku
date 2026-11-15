// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get typeExpense => 'Expense';

  @override
  String get typeIncome => 'Income';

  @override
  String get catFood => 'Food';

  @override
  String get catCoffee => 'Coffee';

  @override
  String get catFuel => 'Fuel';

  @override
  String get catParking => 'Parking';

  @override
  String get catTransport => 'Transport';

  @override
  String get catGroceries => 'Groceries';

  @override
  String get catShopping => 'Shopping';

  @override
  String get catEntertainment => 'Entertainment';

  @override
  String get catBills => 'Bills';

  @override
  String get catHealth => 'Health';

  @override
  String get catOther => 'Other';

  @override
  String get catSalary => 'Salary';

  @override
  String get catAllowance => 'Allowance';

  @override
  String get catFreelance => 'Freelance';

  @override
  String get catBusiness => 'Business';

  @override
  String get catInvestment => 'Investment';

  @override
  String get payCash => 'Cash';

  @override
  String get payCreditCard => 'Credit card';

  @override
  String get payTransfer => 'Bank transfer';

  @override
  String get payDebit => 'Debit';

  @override
  String get payEwallet => 'E-wallet';

  @override
  String get errAmountZero => 'Enter an amount greater than 0';

  @override
  String get errAmountTooLarge => 'Amount is too large';

  @override
  String get errPickCategory => 'Pick a category first';

  @override
  String errNoteTooLong(int max) {
    return 'Note can be at most $max characters';
  }

  @override
  String get errInvalidDate => 'Invalid date';

  @override
  String get periodDaily => 'Daily';

  @override
  String get periodWeekly => 'Weekly';

  @override
  String get periodMonthly => 'Monthly';

  @override
  String get periodYearly => 'Yearly';

  @override
  String get appTagline => 'Track your money in seconds.';

  @override
  String get festiveNone => 'None';

  @override
  String get festiveIdulFitri => 'Eid al-Fitr';

  @override
  String get festiveIdulFitriGreeting => 'Happy Eid al-Fitr';

  @override
  String get festiveIdulFitriSubtitle => 'Please forgive us, body and soul';

  @override
  String get festiveIdulAdha => 'Eid al-Adha';

  @override
  String get festiveIdulAdhaGreeting => 'Happy Eid al-Adha';

  @override
  String get festiveIdulAdhaSubtitle => 'May it be blessed and meaningful';

  @override
  String get festiveImlek => 'Lunar New Year';

  @override
  String get festiveImlekGreeting => 'Gong Xi Fa Cai';

  @override
  String get festiveImlekSubtitle => 'Happy Lunar New Year';

  @override
  String get festivePaskah => 'Easter';

  @override
  String get festivePaskahGreeting => 'Happy Easter';

  @override
  String get festivePaskahSubtitle => 'Peace and joy to you';

  @override
  String get festiveNatal => 'Christmas';

  @override
  String get festiveNatalGreeting => 'Merry Christmas';

  @override
  String get festiveNatalSubtitle => 'Peace and joy to you';

  @override
  String get festiveTahunBaru => 'New Year';

  @override
  String get festiveTahunBaruGreeting => 'Happy New Year';

  @override
  String get festiveTahunBaruSubtitle =>
      'A fresh start, fresh financial records';

  @override
  String get festiveValentine => 'Valentine\'s Day';

  @override
  String get festiveValentineGreeting => 'Happy Valentine\'s Day';

  @override
  String get festiveValentineSubtitle => 'A day full of love';

  @override
  String get festiveRamadan => 'Ramadan';

  @override
  String get festiveRamadanGreeting => 'Ramadan Mubarak';

  @override
  String get festiveRamadanSubtitle => 'Have a blessed fast';

  @override
  String get festiveNyepi => 'Nyepi';

  @override
  String get festiveNyepiGreeting => 'Happy Nyepi';

  @override
  String get festiveNyepiSubtitle => 'Peace in silence';

  @override
  String get festiveWaisak => 'Vesak';

  @override
  String get festiveWaisakGreeting => 'Happy Vesak';

  @override
  String get festiveWaisakSubtitle => 'May all beings be happy';

  @override
  String get festiveKartini => 'Kartini Day';

  @override
  String get festiveKartiniGreeting => 'Happy Kartini Day';

  @override
  String get festiveKartiniSubtitle => 'After darkness comes light';

  @override
  String get festiveKemerdekaan => 'Indonesian Independence';

  @override
  String get festiveKemerdekaanGreeting => 'Happy Independence Day, Indonesia';

  @override
  String get festiveKemerdekaanSubtitle => 'Merdeka! August 17';

  @override
  String get festiveHalloween => 'Halloween';

  @override
  String get festiveHalloweenGreeting => 'Happy Halloween';

  @override
  String get festiveHalloweenSubtitle => 'Watch out for scary spending!';

  @override
  String get festiveHariIbu => 'Mother\'s Day';

  @override
  String get festiveHariIbuGreeting => 'Happy Mother\'s Day';

  @override
  String get festiveHariIbuSubtitle => 'Thank you, Mom';

  @override
  String get currencyIdr => 'Indonesian Rupiah';

  @override
  String get currencyUsd => 'US Dollar';

  @override
  String get currencySgd => 'Singapore Dollar';

  @override
  String get currencyMyr => 'Malaysian Ringgit';

  @override
  String get currencyEur => 'Euro';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get retry => 'Try again';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get errDatabase => 'Couldn\'t save to the database. Try again.';

  @override
  String get navHome => 'Home';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navStatistics => 'Statistics';

  @override
  String get navSettings => 'Settings';

  @override
  String get addTransactionTooltip => 'Add transaction';

  @override
  String demoRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count demo transactions removed.',
      one: '1 demo transaction removed.',
    );
    return '$_temp0';
  }

  @override
  String get dashBudgetAlerts => 'Budget Alerts';

  @override
  String get manage => 'Manage';

  @override
  String get dashMonthlySummary => 'Monthly Summary';

  @override
  String get dashRecent => 'Recent Transactions';

  @override
  String get seeAll => 'See all';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get dashEmptyMessage =>
      'Record your first expense — it only takes a few seconds.';

  @override
  String get recordNow => 'Record Now';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get greetingNight => 'Good night';

  @override
  String get scanReceipt => 'Scan receipt';

  @override
  String get assistantBarTitle => 'Ask or record via chat';

  @override
  String get assistantBarHint =>
      'e.g. \"coffee 25k\" · \"spending this month?\"';

  @override
  String get demoActive => 'Demo mode is on: some data is sample data.';

  @override
  String get delete => 'Delete';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get incomeThisMonth => 'Income this month';

  @override
  String get expenseThisMonth => 'Expenses this month';

  @override
  String get setMonthlyBudget => 'Set a monthly budget';

  @override
  String budgetRemaining(String amount) {
    return '$amount left in budget';
  }

  @override
  String budgetExceededBy(String amount) {
    return 'Budget exceeded by $amount';
  }

  @override
  String get history => 'History';

  @override
  String get avgPerDay => 'Average / day';

  @override
  String get topCategory => 'Top category';

  @override
  String get transactionsThisMonth => 'Transactions this month';

  @override
  String get last6Months => 'Last 6 months';

  @override
  String get legendIn => 'In';

  @override
  String get legendOut => 'Out';

  @override
  String get chartEmpty => 'The chart appears once you have transactions.';

  @override
  String get transactionDate => 'Transaction date';

  @override
  String get categoryFallback => 'category';

  @override
  String txSaved(String type, String amount) {
    return '$type $amount saved.';
  }

  @override
  String txUpdated(String type, String amount) {
    return '$type $amount updated.';
  }

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get amount => 'Amount';

  @override
  String get note => 'Note';

  @override
  String get noteHint => 'e.g. Fried rice, iced latte…';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get save => 'Save';

  @override
  String get transactionType => 'Transaction type';

  @override
  String get newCategoryShort => 'New';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get clearPaymentMethod => 'Clear method';

  @override
  String get method => 'Method';

  @override
  String get tripleZero => 'Three zeros';

  @override
  String get backspaceHint => 'Delete digit. Hold to clear all';

  @override
  String get deleteTransactionQ => 'Delete transaction?';

  @override
  String get deleteCannotUndo => 'Deleted transactions can\'t be recovered.';

  @override
  String get cancel => 'Cancel';

  @override
  String get transactionDeleted => 'Transaction deleted.';

  @override
  String get demoData => 'Demo data';

  @override
  String get type => 'Type';

  @override
  String get category => 'Category';

  @override
  String get date => 'Date';

  @override
  String get recordedAt => 'Recorded';

  @override
  String get updatedAt => 'Updated';

  @override
  String get edit => 'Edit';

  @override
  String get sortNewest => 'Newest first';

  @override
  String get sortOldest => 'Oldest first';

  @override
  String get searchHint => 'Search notes or categories';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get noMatchingTransactions => 'No matching transactions';

  @override
  String get noMatchingHint => 'Try a different keyword or filter.';

  @override
  String get resetFilter => 'Reset filters';

  @override
  String get historyEmptyMessage =>
      'Tap the + button to record your first transaction.';

  @override
  String get recordTransaction => 'Add Transaction';

  @override
  String get all => 'All';

  @override
  String get pickDateRange => 'Pick a date range';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get allCategories => 'All categories';

  @override
  String transactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return '$_temp0';
  }

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get noCategories => 'No categories yet';

  @override
  String get defaultCategory => 'Default';

  @override
  String get deleteCategory => 'Delete category';

  @override
  String get errLastCategory =>
      'There must be at least one category of this type.';

  @override
  String deleteCategoryQ(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get deleteCategoryUnused =>
      'This category isn\'t used by any transaction. Budgets for it will also be deleted.';

  @override
  String deleteCategoryUsed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions use this category. Move them to:',
      one: '1 transaction uses this category. Move it to:',
    );
    return '$_temp0';
  }

  @override
  String categoryDeleted(String name) {
    return 'Category \"$name\" deleted.';
  }

  @override
  String get categoryAdded => 'Category added.';

  @override
  String get categoryUpdated => 'Category updated.';

  @override
  String get newCategory => 'New Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get categoryName => 'Category name';

  @override
  String get color => 'Color';

  @override
  String get icon => 'Icon';

  @override
  String get saveCategory => 'Save Category';

  @override
  String get budgets => 'Budgets';

  @override
  String get budgetCarryHint =>
      'A budget applies from the selected month and carries over to the following months until you change it.';

  @override
  String get monthlyBudget => 'Monthly Budget';

  @override
  String get setTotalBudget => 'Set a total budget for this month';

  @override
  String get categoryLimits => 'Category Limits';

  @override
  String get add => 'Add';

  @override
  String get noCategoryLimits => 'No category limits yet';

  @override
  String get categoryLimitExample => 'e.g. limit Coffee to Rp 300,000 a month.';

  @override
  String get addLimit => 'Add limit';

  @override
  String get pickCategory => 'Pick a category';

  @override
  String budgetSaved(String label) {
    return '$label budget saved.';
  }

  @override
  String get deleteBudgetQ => 'Delete budget?';

  @override
  String deleteBudgetBody(String label, String month) {
    return '$label no longer applies from $month. Budgets for earlier months are kept.';
  }

  @override
  String budgetDeleted(String label) {
    return '$label budget deleted.';
  }

  @override
  String startingFrom(String month) {
    return 'Starting $month';
  }

  @override
  String get levelSafe => 'On track';

  @override
  String get levelCaution => 'Caution';

  @override
  String get levelDanger => 'Almost used up';

  @override
  String get levelExceeded => 'Exceeded';

  @override
  String usedPercentA11y(int percent) {
    return '$percent percent used';
  }

  @override
  String budgetAmount(String amount) {
    return 'Budget $amount';
  }

  @override
  String get deleteBudget => 'Delete budget';

  @override
  String spentAmount(String amount) {
    return 'Spent $amount';
  }

  @override
  String leftAmount(String amount) {
    return '$amount left';
  }

  @override
  String overAmount(String amount) {
    return '$amount over';
  }

  @override
  String budgetWarnCaution(String label, int percent) {
    return '$label: $percent% used.';
  }

  @override
  String budgetWarnDanger(String label, int percent) {
    return '$label is almost used up ($percent%).';
  }

  @override
  String budgetWarnExceeded(String label, int percent) {
    return '$label exceeded: $percent%!';
  }

  @override
  String budgetFor(String name) {
    return '$name budget';
  }

  @override
  String get errBudgetZero => 'Enter a budget greater than 0.';

  @override
  String get errBudgetTooLarge => 'Budget is too large.';

  @override
  String get errPickReplacement =>
      'Pick a replacement category for the existing transactions.';

  @override
  String get errReplacementType =>
      'The replacement category must be of the same type.';

  @override
  String get errCategoryNameRequired => 'Category name is required.';

  @override
  String errCategoryNameTooLong(int max) {
    return 'Category name can be at most $max characters.';
  }

  @override
  String get errCategoryExists => 'A category with this name already exists.';

  @override
  String get errTransactionNotFound => 'Transaction not found.';

  @override
  String get errCategoryNotFound => 'Category not found.';

  @override
  String get errCategoryTypeMismatch =>
      'The category doesn\'t match the transaction type.';

  @override
  String get noDataYet => 'No data yet';

  @override
  String get statsEmptyMessage =>
      'Statistics and insights appear once you record transactions.';

  @override
  String get trendLast7Days => 'Spending in the last 7 days';

  @override
  String get trendDailyThisWeek => 'Daily spending this week';

  @override
  String get trendDaily => 'Daily spending trend';

  @override
  String get trendPerMonth => 'Spending per month';

  @override
  String get net => 'Net';

  @override
  String insightsFor(String month) {
    return 'Insights · $month';
  }

  @override
  String get expenseByCategory => 'Spending by Category';

  @override
  String get noExpenseInPeriod => 'No spending in this period.';

  @override
  String get incomeVsExpense => 'Income vs Expenses';

  @override
  String get monthlyExpenseTrend => 'Monthly Spending Trend';

  @override
  String get total => 'Total';

  @override
  String get insThisMonth => 'this month';

  @override
  String insMonthOf(String month) {
    return 'in $month';
  }

  @override
  String insNoTransactions(String period) {
    return 'No transactions $period yet. Record your first one!';
  }

  @override
  String insTopCategory(
    String period,
    String category,
    String amount,
    int percent,
  ) {
    return 'Your biggest spending $period is $category ($amount, $percent%).';
  }

  @override
  String get insCompareSamePeriod => 'the same period last month';

  @override
  String get insComparePrevMonth => 'the previous month';

  @override
  String insTotalUp(int percent, String comparison) {
    return 'Total spending is up $percent% compared to $comparison.';
  }

  @override
  String insTotalDown(int percent, String comparison) {
    return 'Great! Total spending is down $percent% compared to $comparison.';
  }

  @override
  String insCategoryUp(String category, int percent, String comparison) {
    return '$category spending is up $percent% compared to $comparison.';
  }

  @override
  String insBudgetExceeded(String amount) {
    return 'Spending is over the monthly budget by $amount.';
  }

  @override
  String insBudgetUsed(int percent) {
    return 'You\'ve used $percent% of your monthly budget.';
  }

  @override
  String insProjection(String amount) {
    return 'At this pace, this month\'s spending will reach about $amount, over budget.';
  }

  @override
  String insSavingRate(int percent, String period) {
    return 'You\'re saving $percent% of your income $period.';
  }

  @override
  String insOverspend(String period, String amount) {
    return 'Spending $period is $amount more than income.';
  }

  @override
  String insMostFrequent(
    String category,
    int count,
    String period,
    String amount,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: '1 time',
    );
    return 'You record $category most often ($_temp0) $period, $amount per transaction on average.';
  }

  @override
  String insAvgDaily(String period, String amount) {
    return 'Average daily spending $period: $amount.';
  }

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'Follow system';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get festiveTheme => 'Festive theme';

  @override
  String get currency => 'Currency';

  @override
  String get currencyNote =>
      'Only the symbol changes. Amounts are not converted and are recorded without decimals.';

  @override
  String get language => 'Language';

  @override
  String get nothingToExport => 'No transactions to export yet.';

  @override
  String get saveCsv => 'Save CSV';

  @override
  String csvExported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions exported to CSV.',
      one: '1 transaction exported to CSV.',
    );
    return '$_temp0';
  }

  @override
  String get saveBackup => 'Save backup';

  @override
  String get backupSaved => 'Backup saved.';

  @override
  String get restoreQ => 'Restore from backup?';

  @override
  String get restoreBody =>
      'All current data will be replaced with the backup file. Consider backing up your current data first.';

  @override
  String get pickFile => 'Choose File';

  @override
  String get pickBackupFile => 'Choose a backup file';

  @override
  String get restoreDone => 'Data restored.';

  @override
  String get loadDemoQ => 'Load demo data?';

  @override
  String get loadDemoBody =>
      'Adds sample transactions for the last 90 days so you can try the app. Demo data is labeled and can be removed any time without touching your real data.';

  @override
  String get loadDemoAction => 'Load Demo';

  @override
  String demoAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count demo transactions added.',
      one: '1 demo transaction added.',
    );
    return '$_temp0';
  }

  @override
  String get clearAllQ => 'Delete all data?';

  @override
  String clearAllBody(String word) {
    return 'All transactions, budgets, your own categories and data settings will be permanently deleted. Default categories will be recreated.\n\nType $word to continue.';
  }

  @override
  String get confirmWord => 'DELETE';

  @override
  String get deleteAll => 'Delete All';

  @override
  String get allDataCleared => 'All data has been deleted.';

  @override
  String get appearance => 'Appearance';

  @override
  String get data => 'Data';

  @override
  String get exportCsv => 'Export transactions (CSV)';

  @override
  String get backupDatabase => 'Back up database';

  @override
  String get restoreFromBackup => 'Restore from backup';

  @override
  String get demoMode => 'Demo Mode';

  @override
  String get removeDemo => 'Remove demo data';

  @override
  String get removeDemoHint => 'Only demo-labeled transactions are removed';

  @override
  String get loadDemo => 'Load demo data';

  @override
  String get loadDemoHint => 'Sample transactions to try the features';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get clearAllData => 'Delete all data';

  @override
  String get about => 'About';

  @override
  String get aboutApp => 'About Dhuwitku';

  @override
  String get appVersion => 'App version';

  @override
  String get storage => 'Storage';

  @override
  String get storageHint => 'All data is stored on this device (offline)';

  @override
  String get aboutTitle => 'About';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String aboutDescription(String app) {
    return '$app is a personal finance app designed for recording daily transactions quickly — especially the small expenses that are easy to forget. \"Dhuwitku\" is Javanese for \"my money\".\n\nThe goal is simple: track your money in seconds, and understand your finances at a glance.';
  }

  @override
  String get aboutFeatures => 'Key Features';

  @override
  String get aboutFeatureFastTitle => 'Record in seconds';

  @override
  String get aboutFeatureFastBody =>
      'Enter the amount, pick a category, save. Made for small daily expenses like food, coffee, fuel and parking.';

  @override
  String get aboutFeatureOverviewTitle => 'Overview at a glance';

  @override
  String get aboutFeatureOverviewBody =>
      'This month\'s balance, income and expenses are right on the Home screen.';

  @override
  String get aboutFeatureBudgetTitle => 'Budgets & alerts';

  @override
  String get aboutFeatureBudgetBody =>
      'Set a monthly budget and per-category limits. Alerts appear at 75%, 90% and over 100%.';

  @override
  String get aboutFeatureStatsTitle => 'Statistics & insights';

  @override
  String get aboutFeatureStatsBody =>
      'Daily to yearly charts, category breakdowns, and insights calculated from your own data.';

  @override
  String get aboutFeatureBackupTitle => 'Export & backup';

  @override
  String get aboutFeatureBackupBody =>
      'Export transactions to CSV, and back up or restore the database any time.';

  @override
  String get aboutPrivacy => 'Privacy';

  @override
  String get aboutPrivacyOffline => 'Works without internet';

  @override
  String get aboutPrivacyNoAccount => 'No account, no login';

  @override
  String get aboutPrivacyLocal => 'Data stays on this device';

  @override
  String get aboutPrivacyNoAds => 'No ads, no tracking';

  @override
  String get aboutBackupTip =>
      'Since your data only lives on this device, use Settings → Back up database regularly so it stays safe if your phone is lost or replaced.';

  @override
  String get aboutFooter => 'Made with Flutter · Currency: Rupiah (IDR)';

  @override
  String get csvTime => 'Time';

  @override
  String get csvCreated => 'Created';

  @override
  String get errBackupInvalid => 'This file is not a valid Dhuwitku backup.';

  @override
  String get errBackupNoData =>
      'The backup file doesn\'t contain Dhuwitku data.';

  @override
  String get errBackupNewer =>
      'This backup was made by a newer version of the app. Please update the app first.';

  @override
  String get errBackupCorrupt => 'The backup file is corrupted.';

  @override
  String get errBackupInconsistent => 'The data in the backup is inconsistent.';

  @override
  String get errBackupUnreadable => 'The backup file can\'t be read.';

  @override
  String get errCamera => 'Couldn\'t open the camera.';

  @override
  String get errGallery => 'Couldn\'t open the gallery.';

  @override
  String get errReadReceipt => 'Couldn\'t read the receipt. Try another photo.';

  @override
  String get receiptNoText =>
      'No text could be read. Make sure the receipt is well lit, straight and sharp.';

  @override
  String get receiptNoTotal =>
      'The total couldn\'t be read. Enter the amount manually, then check the other details.';

  @override
  String get receiptCheck =>
      'Scanned from a receipt. Check the amount, date and category before saving.';

  @override
  String get receiptGuessedTotal =>
      'No TOTAL label found; the amount was guessed from the largest number. Check before saving.';

  @override
  String get scanReceiptTitle => 'Scan Receipt';

  @override
  String get receiptTips =>
      'Take the photo in good light, with the receipt straight and the TOTAL clearly visible.';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get pickFromGallery => 'Choose from gallery';

  @override
  String get receiptPrivacy =>
      'Receipts are read on your phone and never sent to the internet.';

  @override
  String get readingReceipt => 'Reading receipt…';

  @override
  String get asstHelp =>
      'I can help you:\n• Record: \"coffee 25k\", \"salary 6.5 million yesterday\", \"parking 5000 cash\"\n• Ask: \"spending this month?\", \"coffee this week\", \"balance?\"\n• Budgets: \"budget left?\", \"food budget\"\n• Analyze: \"biggest category\", \"saving tips\"\n• Edit: \"change the last one to 30k\", \"delete last transaction\"';

  @override
  String get asstHi => 'Hi!';

  @override
  String get asstUnknown =>
      'Sorry, I didn\'t get that. I only handle your financial records.';

  @override
  String asstNoCategoryTx(String category, String range) {
    return 'No $category transactions $range yet.';
  }

  @override
  String asstNoIncome(String range) {
    return 'No income $range yet.';
  }

  @override
  String asstNoExpense(String range) {
    return 'No spending $range yet.';
  }

  @override
  String asstTotal(String what, String range, String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return '$what $range: $amount ($_temp0).';
  }

  @override
  String asstAvgPerTx(String amount) {
    return '$amount per transaction on average.';
  }

  @override
  String asstTop(String category, String amount, int percent) {
    return 'Biggest: $category $amount ($percent%).';
  }

  @override
  String asstAvgPerDay(String amount) {
    return '$amount per day on average.';
  }

  @override
  String asstBalance(
    String balance,
    String income,
    String expense,
    String monthIncome,
    String monthExpense,
  ) {
    return 'Your balance is $balance.\nTotal income $income, expenses $expense.\nThis month: $monthIncome in, $monthExpense out.';
  }

  @override
  String get asstStateSafe => 'on track';

  @override
  String get asstStateCaution => 'caution';

  @override
  String get asstStateDanger => 'almost used up';

  @override
  String get asstStateExceeded => 'exceeded';

  @override
  String asstLeft(String amount) {
    return '$amount left';
  }

  @override
  String asstOver(String amount) {
    return '$amount over';
  }

  @override
  String asstBudgetLine(
    String label,
    String left,
    String limit,
    int percent,
    String state,
  ) {
    return '$label: $left of $limit ($percent%, $state).';
  }

  @override
  String asstNoBudgetFor(String category) {
    return 'There is no budget limit for $category yet. Set one in Budgets.';
  }

  @override
  String get asstNoBudget =>
      'You haven\'t set a budget yet. Open Settings → Budgets to set a monthly budget.';

  @override
  String asstTopList(String range) {
    return 'Biggest spending $range:';
  }

  @override
  String get asstNoTips =>
      'Not enough data for tips yet. Record your spending for a few days first.';

  @override
  String get asstTipsHeader => 'Tips based on your spending:';

  @override
  String tipFrequent(
    String category,
    int count,
    String amount,
    String avg,
    String saving,
  ) {
    return '$category $count× this month ($amount, $avg on average). Cutting 2× a week ≈ saves $saving/month.';
  }

  @override
  String tipDominant(String category, int percent, String saving) {
    return '$category takes $percent% of your spending this month. Cutting it by 10% ≈ saves $saving.';
  }

  @override
  String tipTightBudget(String label, int percent) {
    return 'The $label budget is already $percent% used. Hold off on $label until the end of the month.';
  }

  @override
  String get tipNoBudget =>
      'You don\'t have a monthly budget yet. Set one in Budgets to get automatic alerts as spending nears the limit.';

  @override
  String get asstWelcome =>
      'Hi! I\'m the Dhuwitku Assistant. Type a transaction or ask about your finances.';

  @override
  String asstError(String error) {
    return 'Sorry, something went wrong: $error';
  }

  @override
  String asstWhichCategory(String type, String amount) {
    return 'Which category is this $type of $amount?';
  }

  @override
  String asstSaveFailed(String error) {
    return 'Sorry, couldn\'t save: $error';
  }

  @override
  String get asstSaved => 'Saved ✓';

  @override
  String get asstNothingToEdit => 'There are no transactions to edit yet.';

  @override
  String get asstEditHow =>
      'What should it change to? e.g. \"change to 30k\", \"change category to food\", or \"change date to yesterday\".';

  @override
  String get asstUpdated => 'Updated ✓';

  @override
  String get asstNothingToDelete => 'There are no transactions to delete yet.';

  @override
  String get asstDeleteQ => 'Delete this transaction?';

  @override
  String asstDeleteFailed(String error) {
    return 'Couldn\'t delete: $error';
  }

  @override
  String get asstNotDeleted => 'OK, it won\'t be deleted.';

  @override
  String get asstUndoneAdd => 'Undone, the transaction was removed.';

  @override
  String get asstUndoneEdit => 'Undone, the previous values are back.';

  @override
  String asstUndoFailed(String error) {
    return 'Couldn\'t undo: $error';
  }

  @override
  String get sugSpendingThisMonth => 'Spending this month';

  @override
  String get sugBudgetLeft => 'Budget left';

  @override
  String get sugTips => 'Saving tips';

  @override
  String get sugTopCategory => 'Biggest category';

  @override
  String get sugBalance => 'Balance';

  @override
  String get sugDeleteLast => 'Delete last transaction';

  @override
  String get asstTitle => 'Dhuwitku Assistant';

  @override
  String get asstSubtitle => 'Offline · data stays on your phone';

  @override
  String get asstRestart => 'Restart conversation';

  @override
  String get asstInputHint => 'e.g. coffee 25k · balance?';

  @override
  String get asstSend => 'Send';

  @override
  String get asstUndone => 'Undone';

  @override
  String get undo => 'Undo';

  @override
  String get asstDeleted => 'Deleted';

  @override
  String get asstNotDeletedShort => 'Not deleted';

  @override
  String previousAmount(String amount) {
    return 'previously $amount';
  }

  @override
  String get mascotA11y => 'Dhuwitku Assistant mascot';

  @override
  String get typingA11y => 'Assistant is typing';

  @override
  String get rangeToday => 'today';

  @override
  String get rangeYesterday => 'yesterday';

  @override
  String get rangeThisWeek => 'this week';

  @override
  String get rangeLastWeek => 'last week';

  @override
  String get rangeThisMonth => 'this month';

  @override
  String get rangeLastMonth => 'last month';

  @override
  String get rangeThisYear => 'this year';

  @override
  String get rangeLastYear => 'last year';

  @override
  String rangeLastNDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'the last $count days',
      one: 'the last day',
    );
    return '$_temp0';
  }
}
