import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('id'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @today.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In id, this message translates to:
  /// **'Kemarin'**
  String get yesterday;

  /// No description provided for @typeExpense.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get typeExpense;

  /// No description provided for @typeIncome.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan'**
  String get typeIncome;

  /// No description provided for @catFood.
  ///
  /// In id, this message translates to:
  /// **'Makan'**
  String get catFood;

  /// No description provided for @catCoffee.
  ///
  /// In id, this message translates to:
  /// **'Kopi'**
  String get catCoffee;

  /// No description provided for @catFuel.
  ///
  /// In id, this message translates to:
  /// **'Bensin'**
  String get catFuel;

  /// No description provided for @catParking.
  ///
  /// In id, this message translates to:
  /// **'Parkir'**
  String get catParking;

  /// No description provided for @catTransport.
  ///
  /// In id, this message translates to:
  /// **'Transportasi'**
  String get catTransport;

  /// No description provided for @catGroceries.
  ///
  /// In id, this message translates to:
  /// **'Belanja Harian'**
  String get catGroceries;

  /// No description provided for @catShopping.
  ///
  /// In id, this message translates to:
  /// **'Belanja'**
  String get catShopping;

  /// No description provided for @catEntertainment.
  ///
  /// In id, this message translates to:
  /// **'Hiburan'**
  String get catEntertainment;

  /// No description provided for @catBills.
  ///
  /// In id, this message translates to:
  /// **'Tagihan'**
  String get catBills;

  /// No description provided for @catHealth.
  ///
  /// In id, this message translates to:
  /// **'Kesehatan'**
  String get catHealth;

  /// No description provided for @catOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get catOther;

  /// No description provided for @catSalary.
  ///
  /// In id, this message translates to:
  /// **'Gaji'**
  String get catSalary;

  /// No description provided for @catAllowance.
  ///
  /// In id, this message translates to:
  /// **'Uang Saku'**
  String get catAllowance;

  /// No description provided for @catFreelance.
  ///
  /// In id, this message translates to:
  /// **'Freelance'**
  String get catFreelance;

  /// No description provided for @catBusiness.
  ///
  /// In id, this message translates to:
  /// **'Bisnis'**
  String get catBusiness;

  /// No description provided for @catInvestment.
  ///
  /// In id, this message translates to:
  /// **'Investasi'**
  String get catInvestment;

  /// No description provided for @payCash.
  ///
  /// In id, this message translates to:
  /// **'Tunai'**
  String get payCash;

  /// No description provided for @payCreditCard.
  ///
  /// In id, this message translates to:
  /// **'Kartu Kredit'**
  String get payCreditCard;

  /// No description provided for @payTransfer.
  ///
  /// In id, this message translates to:
  /// **'Transfer'**
  String get payTransfer;

  /// No description provided for @payDebit.
  ///
  /// In id, this message translates to:
  /// **'Debit'**
  String get payDebit;

  /// No description provided for @payEwallet.
  ///
  /// In id, this message translates to:
  /// **'E-Wallet'**
  String get payEwallet;

  /// No description provided for @errAmountZero.
  ///
  /// In id, this message translates to:
  /// **'Masukkan jumlah lebih dari 0'**
  String get errAmountZero;

  /// No description provided for @errAmountTooLarge.
  ///
  /// In id, this message translates to:
  /// **'Jumlah terlalu besar'**
  String get errAmountTooLarge;

  /// No description provided for @errPickCategory.
  ///
  /// In id, this message translates to:
  /// **'Pilih kategori terlebih dahulu'**
  String get errPickCategory;

  /// No description provided for @errNoteTooLong.
  ///
  /// In id, this message translates to:
  /// **'Catatan maksimal {max} karakter'**
  String errNoteTooLong(int max);

  /// No description provided for @errInvalidDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal tidak valid'**
  String get errInvalidDate;

  /// No description provided for @periodDaily.
  ///
  /// In id, this message translates to:
  /// **'Harian'**
  String get periodDaily;

  /// No description provided for @periodWeekly.
  ///
  /// In id, this message translates to:
  /// **'Mingguan'**
  String get periodWeekly;

  /// No description provided for @periodMonthly.
  ///
  /// In id, this message translates to:
  /// **'Bulanan'**
  String get periodMonthly;

  /// No description provided for @periodYearly.
  ///
  /// In id, this message translates to:
  /// **'Tahunan'**
  String get periodYearly;

  /// No description provided for @appTagline.
  ///
  /// In id, this message translates to:
  /// **'Catat uangmu dalam hitungan detik.'**
  String get appTagline;

  /// No description provided for @festiveNone.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada'**
  String get festiveNone;

  /// No description provided for @festiveIdulFitri.
  ///
  /// In id, this message translates to:
  /// **'Idul Fitri'**
  String get festiveIdulFitri;

  /// No description provided for @festiveIdulFitriGreeting.
  ///
  /// In id, this message translates to:
  /// **'Selamat Idul Fitri'**
  String get festiveIdulFitriGreeting;

  /// No description provided for @festiveIdulFitriSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Mohon maaf lahir dan batin'**
  String get festiveIdulFitriSubtitle;

  /// No description provided for @festiveIdulAdha.
  ///
  /// In id, this message translates to:
  /// **'Idul Adha'**
  String get festiveIdulAdha;

  /// No description provided for @festiveIdulAdhaGreeting.
  ///
  /// In id, this message translates to:
  /// **'Selamat Idul Adha'**
  String get festiveIdulAdhaGreeting;

  /// No description provided for @festiveIdulAdhaSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Semoga berkah dan penuh makna'**
  String get festiveIdulAdhaSubtitle;

  /// No description provided for @festiveImlek.
  ///
  /// In id, this message translates to:
  /// **'Imlek'**
  String get festiveImlek;

  /// No description provided for @festiveImlekGreeting.
  ///
  /// In id, this message translates to:
  /// **'Gong Xi Fa Cai'**
  String get festiveImlekGreeting;

  /// No description provided for @festiveImlekSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Selamat Tahun Baru Imlek'**
  String get festiveImlekSubtitle;

  /// No description provided for @festivePaskah.
  ///
  /// In id, this message translates to:
  /// **'Paskah'**
  String get festivePaskah;

  /// No description provided for @festivePaskahGreeting.
  ///
  /// In id, this message translates to:
  /// **'Selamat Paskah'**
  String get festivePaskahGreeting;

  /// No description provided for @festivePaskahSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Damai dan sukacita untukmu'**
  String get festivePaskahSubtitle;

  /// No description provided for @festiveNatal.
  ///
  /// In id, this message translates to:
  /// **'Natal'**
  String get festiveNatal;

  /// No description provided for @festiveNatalGreeting.
  ///
  /// In id, this message translates to:
  /// **'Selamat Natal'**
  String get festiveNatalGreeting;

  /// No description provided for @festiveNatalSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Damai dan sukacita untukmu'**
  String get festiveNatalSubtitle;

  /// No description provided for @festiveTahunBaru.
  ///
  /// In id, this message translates to:
  /// **'Tahun Baru'**
  String get festiveTahunBaru;

  /// No description provided for @festiveTahunBaruGreeting.
  ///
  /// In id, this message translates to:
  /// **'Selamat Tahun Baru'**
  String get festiveTahunBaruGreeting;

  /// No description provided for @festiveTahunBaruSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Awal baru, catatan keuangan baru'**
  String get festiveTahunBaruSubtitle;

  /// No description provided for @festiveValentine.
  ///
  /// In id, this message translates to:
  /// **'Valentine'**
  String get festiveValentine;

  /// No description provided for @festiveValentineGreeting.
  ///
  /// In id, this message translates to:
  /// **'Selamat Hari Valentine'**
  String get festiveValentineGreeting;

  /// No description provided for @festiveValentineSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Hari penuh kasih sayang'**
  String get festiveValentineSubtitle;

  /// No description provided for @festiveRamadan.
  ///
  /// In id, this message translates to:
  /// **'Ramadan'**
  String get festiveRamadan;

  /// No description provided for @festiveRamadanGreeting.
  ///
  /// In id, this message translates to:
  /// **'Marhaban ya Ramadan'**
  String get festiveRamadanGreeting;

  /// No description provided for @festiveRamadanSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Selamat menunaikan ibadah puasa'**
  String get festiveRamadanSubtitle;

  /// No description provided for @festiveNyepi.
  ///
  /// In id, this message translates to:
  /// **'Nyepi'**
  String get festiveNyepi;

  /// No description provided for @festiveNyepiGreeting.
  ///
  /// In id, this message translates to:
  /// **'Selamat Hari Raya Nyepi'**
  String get festiveNyepiGreeting;

  /// No description provided for @festiveNyepiSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Damai dalam keheningan'**
  String get festiveNyepiSubtitle;

  /// No description provided for @festiveWaisak.
  ///
  /// In id, this message translates to:
  /// **'Waisak'**
  String get festiveWaisak;

  /// No description provided for @festiveWaisakGreeting.
  ///
  /// In id, this message translates to:
  /// **'Selamat Hari Raya Waisak'**
  String get festiveWaisakGreeting;

  /// No description provided for @festiveWaisakSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Semoga semua makhluk berbahagia'**
  String get festiveWaisakSubtitle;

  /// No description provided for @festiveKartini.
  ///
  /// In id, this message translates to:
  /// **'Hari Kartini'**
  String get festiveKartini;

  /// No description provided for @festiveKartiniGreeting.
  ///
  /// In id, this message translates to:
  /// **'Selamat Hari Kartini'**
  String get festiveKartiniGreeting;

  /// No description provided for @festiveKartiniSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Habis gelap terbitlah terang'**
  String get festiveKartiniSubtitle;

  /// No description provided for @festiveKemerdekaan.
  ///
  /// In id, this message translates to:
  /// **'Kemerdekaan RI'**
  String get festiveKemerdekaan;

  /// No description provided for @festiveKemerdekaanGreeting.
  ///
  /// In id, this message translates to:
  /// **'Dirgahayu Indonesia'**
  String get festiveKemerdekaanGreeting;

  /// No description provided for @festiveKemerdekaanSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Merdeka! 17 Agustus'**
  String get festiveKemerdekaanSubtitle;

  /// No description provided for @festiveHalloween.
  ///
  /// In id, this message translates to:
  /// **'Halloween'**
  String get festiveHalloween;

  /// No description provided for @festiveHalloweenGreeting.
  ///
  /// In id, this message translates to:
  /// **'Happy Halloween'**
  String get festiveHalloweenGreeting;

  /// No description provided for @festiveHalloweenSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Awas, pengeluaran seram!'**
  String get festiveHalloweenSubtitle;

  /// No description provided for @festiveHariIbu.
  ///
  /// In id, this message translates to:
  /// **'Hari Ibu'**
  String get festiveHariIbu;

  /// No description provided for @festiveHariIbuGreeting.
  ///
  /// In id, this message translates to:
  /// **'Selamat Hari Ibu'**
  String get festiveHariIbuGreeting;

  /// No description provided for @festiveHariIbuSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Terima kasih, Ibu'**
  String get festiveHariIbuSubtitle;

  /// No description provided for @currencyIdr.
  ///
  /// In id, this message translates to:
  /// **'Rupiah Indonesia'**
  String get currencyIdr;

  /// No description provided for @currencyUsd.
  ///
  /// In id, this message translates to:
  /// **'Dolar AS'**
  String get currencyUsd;

  /// No description provided for @currencySgd.
  ///
  /// In id, this message translates to:
  /// **'Dolar Singapura'**
  String get currencySgd;

  /// No description provided for @currencyMyr.
  ///
  /// In id, this message translates to:
  /// **'Ringgit Malaysia'**
  String get currencyMyr;

  /// No description provided for @currencyEur.
  ///
  /// In id, this message translates to:
  /// **'Euro'**
  String get currencyEur;

  /// No description provided for @errorTitle.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan'**
  String get errorTitle;

  /// No description provided for @retry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get retry;

  /// No description provided for @previous.
  ///
  /// In id, this message translates to:
  /// **'Sebelumnya'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In id, this message translates to:
  /// **'Berikutnya'**
  String get next;

  /// No description provided for @errDatabase.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan ke database. Coba lagi.'**
  String get errDatabase;

  /// No description provided for @navHome.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get navHome;

  /// No description provided for @navTransactions.
  ///
  /// In id, this message translates to:
  /// **'Transaksi'**
  String get navTransactions;

  /// No description provided for @navStatistics.
  ///
  /// In id, this message translates to:
  /// **'Statistik'**
  String get navStatistics;

  /// No description provided for @navSettings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get navSettings;

  /// No description provided for @addTransactionTooltip.
  ///
  /// In id, this message translates to:
  /// **'Catat transaksi'**
  String get addTransactionTooltip;

  /// No description provided for @demoRemoved.
  ///
  /// In id, this message translates to:
  /// **'{count} transaksi demo dihapus.'**
  String demoRemoved(int count);

  /// No description provided for @dashBudgetAlerts.
  ///
  /// In id, this message translates to:
  /// **'Peringatan Anggaran'**
  String get dashBudgetAlerts;

  /// No description provided for @manage.
  ///
  /// In id, this message translates to:
  /// **'Kelola'**
  String get manage;

  /// No description provided for @dashMonthlySummary.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan Bulanan'**
  String get dashMonthlySummary;

  /// No description provided for @dashRecent.
  ///
  /// In id, this message translates to:
  /// **'Transaksi Terakhir'**
  String get dashRecent;

  /// No description provided for @seeAll.
  ///
  /// In id, this message translates to:
  /// **'Lihat semua'**
  String get seeAll;

  /// No description provided for @noTransactionsYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi'**
  String get noTransactionsYet;

  /// No description provided for @dashEmptyMessage.
  ///
  /// In id, this message translates to:
  /// **'Catat pengeluaran pertamamu, hanya butuh beberapa detik.'**
  String get dashEmptyMessage;

  /// No description provided for @recordNow.
  ///
  /// In id, this message translates to:
  /// **'Catat Sekarang'**
  String get recordNow;

  /// No description provided for @greetingMorning.
  ///
  /// In id, this message translates to:
  /// **'Selamat pagi'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In id, this message translates to:
  /// **'Selamat siang'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In id, this message translates to:
  /// **'Selamat sore'**
  String get greetingEvening;

  /// No description provided for @greetingNight.
  ///
  /// In id, this message translates to:
  /// **'Selamat malam'**
  String get greetingNight;

  /// No description provided for @scanReceipt.
  ///
  /// In id, this message translates to:
  /// **'Scan struk'**
  String get scanReceipt;

  /// No description provided for @assistantBarTitle.
  ///
  /// In id, this message translates to:
  /// **'Tanya atau catat lewat chat'**
  String get assistantBarTitle;

  /// No description provided for @assistantBarHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: \"kopi 25rb\" · \"pengeluaran bulan ini?\"'**
  String get assistantBarHint;

  /// No description provided for @demoActive.
  ///
  /// In id, this message translates to:
  /// **'Mode demo aktif: sebagian data adalah contoh.'**
  String get demoActive;

  /// No description provided for @delete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get delete;

  /// No description provided for @totalBalance.
  ///
  /// In id, this message translates to:
  /// **'Total Saldo'**
  String get totalBalance;

  /// No description provided for @incomeThisMonth.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan bulan ini'**
  String get incomeThisMonth;

  /// No description provided for @expenseThisMonth.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran bulan ini'**
  String get expenseThisMonth;

  /// No description provided for @setMonthlyBudget.
  ///
  /// In id, this message translates to:
  /// **'Atur anggaran bulanan'**
  String get setMonthlyBudget;

  /// No description provided for @budgetRemaining.
  ///
  /// In id, this message translates to:
  /// **'Sisa anggaran {amount}'**
  String budgetRemaining(String amount);

  /// No description provided for @budgetExceededBy.
  ///
  /// In id, this message translates to:
  /// **'Anggaran terlampaui {amount}'**
  String budgetExceededBy(String amount);

  /// No description provided for @history.
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get history;

  /// No description provided for @avgPerDay.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata / hari'**
  String get avgPerDay;

  /// No description provided for @topCategory.
  ///
  /// In id, this message translates to:
  /// **'Kategori terbesar'**
  String get topCategory;

  /// No description provided for @transactionsThisMonth.
  ///
  /// In id, this message translates to:
  /// **'Transaksi bulan ini'**
  String get transactionsThisMonth;

  /// No description provided for @last6Months.
  ///
  /// In id, this message translates to:
  /// **'6 bulan terakhir'**
  String get last6Months;

  /// No description provided for @legendIn.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get legendIn;

  /// No description provided for @legendOut.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get legendOut;

  /// No description provided for @chartEmpty.
  ///
  /// In id, this message translates to:
  /// **'Grafik muncul setelah ada transaksi.'**
  String get chartEmpty;

  /// No description provided for @transactionDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal transaksi'**
  String get transactionDate;

  /// No description provided for @categoryFallback.
  ///
  /// In id, this message translates to:
  /// **'kategori'**
  String get categoryFallback;

  /// No description provided for @txSaved.
  ///
  /// In id, this message translates to:
  /// **'{type} {amount} tersimpan.'**
  String txSaved(String type, String amount);

  /// No description provided for @txUpdated.
  ///
  /// In id, this message translates to:
  /// **'{type} {amount} diperbarui.'**
  String txUpdated(String type, String amount);

  /// No description provided for @editTransaction.
  ///
  /// In id, this message translates to:
  /// **'Ubah Transaksi'**
  String get editTransaction;

  /// No description provided for @amount.
  ///
  /// In id, this message translates to:
  /// **'Jumlah'**
  String get amount;

  /// No description provided for @note.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get note;

  /// No description provided for @noteHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Nasi goreng, kopi susu…'**
  String get noteHint;

  /// No description provided for @saveChanges.
  ///
  /// In id, this message translates to:
  /// **'Simpan Perubahan'**
  String get saveChanges;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @transactionType.
  ///
  /// In id, this message translates to:
  /// **'Jenis transaksi'**
  String get transactionType;

  /// No description provided for @newCategoryShort.
  ///
  /// In id, this message translates to:
  /// **'Baru'**
  String get newCategoryShort;

  /// No description provided for @paymentMethod.
  ///
  /// In id, this message translates to:
  /// **'Metode pembayaran'**
  String get paymentMethod;

  /// No description provided for @clearPaymentMethod.
  ///
  /// In id, this message translates to:
  /// **'Hapus metode'**
  String get clearPaymentMethod;

  /// No description provided for @method.
  ///
  /// In id, this message translates to:
  /// **'Metode'**
  String get method;

  /// No description provided for @tripleZero.
  ///
  /// In id, this message translates to:
  /// **'Tiga nol'**
  String get tripleZero;

  /// No description provided for @backspaceHint.
  ///
  /// In id, this message translates to:
  /// **'Hapus angka. Tahan untuk menghapus semua'**
  String get backspaceHint;

  /// No description provided for @deleteTransactionQ.
  ///
  /// In id, this message translates to:
  /// **'Hapus transaksi?'**
  String get deleteTransactionQ;

  /// No description provided for @deleteCannotUndo.
  ///
  /// In id, this message translates to:
  /// **'Transaksi yang dihapus tidak dapat dikembalikan.'**
  String get deleteCannotUndo;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @transactionDeleted.
  ///
  /// In id, this message translates to:
  /// **'Transaksi dihapus.'**
  String get transactionDeleted;

  /// No description provided for @demoData.
  ///
  /// In id, this message translates to:
  /// **'Data demo'**
  String get demoData;

  /// No description provided for @type.
  ///
  /// In id, this message translates to:
  /// **'Jenis'**
  String get type;

  /// No description provided for @category.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get category;

  /// No description provided for @date.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get date;

  /// No description provided for @recordedAt.
  ///
  /// In id, this message translates to:
  /// **'Dicatat'**
  String get recordedAt;

  /// No description provided for @updatedAt.
  ///
  /// In id, this message translates to:
  /// **'Diperbarui'**
  String get updatedAt;

  /// No description provided for @edit.
  ///
  /// In id, this message translates to:
  /// **'Ubah'**
  String get edit;

  /// No description provided for @sortNewest.
  ///
  /// In id, this message translates to:
  /// **'Terbaru dulu'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In id, this message translates to:
  /// **'Terlama dulu'**
  String get sortOldest;

  /// No description provided for @searchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari catatan atau kategori'**
  String get searchHint;

  /// No description provided for @clearSearch.
  ///
  /// In id, this message translates to:
  /// **'Hapus pencarian'**
  String get clearSearch;

  /// No description provided for @noMatchingTransactions.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada transaksi yang cocok'**
  String get noMatchingTransactions;

  /// No description provided for @noMatchingHint.
  ///
  /// In id, this message translates to:
  /// **'Coba ubah kata kunci atau filter.'**
  String get noMatchingHint;

  /// No description provided for @resetFilter.
  ///
  /// In id, this message translates to:
  /// **'Reset filter'**
  String get resetFilter;

  /// No description provided for @historyEmptyMessage.
  ///
  /// In id, this message translates to:
  /// **'Tekan tombol + untuk mencatat transaksi pertamamu.'**
  String get historyEmptyMessage;

  /// No description provided for @recordTransaction.
  ///
  /// In id, this message translates to:
  /// **'Catat Transaksi'**
  String get recordTransaction;

  /// No description provided for @all.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get all;

  /// No description provided for @pickDateRange.
  ///
  /// In id, this message translates to:
  /// **'Pilih rentang tanggal'**
  String get pickDateRange;

  /// No description provided for @apply.
  ///
  /// In id, this message translates to:
  /// **'Terapkan'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In id, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @allCategories.
  ///
  /// In id, this message translates to:
  /// **'Semua kategori'**
  String get allCategories;

  /// No description provided for @transactionCount.
  ///
  /// In id, this message translates to:
  /// **'{count} transaksi'**
  String transactionCount(int count);

  /// No description provided for @manageCategories.
  ///
  /// In id, this message translates to:
  /// **'Kelola Kategori'**
  String get manageCategories;

  /// No description provided for @noCategories.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kategori'**
  String get noCategories;

  /// No description provided for @defaultCategory.
  ///
  /// In id, this message translates to:
  /// **'Bawaan'**
  String get defaultCategory;

  /// No description provided for @deleteCategory.
  ///
  /// In id, this message translates to:
  /// **'Hapus kategori'**
  String get deleteCategory;

  /// No description provided for @errLastCategory.
  ///
  /// In id, this message translates to:
  /// **'Minimal harus ada satu kategori untuk jenis ini.'**
  String get errLastCategory;

  /// No description provided for @deleteCategoryQ.
  ///
  /// In id, this message translates to:
  /// **'Hapus \"{name}\"?'**
  String deleteCategoryQ(String name);

  /// No description provided for @deleteCategoryUnused.
  ///
  /// In id, this message translates to:
  /// **'Kategori ini belum digunakan transaksi apa pun. Anggaran untuk kategori ini juga akan dihapus.'**
  String get deleteCategoryUnused;

  /// No description provided for @deleteCategoryUsed.
  ///
  /// In id, this message translates to:
  /// **'{count} transaksi menggunakan kategori ini. Pindahkan transaksi tersebut ke:'**
  String deleteCategoryUsed(int count);

  /// No description provided for @categoryDeleted.
  ///
  /// In id, this message translates to:
  /// **'Kategori \"{name}\" dihapus.'**
  String categoryDeleted(String name);

  /// No description provided for @categoryAdded.
  ///
  /// In id, this message translates to:
  /// **'Kategori ditambahkan.'**
  String get categoryAdded;

  /// No description provided for @categoryUpdated.
  ///
  /// In id, this message translates to:
  /// **'Kategori diperbarui.'**
  String get categoryUpdated;

  /// No description provided for @newCategory.
  ///
  /// In id, this message translates to:
  /// **'Kategori Baru'**
  String get newCategory;

  /// No description provided for @editCategory.
  ///
  /// In id, this message translates to:
  /// **'Ubah Kategori'**
  String get editCategory;

  /// No description provided for @categoryName.
  ///
  /// In id, this message translates to:
  /// **'Nama kategori'**
  String get categoryName;

  /// No description provided for @color.
  ///
  /// In id, this message translates to:
  /// **'Warna'**
  String get color;

  /// No description provided for @icon.
  ///
  /// In id, this message translates to:
  /// **'Ikon'**
  String get icon;

  /// No description provided for @saveCategory.
  ///
  /// In id, this message translates to:
  /// **'Simpan Kategori'**
  String get saveCategory;

  /// No description provided for @budgets.
  ///
  /// In id, this message translates to:
  /// **'Anggaran'**
  String get budgets;

  /// No description provided for @budgetCarryHint.
  ///
  /// In id, this message translates to:
  /// **'Anggaran berlaku mulai bulan yang dipilih dan terus berlanjut ke bulan berikutnya sampai diubah.'**
  String get budgetCarryHint;

  /// No description provided for @monthlyBudget.
  ///
  /// In id, this message translates to:
  /// **'Anggaran Bulanan'**
  String get monthlyBudget;

  /// No description provided for @setTotalBudget.
  ///
  /// In id, this message translates to:
  /// **'Atur anggaran total untuk bulan ini'**
  String get setTotalBudget;

  /// No description provided for @categoryLimits.
  ///
  /// In id, this message translates to:
  /// **'Batas per Kategori'**
  String get categoryLimits;

  /// No description provided for @add.
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get add;

  /// No description provided for @noCategoryLimits.
  ///
  /// In id, this message translates to:
  /// **'Belum ada batas kategori'**
  String get noCategoryLimits;

  /// No description provided for @categoryLimitExample.
  ///
  /// In id, this message translates to:
  /// **'Contoh: batasi Kopi Rp 300.000 per bulan.'**
  String get categoryLimitExample;

  /// No description provided for @addLimit.
  ///
  /// In id, this message translates to:
  /// **'Tambah batas'**
  String get addLimit;

  /// No description provided for @pickCategory.
  ///
  /// In id, this message translates to:
  /// **'Pilih kategori'**
  String get pickCategory;

  /// No description provided for @budgetSaved.
  ///
  /// In id, this message translates to:
  /// **'Anggaran {label} disimpan.'**
  String budgetSaved(String label);

  /// No description provided for @deleteBudgetQ.
  ///
  /// In id, this message translates to:
  /// **'Hapus anggaran?'**
  String get deleteBudgetQ;

  /// No description provided for @deleteBudgetBody.
  ///
  /// In id, this message translates to:
  /// **'{label} tidak lagi berlaku mulai {month}. Anggaran bulan-bulan sebelumnya tetap tersimpan.'**
  String deleteBudgetBody(String label, String month);

  /// No description provided for @budgetDeleted.
  ///
  /// In id, this message translates to:
  /// **'Anggaran {label} dihapus.'**
  String budgetDeleted(String label);

  /// No description provided for @startingFrom.
  ///
  /// In id, this message translates to:
  /// **'Mulai {month}'**
  String startingFrom(String month);

  /// No description provided for @levelSafe.
  ///
  /// In id, this message translates to:
  /// **'Aman'**
  String get levelSafe;

  /// No description provided for @levelCaution.
  ///
  /// In id, this message translates to:
  /// **'Waspada'**
  String get levelCaution;

  /// No description provided for @levelDanger.
  ///
  /// In id, this message translates to:
  /// **'Hampir habis'**
  String get levelDanger;

  /// No description provided for @levelExceeded.
  ///
  /// In id, this message translates to:
  /// **'Terlampaui'**
  String get levelExceeded;

  /// No description provided for @usedPercentA11y.
  ///
  /// In id, this message translates to:
  /// **'Terpakai {percent} persen'**
  String usedPercentA11y(int percent);

  /// No description provided for @budgetAmount.
  ///
  /// In id, this message translates to:
  /// **'Anggaran {amount}'**
  String budgetAmount(String amount);

  /// No description provided for @deleteBudget.
  ///
  /// In id, this message translates to:
  /// **'Hapus anggaran'**
  String get deleteBudget;

  /// No description provided for @spentAmount.
  ///
  /// In id, this message translates to:
  /// **'Terpakai {amount}'**
  String spentAmount(String amount);

  /// No description provided for @leftAmount.
  ///
  /// In id, this message translates to:
  /// **'Sisa {amount}'**
  String leftAmount(String amount);

  /// No description provided for @overAmount.
  ///
  /// In id, this message translates to:
  /// **'Lebih {amount}'**
  String overAmount(String amount);

  /// No description provided for @budgetWarnCaution.
  ///
  /// In id, this message translates to:
  /// **'{label} sudah terpakai {percent}%.'**
  String budgetWarnCaution(String label, int percent);

  /// No description provided for @budgetWarnDanger.
  ///
  /// In id, this message translates to:
  /// **'{label} hampir habis ({percent}%).'**
  String budgetWarnDanger(String label, int percent);

  /// No description provided for @budgetWarnExceeded.
  ///
  /// In id, this message translates to:
  /// **'{label} terlampaui {percent}%!'**
  String budgetWarnExceeded(String label, int percent);

  /// No description provided for @budgetFor.
  ///
  /// In id, this message translates to:
  /// **'Anggaran {name}'**
  String budgetFor(String name);

  /// No description provided for @errBudgetZero.
  ///
  /// In id, this message translates to:
  /// **'Masukkan anggaran lebih dari 0.'**
  String get errBudgetZero;

  /// No description provided for @errBudgetTooLarge.
  ///
  /// In id, this message translates to:
  /// **'Anggaran terlalu besar.'**
  String get errBudgetTooLarge;

  /// No description provided for @errPickReplacement.
  ///
  /// In id, this message translates to:
  /// **'Pilih kategori pengganti untuk transaksi yang ada.'**
  String get errPickReplacement;

  /// No description provided for @errReplacementType.
  ///
  /// In id, this message translates to:
  /// **'Kategori pengganti harus berjenis sama.'**
  String get errReplacementType;

  /// No description provided for @errCategoryNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama kategori wajib diisi.'**
  String get errCategoryNameRequired;

  /// No description provided for @errCategoryNameTooLong.
  ///
  /// In id, this message translates to:
  /// **'Nama kategori maksimal {max} karakter.'**
  String errCategoryNameTooLong(int max);

  /// No description provided for @errCategoryExists.
  ///
  /// In id, this message translates to:
  /// **'Kategori dengan nama ini sudah ada.'**
  String get errCategoryExists;

  /// No description provided for @errTransactionNotFound.
  ///
  /// In id, this message translates to:
  /// **'Transaksi tidak ditemukan.'**
  String get errTransactionNotFound;

  /// No description provided for @errCategoryNotFound.
  ///
  /// In id, this message translates to:
  /// **'Kategori tidak ditemukan.'**
  String get errCategoryNotFound;

  /// No description provided for @errCategoryTypeMismatch.
  ///
  /// In id, this message translates to:
  /// **'Kategori tidak sesuai dengan jenis transaksi.'**
  String get errCategoryTypeMismatch;

  /// No description provided for @noDataYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data'**
  String get noDataYet;

  /// No description provided for @statsEmptyMessage.
  ///
  /// In id, this message translates to:
  /// **'Statistik dan insight akan muncul setelah kamu mencatat transaksi.'**
  String get statsEmptyMessage;

  /// No description provided for @trendLast7Days.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran 7 hari terakhir'**
  String get trendLast7Days;

  /// No description provided for @trendDailyThisWeek.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran harian minggu ini'**
  String get trendDailyThisWeek;

  /// No description provided for @trendDaily.
  ///
  /// In id, this message translates to:
  /// **'Tren pengeluaran harian'**
  String get trendDaily;

  /// No description provided for @trendPerMonth.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran per bulan'**
  String get trendPerMonth;

  /// No description provided for @net.
  ///
  /// In id, this message translates to:
  /// **'Selisih'**
  String get net;

  /// No description provided for @insightsFor.
  ///
  /// In id, this message translates to:
  /// **'Insight {month}'**
  String insightsFor(String month);

  /// No description provided for @expenseByCategory.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran per Kategori'**
  String get expenseByCategory;

  /// No description provided for @noExpenseInPeriod.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada pengeluaran pada periode ini.'**
  String get noExpenseInPeriod;

  /// No description provided for @incomeVsExpense.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan vs Pengeluaran'**
  String get incomeVsExpense;

  /// No description provided for @monthlyExpenseTrend.
  ///
  /// In id, this message translates to:
  /// **'Tren Pengeluaran Bulanan'**
  String get monthlyExpenseTrend;

  /// No description provided for @total.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @insThisMonth.
  ///
  /// In id, this message translates to:
  /// **'bulan ini'**
  String get insThisMonth;

  /// No description provided for @insMonthOf.
  ///
  /// In id, this message translates to:
  /// **'bulan {month}'**
  String insMonthOf(String month);

  /// No description provided for @insNoTransactions.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi {period}. Catat transaksi pertamamu!'**
  String insNoTransactions(String period);

  /// No description provided for @insTopCategory.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran terbesar {period} berasal dari kategori {category} ({amount}, {percent}%).'**
  String insTopCategory(
    String period,
    String category,
    String amount,
    int percent,
  );

  /// No description provided for @insCompareSamePeriod.
  ///
  /// In id, this message translates to:
  /// **'periode yang sama bulan lalu'**
  String get insCompareSamePeriod;

  /// No description provided for @insComparePrevMonth.
  ///
  /// In id, this message translates to:
  /// **'bulan sebelumnya'**
  String get insComparePrevMonth;

  /// No description provided for @insTotalUp.
  ///
  /// In id, this message translates to:
  /// **'Total pengeluaran naik {percent}% dibandingkan {comparison}.'**
  String insTotalUp(int percent, String comparison);

  /// No description provided for @insTotalDown.
  ///
  /// In id, this message translates to:
  /// **'Hebat! Total pengeluaran turun {percent}% dibandingkan {comparison}.'**
  String insTotalDown(int percent, String comparison);

  /// No description provided for @insCategoryUp.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran {category} meningkat {percent}% dibandingkan {comparison}.'**
  String insCategoryUp(String category, int percent, String comparison);

  /// No description provided for @insBudgetExceeded.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran sudah melebihi anggaran bulanan sebesar {amount}.'**
  String insBudgetExceeded(String amount);

  /// No description provided for @insBudgetUsed.
  ///
  /// In id, this message translates to:
  /// **'Kamu sudah menggunakan {percent}% dari anggaran bulanan.'**
  String insBudgetUsed(int percent);

  /// No description provided for @insProjection.
  ///
  /// In id, this message translates to:
  /// **'Dengan pola saat ini, pengeluaran bulan ini diperkirakan {amount}, melebihi anggaran.'**
  String insProjection(String amount);

  /// No description provided for @insSavingRate.
  ///
  /// In id, this message translates to:
  /// **'Kamu menyisihkan {percent}% dari pemasukan {period}.'**
  String insSavingRate(int percent, String period);

  /// No description provided for @insOverspend.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran {period} lebih besar {amount} dari pemasukan.'**
  String insOverspend(String period, String amount);

  /// No description provided for @insMostFrequent.
  ///
  /// In id, this message translates to:
  /// **'Kamu paling sering mencatat {category} ({count} kali) {period}, rata-rata {amount} per transaksi.'**
  String insMostFrequent(
    String category,
    int count,
    String period,
    String amount,
  );

  /// No description provided for @insAvgDaily.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata pengeluaran harian {period} {amount}.'**
  String insAvgDaily(String period, String amount);

  /// No description provided for @theme.
  ///
  /// In id, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In id, this message translates to:
  /// **'Ikuti sistem'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In id, this message translates to:
  /// **'Terang'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In id, this message translates to:
  /// **'Gelap'**
  String get themeDark;

  /// No description provided for @festiveTheme.
  ///
  /// In id, this message translates to:
  /// **'Tema perayaan'**
  String get festiveTheme;

  /// No description provided for @currency.
  ///
  /// In id, this message translates to:
  /// **'Mata uang'**
  String get currency;

  /// No description provided for @currencyNote.
  ///
  /// In id, this message translates to:
  /// **'Hanya simbol yang berubah. Jumlah tidak dikonversi dan dicatat tanpa desimal.'**
  String get currencyNote;

  /// No description provided for @language.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get language;

  /// No description provided for @nothingToExport.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi untuk diekspor.'**
  String get nothingToExport;

  /// No description provided for @saveCsv.
  ///
  /// In id, this message translates to:
  /// **'Simpan CSV'**
  String get saveCsv;

  /// No description provided for @csvExported.
  ///
  /// In id, this message translates to:
  /// **'{count} transaksi diekspor ke CSV.'**
  String csvExported(int count);

  /// No description provided for @saveBackup.
  ///
  /// In id, this message translates to:
  /// **'Simpan cadangan'**
  String get saveBackup;

  /// No description provided for @backupSaved.
  ///
  /// In id, this message translates to:
  /// **'Cadangan berhasil disimpan.'**
  String get backupSaved;

  /// No description provided for @restoreQ.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan dari cadangan?'**
  String get restoreQ;

  /// No description provided for @restoreBody.
  ///
  /// In id, this message translates to:
  /// **'Semua data saat ini akan diganti dengan isi file cadangan. Sebaiknya buat cadangan data saat ini terlebih dahulu.'**
  String get restoreBody;

  /// No description provided for @pickFile.
  ///
  /// In id, this message translates to:
  /// **'Pilih File'**
  String get pickFile;

  /// No description provided for @pickBackupFile.
  ///
  /// In id, this message translates to:
  /// **'Pilih file cadangan'**
  String get pickBackupFile;

  /// No description provided for @restoreDone.
  ///
  /// In id, this message translates to:
  /// **'Data berhasil dipulihkan.'**
  String get restoreDone;

  /// No description provided for @loadDemoQ.
  ///
  /// In id, this message translates to:
  /// **'Muat data demo?'**
  String get loadDemoQ;

  /// No description provided for @loadDemoBody.
  ///
  /// In id, this message translates to:
  /// **'Menambahkan contoh transaksi 90 hari terakhir untuk mencoba aplikasi. Data demo ditandai dan bisa dihapus kapan saja tanpa mengganggu data aslimu.'**
  String get loadDemoBody;

  /// No description provided for @loadDemoAction.
  ///
  /// In id, this message translates to:
  /// **'Muat Demo'**
  String get loadDemoAction;

  /// No description provided for @demoAdded.
  ///
  /// In id, this message translates to:
  /// **'{count} transaksi demo ditambahkan.'**
  String demoAdded(int count);

  /// No description provided for @clearAllQ.
  ///
  /// In id, this message translates to:
  /// **'Hapus semua data?'**
  String get clearAllQ;

  /// No description provided for @clearAllBody.
  ///
  /// In id, this message translates to:
  /// **'Semua transaksi, anggaran, kategori buatanmu, dan pengaturan data akan dihapus permanen. Kategori bawaan akan dibuat ulang.\n\nKetik {word} untuk melanjutkan.'**
  String clearAllBody(String word);

  /// No description provided for @confirmWord.
  ///
  /// In id, this message translates to:
  /// **'HAPUS'**
  String get confirmWord;

  /// No description provided for @deleteAll.
  ///
  /// In id, this message translates to:
  /// **'Hapus Semua'**
  String get deleteAll;

  /// No description provided for @allDataCleared.
  ///
  /// In id, this message translates to:
  /// **'Semua data telah dihapus.'**
  String get allDataCleared;

  /// No description provided for @appearance.
  ///
  /// In id, this message translates to:
  /// **'Tampilan'**
  String get appearance;

  /// No description provided for @data.
  ///
  /// In id, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @exportCsv.
  ///
  /// In id, this message translates to:
  /// **'Ekspor transaksi (CSV)'**
  String get exportCsv;

  /// No description provided for @backupDatabase.
  ///
  /// In id, this message translates to:
  /// **'Cadangkan database'**
  String get backupDatabase;

  /// No description provided for @restoreFromBackup.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan dari cadangan'**
  String get restoreFromBackup;

  /// No description provided for @demoMode.
  ///
  /// In id, this message translates to:
  /// **'Mode Demo'**
  String get demoMode;

  /// No description provided for @removeDemo.
  ///
  /// In id, this message translates to:
  /// **'Hapus data demo'**
  String get removeDemo;

  /// No description provided for @removeDemoHint.
  ///
  /// In id, this message translates to:
  /// **'Hanya transaksi berlabel demo yang dihapus'**
  String get removeDemoHint;

  /// No description provided for @loadDemo.
  ///
  /// In id, this message translates to:
  /// **'Muat data demo'**
  String get loadDemo;

  /// No description provided for @loadDemoHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh transaksi untuk mencoba fitur'**
  String get loadDemoHint;

  /// No description provided for @dangerZone.
  ///
  /// In id, this message translates to:
  /// **'Zona Bahaya'**
  String get dangerZone;

  /// No description provided for @clearAllData.
  ///
  /// In id, this message translates to:
  /// **'Hapus semua data'**
  String get clearAllData;

  /// No description provided for @about.
  ///
  /// In id, this message translates to:
  /// **'Tentang'**
  String get about;

  /// No description provided for @aboutApp.
  ///
  /// In id, this message translates to:
  /// **'Tentang Dhuwitku'**
  String get aboutApp;

  /// No description provided for @appVersion.
  ///
  /// In id, this message translates to:
  /// **'Versi aplikasi'**
  String get appVersion;

  /// No description provided for @storage.
  ///
  /// In id, this message translates to:
  /// **'Penyimpanan'**
  String get storage;

  /// No description provided for @storageHint.
  ///
  /// In id, this message translates to:
  /// **'Semua data tersimpan di perangkat ini (offline)'**
  String get storageHint;

  /// No description provided for @aboutTitle.
  ///
  /// In id, this message translates to:
  /// **'Tentang Aplikasi'**
  String get aboutTitle;

  /// No description provided for @versionLabel.
  ///
  /// In id, this message translates to:
  /// **'Versi {version}'**
  String versionLabel(String version);

  /// No description provided for @aboutDescription.
  ///
  /// In id, this message translates to:
  /// **'{app} adalah aplikasi pencatat keuangan pribadi yang dirancang untuk mencatat transaksi harian dengan cepat, terutama pengeluaran kecil yang sering terlupa. Nama \"Dhuwitku\" berasal dari bahasa Jawa yang berarti \"uangku\".\n\nTujuannya sederhana: catat uangmu dalam hitungan detik, dan pahami kondisi keuanganmu hanya dengan sekali lihat.'**
  String aboutDescription(String app);

  /// No description provided for @aboutFeatures.
  ///
  /// In id, this message translates to:
  /// **'Fitur Utama'**
  String get aboutFeatures;

  /// No description provided for @aboutFeatureFastTitle.
  ///
  /// In id, this message translates to:
  /// **'Catat dalam hitungan detik'**
  String get aboutFeatureFastTitle;

  /// No description provided for @aboutFeatureFastBody.
  ///
  /// In id, this message translates to:
  /// **'Masukkan jumlah, pilih kategori, simpan. Cocok untuk pengeluaran kecil harian seperti makan, kopi, bensin, dan parkir.'**
  String get aboutFeatureFastBody;

  /// No description provided for @aboutFeatureOverviewTitle.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan sekilas'**
  String get aboutFeatureOverviewTitle;

  /// No description provided for @aboutFeatureOverviewBody.
  ///
  /// In id, this message translates to:
  /// **'Saldo, pemasukan, dan pengeluaran bulan ini langsung terlihat di Beranda.'**
  String get aboutFeatureOverviewBody;

  /// No description provided for @aboutFeatureBudgetTitle.
  ///
  /// In id, this message translates to:
  /// **'Anggaran & peringatan'**
  String get aboutFeatureBudgetTitle;

  /// No description provided for @aboutFeatureBudgetBody.
  ///
  /// In id, this message translates to:
  /// **'Atur anggaran bulanan dan batas per kategori. Peringatan muncul saat terpakai 75%, 90%, dan lebih dari 100%.'**
  String get aboutFeatureBudgetBody;

  /// No description provided for @aboutFeatureStatsTitle.
  ///
  /// In id, this message translates to:
  /// **'Statistik & insight'**
  String get aboutFeatureStatsTitle;

  /// No description provided for @aboutFeatureStatsBody.
  ///
  /// In id, this message translates to:
  /// **'Grafik harian hingga tahunan, rincian per kategori, dan insight yang dihitung dari datamu sendiri.'**
  String get aboutFeatureStatsBody;

  /// No description provided for @aboutFeatureBackupTitle.
  ///
  /// In id, this message translates to:
  /// **'Ekspor & cadangan'**
  String get aboutFeatureBackupTitle;

  /// No description provided for @aboutFeatureBackupBody.
  ///
  /// In id, this message translates to:
  /// **'Ekspor transaksi ke CSV, cadangkan, dan pulihkan database kapan saja.'**
  String get aboutFeatureBackupBody;

  /// No description provided for @aboutPrivacy.
  ///
  /// In id, this message translates to:
  /// **'Privasi'**
  String get aboutPrivacy;

  /// No description provided for @aboutPrivacyOffline.
  ///
  /// In id, this message translates to:
  /// **'Bekerja tanpa internet'**
  String get aboutPrivacyOffline;

  /// No description provided for @aboutPrivacyNoAccount.
  ///
  /// In id, this message translates to:
  /// **'Tanpa akun dan tanpa login'**
  String get aboutPrivacyNoAccount;

  /// No description provided for @aboutPrivacyLocal.
  ///
  /// In id, this message translates to:
  /// **'Data hanya tersimpan di perangkat ini'**
  String get aboutPrivacyLocal;

  /// No description provided for @aboutPrivacyNoAds.
  ///
  /// In id, this message translates to:
  /// **'Tanpa iklan dan tanpa pelacakan'**
  String get aboutPrivacyNoAds;

  /// No description provided for @aboutBackupTip.
  ///
  /// In id, this message translates to:
  /// **'Karena data hanya ada di perangkat ini, gunakan Pengaturan → Cadangkan database secara berkala agar datamu aman jika HP hilang atau diganti.'**
  String get aboutBackupTip;

  /// No description provided for @aboutFooter.
  ///
  /// In id, this message translates to:
  /// **'Dibuat dengan Flutter · Mata uang: Rupiah (IDR)'**
  String get aboutFooter;

  /// No description provided for @csvTime.
  ///
  /// In id, this message translates to:
  /// **'Waktu'**
  String get csvTime;

  /// No description provided for @csvCreated.
  ///
  /// In id, this message translates to:
  /// **'Dibuat'**
  String get csvCreated;

  /// No description provided for @errBackupInvalid.
  ///
  /// In id, this message translates to:
  /// **'File bukan cadangan Dhuwitku yang valid.'**
  String get errBackupInvalid;

  /// No description provided for @errBackupNoData.
  ///
  /// In id, this message translates to:
  /// **'File cadangan tidak berisi data Dhuwitku.'**
  String get errBackupNoData;

  /// No description provided for @errBackupNewer.
  ///
  /// In id, this message translates to:
  /// **'Cadangan dibuat oleh versi aplikasi yang lebih baru. Perbarui aplikasi terlebih dahulu.'**
  String get errBackupNewer;

  /// No description provided for @errBackupCorrupt.
  ///
  /// In id, this message translates to:
  /// **'File cadangan rusak.'**
  String get errBackupCorrupt;

  /// No description provided for @errBackupInconsistent.
  ///
  /// In id, this message translates to:
  /// **'Data dalam cadangan tidak konsisten.'**
  String get errBackupInconsistent;

  /// No description provided for @errBackupUnreadable.
  ///
  /// In id, this message translates to:
  /// **'File cadangan tidak dapat dibaca.'**
  String get errBackupUnreadable;

  /// No description provided for @errCamera.
  ///
  /// In id, this message translates to:
  /// **'Kamera tidak dapat dibuka.'**
  String get errCamera;

  /// No description provided for @errGallery.
  ///
  /// In id, this message translates to:
  /// **'Galeri tidak dapat dibuka.'**
  String get errGallery;

  /// No description provided for @errReadReceipt.
  ///
  /// In id, this message translates to:
  /// **'Gagal membaca struk. Coba foto ulang.'**
  String get errReadReceipt;

  /// No description provided for @receiptNoText.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada tulisan yang terbaca. Pastikan struk terang, lurus, dan tidak buram.'**
  String get receiptNoText;

  /// No description provided for @receiptNoTotal.
  ///
  /// In id, this message translates to:
  /// **'Total tidak terbaca. Isi jumlah secara manual, lalu periksa data lainnya.'**
  String get receiptNoTotal;

  /// No description provided for @receiptCheck.
  ///
  /// In id, this message translates to:
  /// **'Hasil scan struk. Periksa jumlah, tanggal, dan kategori sebelum menyimpan.'**
  String get receiptCheck;

  /// No description provided for @receiptGuessedTotal.
  ///
  /// In id, this message translates to:
  /// **'Label TOTAL tidak ditemukan; jumlah ditebak dari angka terbesar. Periksa sebelum menyimpan.'**
  String get receiptGuessedTotal;

  /// No description provided for @scanReceiptTitle.
  ///
  /// In id, this message translates to:
  /// **'Scan Struk'**
  String get scanReceiptTitle;

  /// No description provided for @receiptTips.
  ///
  /// In id, this message translates to:
  /// **'Foto struk dengan cahaya cukup, posisi lurus, dan tulisan TOTAL terlihat jelas.'**
  String get receiptTips;

  /// No description provided for @takePhoto.
  ///
  /// In id, this message translates to:
  /// **'Ambil foto'**
  String get takePhoto;

  /// No description provided for @pickFromGallery.
  ///
  /// In id, this message translates to:
  /// **'Pilih dari galeri'**
  String get pickFromGallery;

  /// No description provided for @receiptPrivacy.
  ///
  /// In id, this message translates to:
  /// **'Struk dibaca langsung di HP, tidak dikirim ke internet.'**
  String get receiptPrivacy;

  /// No description provided for @readingReceipt.
  ///
  /// In id, this message translates to:
  /// **'Membaca struk…'**
  String get readingReceipt;

  /// No description provided for @asstHelp.
  ///
  /// In id, this message translates to:
  /// **'Aku bisa bantu:\n• Catat: \"kopi 25rb\", \"gaji 6,5jt kemarin\", \"parkir 5000 tunai\"\n• Tanya: \"pengeluaran bulan ini?\", \"kopi minggu ini\", \"saldo?\"\n• Anggaran: \"sisa anggaran?\", \"anggaran makan\"\n• Analisis: \"kategori terbesar\", \"tips hemat\"\n• Ubah: \"ubah yang tadi jadi 30rb\", \"hapus transaksi terakhir\"'**
  String get asstHelp;

  /// No description provided for @asstHi.
  ///
  /// In id, this message translates to:
  /// **'Hai!'**
  String get asstHi;

  /// No description provided for @asstUnknown.
  ///
  /// In id, this message translates to:
  /// **'Maaf, aku belum paham. Aku khusus mengurus catatan keuanganmu.'**
  String get asstUnknown;

  /// No description provided for @asstNoCategoryTx.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi {category} {range}.'**
  String asstNoCategoryTx(String category, String range);

  /// No description provided for @asstNoIncome.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pemasukan {range}.'**
  String asstNoIncome(String range);

  /// No description provided for @asstNoExpense.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pengeluaran {range}.'**
  String asstNoExpense(String range);

  /// No description provided for @asstTotal.
  ///
  /// In id, this message translates to:
  /// **'{what} {range} {amount} ({count} transaksi).'**
  String asstTotal(String what, String range, String amount, int count);

  /// No description provided for @asstAvgPerTx.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata {amount} per transaksi.'**
  String asstAvgPerTx(String amount);

  /// No description provided for @asstTop.
  ///
  /// In id, this message translates to:
  /// **'Terbesar: {category} {amount} ({percent}%).'**
  String asstTop(String category, String amount, int percent);

  /// No description provided for @asstAvgPerDay.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata {amount} per hari.'**
  String asstAvgPerDay(String amount);

  /// No description provided for @asstBalance.
  ///
  /// In id, this message translates to:
  /// **'Saldo kamu {balance}.\nTotal pemasukan {income}, pengeluaran {expense}.\nBulan ini: masuk {monthIncome}, keluar {monthExpense}.'**
  String asstBalance(
    String balance,
    String income,
    String expense,
    String monthIncome,
    String monthExpense,
  );

  /// No description provided for @asstStateSafe.
  ///
  /// In id, this message translates to:
  /// **'aman'**
  String get asstStateSafe;

  /// No description provided for @asstStateCaution.
  ///
  /// In id, this message translates to:
  /// **'waspada'**
  String get asstStateCaution;

  /// No description provided for @asstStateDanger.
  ///
  /// In id, this message translates to:
  /// **'hampir habis'**
  String get asstStateDanger;

  /// No description provided for @asstStateExceeded.
  ///
  /// In id, this message translates to:
  /// **'terlampaui'**
  String get asstStateExceeded;

  /// No description provided for @asstLeft.
  ///
  /// In id, this message translates to:
  /// **'sisa {amount}'**
  String asstLeft(String amount);

  /// No description provided for @asstOver.
  ///
  /// In id, this message translates to:
  /// **'lebih {amount}'**
  String asstOver(String amount);

  /// No description provided for @asstBudgetLine.
  ///
  /// In id, this message translates to:
  /// **'{label}: {left} dari {limit} ({percent}%, {state}).'**
  String asstBudgetLine(
    String label,
    String left,
    String limit,
    int percent,
    String state,
  );

  /// No description provided for @asstNoBudgetFor.
  ///
  /// In id, this message translates to:
  /// **'Belum ada batas anggaran untuk {category}. Atur di menu Anggaran.'**
  String asstNoBudgetFor(String category);

  /// No description provided for @asstNoBudget.
  ///
  /// In id, this message translates to:
  /// **'Kamu belum mengatur anggaran. Buka Pengaturan → Anggaran untuk mengatur anggaran bulanan.'**
  String get asstNoBudget;

  /// No description provided for @asstTopList.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran terbesar {range}:'**
  String asstTopList(String range);

  /// No description provided for @asstNoTips.
  ///
  /// In id, this message translates to:
  /// **'Belum cukup data untuk memberi saran. Catat pengeluaranmu beberapa hari dulu, ya.'**
  String get asstNoTips;

  /// No description provided for @asstTipsHeader.
  ///
  /// In id, this message translates to:
  /// **'Saran dari pola pengeluaranmu:'**
  String get asstTipsHeader;

  /// No description provided for @tipFrequent.
  ///
  /// In id, this message translates to:
  /// **'{category} {count}× bulan ini ({amount}, rata-rata {avg}). Kurangi 2× seminggu ≈ hemat {saving}/bulan.'**
  String tipFrequent(
    String category,
    int count,
    String amount,
    String avg,
    String saving,
  );

  /// No description provided for @tipDominant.
  ///
  /// In id, this message translates to:
  /// **'{category} menyerap {percent}% pengeluaranmu bulan ini. Turunkan 10% ≈ hemat {saving}.'**
  String tipDominant(String category, int percent, String saving);

  /// No description provided for @tipTightBudget.
  ///
  /// In id, this message translates to:
  /// **'Anggaran {label} sudah {percent}% terpakai. Tahan dulu pengeluaran {label} sampai akhir bulan.'**
  String tipTightBudget(String label, int percent);

  /// No description provided for @tipNoBudget.
  ///
  /// In id, this message translates to:
  /// **'Kamu belum punya anggaran bulanan. Atur di menu Anggaran supaya dapat peringatan otomatis saat pengeluaran mendekati batas.'**
  String get tipNoBudget;

  /// No description provided for @asstWelcome.
  ///
  /// In id, this message translates to:
  /// **'Hai! Aku Asisten Dhuwitku. Ketik transaksi atau tanya soal keuanganmu.'**
  String get asstWelcome;

  /// No description provided for @asstError.
  ///
  /// In id, this message translates to:
  /// **'Maaf, terjadi kesalahan: {error}'**
  String asstError(String error);

  /// No description provided for @asstWhichCategory.
  ///
  /// In id, this message translates to:
  /// **'{type} {amount} masuk kategori apa?'**
  String asstWhichCategory(String type, String amount);

  /// No description provided for @asstSaveFailed.
  ///
  /// In id, this message translates to:
  /// **'Maaf, gagal menyimpan: {error}'**
  String asstSaveFailed(String error);

  /// No description provided for @asstSaved.
  ///
  /// In id, this message translates to:
  /// **'Tersimpan ✓'**
  String get asstSaved;

  /// No description provided for @asstNothingToEdit.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi untuk diubah.'**
  String get asstNothingToEdit;

  /// No description provided for @asstEditHow.
  ///
  /// In id, this message translates to:
  /// **'Mau diubah jadi apa? Contoh: \"ubah jadi 30rb\", \"kategorinya jadi makan\", atau \"tanggalnya jadi kemarin\".'**
  String get asstEditHow;

  /// No description provided for @asstUpdated.
  ///
  /// In id, this message translates to:
  /// **'Diperbarui ✓'**
  String get asstUpdated;

  /// No description provided for @asstNothingToDelete.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi untuk dihapus.'**
  String get asstNothingToDelete;

  /// No description provided for @asstDeleteQ.
  ///
  /// In id, this message translates to:
  /// **'Hapus transaksi ini?'**
  String get asstDeleteQ;

  /// No description provided for @asstDeleteFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menghapus: {error}'**
  String asstDeleteFailed(String error);

  /// No description provided for @asstNotDeleted.
  ///
  /// In id, this message translates to:
  /// **'Oke, tidak jadi dihapus.'**
  String get asstNotDeleted;

  /// No description provided for @asstUndoneAdd.
  ///
  /// In id, this message translates to:
  /// **'Dibatalkan, transaksi dihapus.'**
  String get asstUndoneAdd;

  /// No description provided for @asstUndoneEdit.
  ///
  /// In id, this message translates to:
  /// **'Dibatalkan, data dikembalikan.'**
  String get asstUndoneEdit;

  /// No description provided for @asstUndoFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal membatalkan: {error}'**
  String asstUndoFailed(String error);

  /// No description provided for @sugSpendingThisMonth.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran bulan ini'**
  String get sugSpendingThisMonth;

  /// No description provided for @sugBudgetLeft.
  ///
  /// In id, this message translates to:
  /// **'Sisa anggaran'**
  String get sugBudgetLeft;

  /// No description provided for @sugTips.
  ///
  /// In id, this message translates to:
  /// **'Tips hemat'**
  String get sugTips;

  /// No description provided for @sugTopCategory.
  ///
  /// In id, this message translates to:
  /// **'Kategori terbesar'**
  String get sugTopCategory;

  /// No description provided for @sugBalance.
  ///
  /// In id, this message translates to:
  /// **'Saldo'**
  String get sugBalance;

  /// No description provided for @sugDeleteLast.
  ///
  /// In id, this message translates to:
  /// **'Hapus transaksi terakhir'**
  String get sugDeleteLast;

  /// No description provided for @asstTitle.
  ///
  /// In id, this message translates to:
  /// **'Asisten Dhuwitku'**
  String get asstTitle;

  /// No description provided for @asstSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Offline · data tetap di HP'**
  String get asstSubtitle;

  /// No description provided for @asstRestart.
  ///
  /// In id, this message translates to:
  /// **'Mulai ulang percakapan'**
  String get asstRestart;

  /// No description provided for @asstInputHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: kopi 25rb · saldo?'**
  String get asstInputHint;

  /// No description provided for @asstSend.
  ///
  /// In id, this message translates to:
  /// **'Kirim'**
  String get asstSend;

  /// No description provided for @asstUndone.
  ///
  /// In id, this message translates to:
  /// **'Dibatalkan'**
  String get asstUndone;

  /// No description provided for @undo.
  ///
  /// In id, this message translates to:
  /// **'Batalkan'**
  String get undo;

  /// No description provided for @asstDeleted.
  ///
  /// In id, this message translates to:
  /// **'Dihapus'**
  String get asstDeleted;

  /// No description provided for @asstNotDeletedShort.
  ///
  /// In id, this message translates to:
  /// **'Tidak jadi dihapus'**
  String get asstNotDeletedShort;

  /// No description provided for @previousAmount.
  ///
  /// In id, this message translates to:
  /// **'sebelumnya {amount}'**
  String previousAmount(String amount);

  /// No description provided for @mascotA11y.
  ///
  /// In id, this message translates to:
  /// **'Maskot Asisten Dhuwitku'**
  String get mascotA11y;

  /// No description provided for @typingA11y.
  ///
  /// In id, this message translates to:
  /// **'Asisten sedang mengetik'**
  String get typingA11y;

  /// No description provided for @rangeToday.
  ///
  /// In id, this message translates to:
  /// **'hari ini'**
  String get rangeToday;

  /// No description provided for @rangeYesterday.
  ///
  /// In id, this message translates to:
  /// **'kemarin'**
  String get rangeYesterday;

  /// No description provided for @rangeThisWeek.
  ///
  /// In id, this message translates to:
  /// **'minggu ini'**
  String get rangeThisWeek;

  /// No description provided for @rangeLastWeek.
  ///
  /// In id, this message translates to:
  /// **'minggu lalu'**
  String get rangeLastWeek;

  /// No description provided for @rangeThisMonth.
  ///
  /// In id, this message translates to:
  /// **'bulan ini'**
  String get rangeThisMonth;

  /// No description provided for @rangeLastMonth.
  ///
  /// In id, this message translates to:
  /// **'bulan lalu'**
  String get rangeLastMonth;

  /// No description provided for @rangeThisYear.
  ///
  /// In id, this message translates to:
  /// **'tahun ini'**
  String get rangeThisYear;

  /// No description provided for @rangeLastYear.
  ///
  /// In id, this message translates to:
  /// **'tahun lalu'**
  String get rangeLastYear;

  /// No description provided for @rangeLastNDays.
  ///
  /// In id, this message translates to:
  /// **'{count} hari terakhir'**
  String rangeLastNDays(int count);
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
      <String>['en', 'id', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
