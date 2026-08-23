import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('am'),
    Locale('en'),
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @managePersonalInformation.
  ///
  /// In en, this message translates to:
  /// **'Manage your personal information'**
  String get managePersonalInformation;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @passwordAndAccountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Password and account security'**
  String get passwordAndAccountSecurity;

  /// No description provided for @farm.
  ///
  /// In en, this message translates to:
  /// **'Farm'**
  String get farm;

  /// No description provided for @farmSettings.
  ///
  /// In en, this message translates to:
  /// **'Farm Settings'**
  String get farmSettings;

  /// No description provided for @manageFarmInformation.
  ///
  /// In en, this message translates to:
  /// **'Manage your farm information'**
  String get manageFarmInformation;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

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

  /// No description provided for @amharic.
  ///
  /// In en, this message translates to:
  /// **'Amharic'**
  String get amharic;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @manageNotifications.
  ///
  /// In en, this message translates to:
  /// **'Manage notifications'**
  String get manageNotifications;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @poultryFarmManagement.
  ///
  /// In en, this message translates to:
  /// **'Poultry Farm Management'**
  String get poultryFarmManagement;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @learnHowYourDataIsHandled.
  ///
  /// In en, this message translates to:
  /// **'Learn how your data is handled'**
  String get learnHowYourDataIsHandled;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'A poultry farm management application for managing farm operations, chickens, feed, finances, customers and more.'**
  String get aboutDescription;

  /// No description provided for @settingAvailableSoon.
  ///
  /// In en, this message translates to:
  /// **'This setting will be available soon.'**
  String get settingAvailableSoon;

  /// No description provided for @confirmSignOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get confirmSignOut;

  /// No description provided for @unableToSignOut.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign out'**
  String get unableToSignOut;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @finance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @poultryFarmManager.
  ///
  /// In en, this message translates to:
  /// **'Poultry Farm Manager'**
  String get poultryFarmManager;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @totalChickens.
  ///
  /// In en, this message translates to:
  /// **'Total Chickens'**
  String get totalChickens;

  /// No description provided for @manageFarmWithConfidence.
  ///
  /// In en, this message translates to:
  /// **'Manage your farm with confidence.'**
  String get manageFarmWithConfidence;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @signInToFarmAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your farm account'**
  String get signInToFarmAccount;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @googleLoginNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Google login is not configured yet'**
  String get googleLoginNotConfigured;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @alreadyhaveanaccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an Account'**
  String get alreadyhaveanaccount;

  /// No description provided for @registerToFarmAccount.
  ///
  /// In en, this message translates to:
  /// **'Register to your farm account'**
  String get registerToFarmAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterYourFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterYourFullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccessful;

  /// No description provided for @enterEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address first'**
  String get enterEmailFirst;

  /// No description provided for @passwordResetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent'**
  String get passwordResetLinkSent;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @accountCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get accountCreatedSuccessfully;

  /// No description provided for @todaysOverview.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Overview'**
  String get todaysOverview;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @feedRemaining.
  ///
  /// In en, this message translates to:
  /// **'Feed Remaining'**
  String get feedRemaining;

  /// No description provided for @incomeToday.
  ///
  /// In en, this message translates to:
  /// **'Income Today'**
  String get incomeToday;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @eggInventory.
  ///
  /// In en, this message translates to:
  /// **'Egg Inventory'**
  String get eggInventory;

  /// No description provided for @expensesToday.
  ///
  /// In en, this message translates to:
  /// **'Expenses Today'**
  String get expensesToday;

  /// No description provided for @recordProduction.
  ///
  /// In en, this message translates to:
  /// **'Record Production'**
  String get recordProduction;

  /// No description provided for @recordSale.
  ///
  /// In en, this message translates to:
  /// **'Record Sale'**
  String get recordSale;

  /// No description provided for @addFeed.
  ///
  /// In en, this message translates to:
  /// **'Add Feed'**
  String get addFeed;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @retryLoadingDashboard.
  ///
  /// In en, this message translates to:
  /// **'Retry loading dashboard'**
  String get retryLoadingDashboard;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity yet.'**
  String get noRecentActivity;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @recoverFarmAccount.
  ///
  /// In en, this message translates to:
  /// **'Recover your farm account'**
  String get recoverFarmAccount;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @rememberedPassword.
  ///
  /// In en, this message translates to:
  /// **'Remembered your password?'**
  String get rememberedPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @setSecureNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set a secure new password'**
  String get setSecureNewPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @passwordMustBeSixCharacters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordMustBeSixCharacters;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully.'**
  String get passwordUpdatedSuccessfully;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get pleaseEnterEmail;

  /// No description provided for @passwordResetLinkSentToEmail.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email'**
  String get passwordResetLinkSentToEmail;

  /// No description provided for @feedManagement.
  ///
  /// In en, this message translates to:
  /// **'Feed Management'**
  String get feedManagement;

  /// No description provided for @addFeedTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Feed'**
  String get addFeedTitle;

  /// No description provided for @feedName.
  ///
  /// In en, this message translates to:
  /// **'Feed Name'**
  String get feedName;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @feedAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Feed added successfully.'**
  String get feedAddedSuccessfully;

  /// No description provided for @enterValidFeed.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid feed name and quantity.'**
  String get enterValidFeed;

  /// No description provided for @noFeedRecords.
  ///
  /// In en, this message translates to:
  /// **'No feed records yet.'**
  String get noFeedRecords;

  /// No description provided for @totalFeedStock.
  ///
  /// In en, this message translates to:
  /// **'Total Feed Stock'**
  String get totalFeedStock;

  /// No description provided for @feedInventory.
  ///
  /// In en, this message translates to:
  /// **'Feed Inventory'**
  String get feedInventory;

  /// No description provided for @unableToLoadFeed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load feed'**
  String get unableToLoadFeed;

  /// No description provided for @unableToAddFeed.
  ///
  /// In en, this message translates to:
  /// **'Unable to add feed'**
  String get unableToAddFeed;

  /// No description provided for @eggInventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Egg Inventory'**
  String get eggInventoryTitle;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @soldThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Sold This Week'**
  String get soldThisWeek;

  /// No description provided for @damaged.
  ///
  /// In en, this message translates to:
  /// **'Damaged'**
  String get damaged;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @inventoryBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Inventory Breakdown'**
  String get inventoryBreakdown;

  /// No description provided for @availableEggs.
  ///
  /// In en, this message translates to:
  /// **'Available Eggs'**
  String get availableEggs;

  /// No description provided for @collected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get collected;

  /// No description provided for @crackedDamaged.
  ///
  /// In en, this message translates to:
  /// **'Cracked / Damaged'**
  String get crackedDamaged;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @noRecentTransactions.
  ///
  /// In en, this message translates to:
  /// **'No recent transactions'**
  String get noRecentTransactions;

  /// No description provided for @dailyProduction.
  ///
  /// In en, this message translates to:
  /// **'Daily Production'**
  String get dailyProduction;

  /// No description provided for @eggs.
  ///
  /// In en, this message translates to:
  /// **'eggs'**
  String get eggs;

  /// No description provided for @unableToLoadEggInventory.
  ///
  /// In en, this message translates to:
  /// **'Unable to load egg inventory'**
  String get unableToLoadEggInventory;

  /// No description provided for @medicineName.
  ///
  /// In en, this message translates to:
  /// **'Medicine Name'**
  String get medicineName;

  /// No description provided for @addMedicine.
  ///
  /// In en, this message translates to:
  /// **'Add Medicine'**
  String get addMedicine;

  /// No description provided for @editMedicine.
  ///
  /// In en, this message translates to:
  /// **'Edit Medicine'**
  String get editMedicine;

  /// No description provided for @purchaseCost.
  ///
  /// In en, this message translates to:
  /// **'Purchase Cost (ETB)'**
  String get purchaseCost;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @removeExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Remove expiry date'**
  String get removeExpiryDate;

  /// No description provided for @pleaseEnterMedicineName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a medicine name.'**
  String get pleaseEnterMedicineName;

  /// No description provided for @quantityCannotBeNegative.
  ///
  /// In en, this message translates to:
  /// **'Quantity cannot be negative.'**
  String get quantityCannotBeNegative;

  /// No description provided for @purchaseCostCannotBeNegative.
  ///
  /// In en, this message translates to:
  /// **'Purchase cost cannot be negative.'**
  String get purchaseCostCannotBeNegative;

  /// No description provided for @deleteMedicine.
  ///
  /// In en, this message translates to:
  /// **'Delete Medicine'**
  String get deleteMedicine;

  /// No description provided for @confirmDeleteMedicine.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this medicine?'**
  String get confirmDeleteMedicine;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @vaccination.
  ///
  /// In en, this message translates to:
  /// **'Vaccination'**
  String get vaccination;

  /// No description provided for @recordVaccination.
  ///
  /// In en, this message translates to:
  /// **'Record Vaccination'**
  String get recordVaccination;

  /// No description provided for @editVaccination.
  ///
  /// In en, this message translates to:
  /// **'Edit Vaccination'**
  String get editVaccination;

  /// No description provided for @chickenBatch.
  ///
  /// In en, this message translates to:
  /// **'Chicken Batch'**
  String get chickenBatch;

  /// No description provided for @medicineVaccine.
  ///
  /// In en, this message translates to:
  /// **'Medicine / Vaccine'**
  String get medicineVaccine;

  /// No description provided for @noMedicineSelected.
  ///
  /// In en, this message translates to:
  /// **'No medicine selected'**
  String get noMedicineSelected;

  /// No description provided for @vaccinationDate.
  ///
  /// In en, this message translates to:
  /// **'Vaccination Date'**
  String get vaccinationDate;

  /// No description provided for @nextDueDate.
  ///
  /// In en, this message translates to:
  /// **'Next Due Date'**
  String get nextDueDate;

  /// No description provided for @removeDueDate.
  ///
  /// In en, this message translates to:
  /// **'Remove due date'**
  String get removeDueDate;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @addVaccinationNotes.
  ///
  /// In en, this message translates to:
  /// **'Add vaccination notes...'**
  String get addVaccinationNotes;

  /// No description provided for @pleaseSelectChickenBatch.
  ///
  /// In en, this message translates to:
  /// **'Please select a chicken batch.'**
  String get pleaseSelectChickenBatch;

  /// No description provided for @deleteVaccination.
  ///
  /// In en, this message translates to:
  /// **'Delete Vaccination'**
  String get deleteVaccination;

  /// No description provided for @confirmDeleteVaccination.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this vaccination record?'**
  String get confirmDeleteVaccination;

  /// No description provided for @recentRecords.
  ///
  /// In en, this message translates to:
  /// **'Recent Records'**
  String get recentRecords;

  /// No description provided for @recordTodaysProduction.
  ///
  /// In en, this message translates to:
  /// **'Record Today\'s Production'**
  String get recordTodaysProduction;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @batch.
  ///
  /// In en, this message translates to:
  /// **'Batch'**
  String get batch;

  /// No description provided for @eggsCollected.
  ///
  /// In en, this message translates to:
  /// **'Eggs Collected'**
  String get eggsCollected;

  /// No description provided for @brokenEggs.
  ///
  /// In en, this message translates to:
  /// **'Broken Eggs'**
  String get brokenEggs;

  /// No description provided for @selectBatch.
  ///
  /// In en, this message translates to:
  /// **'Select batch'**
  String get selectBatch;

  /// No description provided for @unnamedBatch.
  ///
  /// In en, this message translates to:
  /// **'Unnamed batch'**
  String get unnamedBatch;

  /// No description provided for @enterPositiveEggs.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive number of collected eggs.'**
  String get enterPositiveEggs;

  /// No description provided for @checkBrokenEggs.
  ///
  /// In en, this message translates to:
  /// **'Check the broken eggs and mortality values.'**
  String get checkBrokenEggs;

  /// No description provided for @productionRecordSaved.
  ///
  /// In en, this message translates to:
  /// **'Production record saved.'**
  String get productionRecordSaved;

  /// No description provided for @chickenBatches.
  ///
  /// In en, this message translates to:
  /// **'Chicken Batches'**
  String get chickenBatches;

  /// No description provided for @deleteBatch.
  ///
  /// In en, this message translates to:
  /// **'Delete Batch'**
  String get deleteBatch;

  /// No description provided for @confirmDeleteBatch.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this batch?'**
  String get confirmDeleteBatch;

  /// No description provided for @unableToLoadChickenBatches.
  ///
  /// In en, this message translates to:
  /// **'Unable to load chicken batches.'**
  String get unableToLoadChickenBatches;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noChickenBatches.
  ///
  /// In en, this message translates to:
  /// **'No chicken batches yet'**
  String get noChickenBatches;

  /// No description provided for @tapToCreateBatch.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create your first batch.'**
  String get tapToCreateBatch;

  /// No description provided for @birds.
  ///
  /// In en, this message translates to:
  /// **'Birds'**
  String get birds;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @weeks.
  ///
  /// In en, this message translates to:
  /// **'weeks'**
  String get weeks;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @mortalityCount.
  ///
  /// In en, this message translates to:
  /// **'Mortality Count'**
  String get mortalityCount;

  /// No description provided for @mortalityCountValue.
  ///
  /// In en, this message translates to:
  /// **'Deaths: {count}'**
  String mortalityCountValue(Object count);

  /// No description provided for @financialReport.
  ///
  /// In en, this message translates to:
  /// **'Financial Report'**
  String get financialReport;

  /// No description provided for @productionReport.
  ///
  /// In en, this message translates to:
  /// **'Production Report'**
  String get productionReport;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @unableToSaveBatch.
  ///
  /// In en, this message translates to:
  /// **'Unable to save batch: {error}'**
  String unableToSaveBatch(Object error);

  /// No description provided for @batchAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Batch added successfully'**
  String get batchAddedSuccessfully;

  /// No description provided for @batchUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Batch updated successfully'**
  String get batchUpdatedSuccessfully;

  /// No description provided for @addChickenBatch.
  ///
  /// In en, this message translates to:
  /// **'Add Chicken Batch'**
  String get addChickenBatch;

  /// No description provided for @editChickenBatch.
  ///
  /// In en, this message translates to:
  /// **'Edit Chicken Batch'**
  String get editChickenBatch;

  /// No description provided for @batchName.
  ///
  /// In en, this message translates to:
  /// **'Batch Name'**
  String get batchName;

  /// No description provided for @batchNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Batch Alpha'**
  String get batchNameHint;

  /// No description provided for @breed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get breed;

  /// No description provided for @breedHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Rhode Island Red'**
  String get breedHint;

  /// No description provided for @birdCount.
  ///
  /// In en, this message translates to:
  /// **'Bird Count'**
  String get birdCount;

  /// No description provided for @ageWeeks.
  ///
  /// In en, this message translates to:
  /// **'Age (Weeks)'**
  String get ageWeeks;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @selectStatus.
  ///
  /// In en, this message translates to:
  /// **'Select status'**
  String get selectStatus;

  /// No description provided for @saveChickenBatch.
  ///
  /// In en, this message translates to:
  /// **'Save Chicken Batch'**
  String get saveChickenBatch;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @totalBirds.
  ///
  /// In en, this message translates to:
  /// **'Total birds'**
  String get totalBirds;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @enterPositiveCount.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive count'**
  String get enterPositiveCount;

  /// No description provided for @enterValidAge.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid age'**
  String get enterValidAge;

  /// No description provided for @birdsCount.
  ///
  /// In en, this message translates to:
  /// **'Birds: {count}'**
  String birdsCount(Object count);

  /// No description provided for @ageInWeeks.
  ///
  /// In en, this message translates to:
  /// **'Age: {count} weeks'**
  String ageInWeeks(Object count);

  /// No description provided for @farmManagement.
  ///
  /// In en, this message translates to:
  /// **'Farm Management'**
  String get farmManagement;

  /// No description provided for @unableToLoadFarmInformation.
  ///
  /// In en, this message translates to:
  /// **'Unable to load farm information.\n{error}'**
  String unableToLoadFarmInformation(Object error);

  /// No description provided for @farmOverview.
  ///
  /// In en, this message translates to:
  /// **'Farm Overview'**
  String get farmOverview;

  /// No description provided for @activeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String activeCount(Object count);

  /// No description provided for @eggsToday.
  ///
  /// In en, this message translates to:
  /// **'{count} eggs today'**
  String eggsToday(Object count);

  /// No description provided for @availableCount.
  ///
  /// In en, this message translates to:
  /// **'{count} available'**
  String availableCount(Object count);

  /// No description provided for @kgStock.
  ///
  /// In en, this message translates to:
  /// **'{count} kg stock'**
  String kgStock(Object count);

  /// No description provided for @recordsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} records'**
  String recordsCount(Object count);

  /// No description provided for @totalBirdsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Birds'**
  String get totalBirdsLabel;

  /// No description provided for @activeBatches.
  ///
  /// In en, this message translates to:
  /// **'Active Batches'**
  String get activeBatches;

  /// No description provided for @mortalityRate.
  ///
  /// In en, this message translates to:
  /// **'Mortality Rate'**
  String get mortalityRate;

  /// No description provided for @incomeRecordedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Income recorded successfully.'**
  String get incomeRecordedSuccessfully;

  /// No description provided for @expenseRecordedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Expense recorded successfully.'**
  String get expenseRecordedSuccessfully;

  /// No description provided for @unableToSaveRecord.
  ///
  /// In en, this message translates to:
  /// **'Unable to save record: {error}'**
  String unableToSaveRecord(Object error);

  /// No description provided for @unableToLoadFinanceData.
  ///
  /// In en, this message translates to:
  /// **'Unable to load finance data.'**
  String get unableToLoadFinanceData;

  /// No description provided for @recordIncome.
  ///
  /// In en, this message translates to:
  /// **'Record Income'**
  String get recordIncome;

  /// No description provided for @recordExpense.
  ///
  /// In en, this message translates to:
  /// **'Record Expense'**
  String get recordExpense;

  /// No description provided for @incomeRecords.
  ///
  /// In en, this message translates to:
  /// **'Income Records'**
  String get incomeRecords;

  /// No description provided for @expenseRecords.
  ///
  /// In en, this message translates to:
  /// **'Expense Records'**
  String get expenseRecords;

  /// No description provided for @noRecordsFound.
  ///
  /// In en, this message translates to:
  /// **'No records found.'**
  String get noRecordsFound;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @productHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Eggs, Chicken'**
  String get productHint;

  /// No description provided for @categoryHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Feed, Labour'**
  String get categoryHint;

  /// No description provided for @amountEur.
  ///
  /// In en, this message translates to:
  /// **'Amount (ETB)'**
  String get amountEur;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount.'**
  String get enterValidAmount;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @netProfit.
  ///
  /// In en, this message translates to:
  /// **'Net Profit'**
  String get netProfit;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @incomeExpense.
  ///
  /// In en, this message translates to:
  /// **'Income vs Expenses'**
  String get incomeExpense;

  /// No description provided for @revenueBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Revenue Breakdown'**
  String get revenueBreakdown;

  /// No description provided for @unableToLoadProduction.
  ///
  /// In en, this message translates to:
  /// **'Unable to load production records: {error}'**
  String unableToLoadProduction(Object error);

  /// No description provided for @saveProductionRecord.
  ///
  /// In en, this message translates to:
  /// **'Save Production Record'**
  String get saveProductionRecord;

  /// No description provided for @productionNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add any observations...'**
  String get productionNotesHint;

  /// No description provided for @noProductionRecords.
  ///
  /// In en, this message translates to:
  /// **'No production records yet.'**
  String get noProductionRecords;

  /// No description provided for @brokenCount.
  ///
  /// In en, this message translates to:
  /// **'Broken: {count}'**
  String brokenCount(Object count);

  /// No description provided for @unableToLoadMedicines.
  ///
  /// In en, this message translates to:
  /// **'Unable to load medicines: {error}'**
  String unableToLoadMedicines(Object error);

  /// No description provided for @mustBeSignedIn.
  ///
  /// In en, this message translates to:
  /// **'You must be signed in.'**
  String get mustBeSignedIn;

  /// No description provided for @noFarmConnected.
  ///
  /// In en, this message translates to:
  /// **'No farm is connected to this account.'**
  String get noFarmConnected;

  /// No description provided for @medicineHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Amoxicillin'**
  String get medicineHint;

  /// No description provided for @quantityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 20'**
  String get quantityHint;

  /// No description provided for @costHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 500'**
  String get costHint;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @unableToSaveMedicine.
  ///
  /// In en, this message translates to:
  /// **'Unable to save medicine: {error}'**
  String unableToSaveMedicine(Object error);

  /// No description provided for @confirmDeleteNamedMedicine.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String confirmDeleteNamedMedicine(Object name);

  /// No description provided for @unableToDeleteMedicine.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete medicine: {error}'**
  String unableToDeleteMedicine(Object error);

  /// No description provided for @medicines.
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get medicines;

  /// No description provided for @noMedicinesRecorded.
  ///
  /// In en, this message translates to:
  /// **'No medicines recorded yet.'**
  String get noMedicinesRecorded;

  /// No description provided for @addMedicinesDescription.
  ///
  /// In en, this message translates to:
  /// **'Add medicines to keep track of your farm inventory.'**
  String get addMedicinesDescription;

  /// No description provided for @medicineInventory.
  ///
  /// In en, this message translates to:
  /// **'Medicine Inventory'**
  String get medicineInventory;

  /// No description provided for @medicineOverview.
  ///
  /// In en, this message translates to:
  /// **'Medicine Overview'**
  String get medicineOverview;

  /// No description provided for @types.
  ///
  /// In en, this message translates to:
  /// **'Types'**
  String get types;

  /// No description provided for @totalUnits.
  ///
  /// In en, this message translates to:
  /// **'Total Units'**
  String get totalUnits;

  /// No description provided for @expiring.
  ///
  /// In en, this message translates to:
  /// **'Expiring'**
  String get expiring;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @quantityCount.
  ///
  /// In en, this message translates to:
  /// **'Quantity: {count}'**
  String quantityCount(Object count);

  /// No description provided for @expiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get expiry;

  /// No description provided for @medicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get medicine;

  /// No description provided for @medicineExpired.
  ///
  /// In en, this message translates to:
  /// **'This medicine has expired.'**
  String get medicineExpired;

  /// No description provided for @medicineExpiresSoon.
  ///
  /// In en, this message translates to:
  /// **'This medicine expires within 30 days.'**
  String get medicineExpiresSoon;

  /// No description provided for @unableToLoadVaccinations.
  ///
  /// In en, this message translates to:
  /// **'Unable to load vaccinations: {error}'**
  String unableToLoadVaccinations(Object error);

  /// No description provided for @noMedicine.
  ///
  /// In en, this message translates to:
  /// **'No medicine'**
  String get noMedicine;

  /// No description provided for @vaccinations.
  ///
  /// In en, this message translates to:
  /// **'Vaccinations'**
  String get vaccinations;

  /// No description provided for @noVaccinationsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No vaccinations recorded yet.'**
  String get noVaccinationsRecorded;

  /// No description provided for @vaccinationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Record vaccinations to keep track of your flock.'**
  String get vaccinationsDescription;

  /// No description provided for @vaccinationRecords.
  ///
  /// In en, this message translates to:
  /// **'Vaccination Records'**
  String get vaccinationRecords;

  /// No description provided for @vaccinationOverview.
  ///
  /// In en, this message translates to:
  /// **'Vaccination Overview'**
  String get vaccinationOverview;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get records;

  /// No description provided for @dueSoon.
  ///
  /// In en, this message translates to:
  /// **'Due Soon'**
  String get dueSoon;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @batches.
  ///
  /// In en, this message translates to:
  /// **'Batches'**
  String get batches;

  /// No description provided for @unknownBatch.
  ///
  /// In en, this message translates to:
  /// **'Unknown batch'**
  String get unknownBatch;

  /// No description provided for @vaccinated.
  ///
  /// In en, this message translates to:
  /// **'Vaccinated'**
  String get vaccinated;

  /// No description provided for @vaccinationOverdue.
  ///
  /// In en, this message translates to:
  /// **'This vaccination is overdue.'**
  String get vaccinationOverdue;

  /// No description provided for @vaccinationDueSoon.
  ///
  /// In en, this message translates to:
  /// **'Vaccination is due within 30 days.'**
  String get vaccinationDueSoon;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @eggProduction.
  ///
  /// In en, this message translates to:
  /// **'Egg Production'**
  String get eggProduction;

  /// No description provided for @noRevenueData.
  ///
  /// In en, this message translates to:
  /// **'No revenue data yet.'**
  String get noRevenueData;

  /// No description provided for @noProductionData.
  ///
  /// In en, this message translates to:
  /// **'No production data available yet.'**
  String get noProductionData;

  /// No description provided for @lastSevenDays.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get lastSevenDays;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @dailyProductionRecordsHint.
  ///
  /// In en, this message translates to:
  /// **'Daily production records will appear here.'**
  String get dailyProductionRecordsHint;

  /// No description provided for @damagedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} damaged'**
  String damagedCount(Object count);

  /// No description provided for @yourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get yourProfile;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhoneNumber;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully.'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @unableToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile: {error}'**
  String unableToLoadProfile(Object error);

  /// No description provided for @unableToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Unable to update profile: {error}'**
  String unableToUpdateProfile(Object error);

  /// No description provided for @accountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account Security'**
  String get accountSecurity;

  /// No description provided for @strongPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Keep your account secure by using a strong password.'**
  String get strongPasswordHint;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password'**
  String get enterNewPassword;

  /// No description provided for @enterPasswordAgain.
  ///
  /// In en, this message translates to:
  /// **'Enter the password again'**
  String get enterPasswordAgain;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password.'**
  String get pleaseEnterNewPassword;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get passwordChangedSuccessfully;

  /// No description provided for @unableToChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Unable to change password: {error}'**
  String unableToChangePassword(Object error);

  /// No description provided for @farmInformation.
  ///
  /// In en, this message translates to:
  /// **'Farm Information'**
  String get farmInformation;

  /// No description provided for @farmName.
  ///
  /// In en, this message translates to:
  /// **'Farm Name'**
  String get farmName;

  /// No description provided for @ownerName.
  ///
  /// In en, this message translates to:
  /// **'Owner Name'**
  String get ownerName;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @farmInformationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Farm information is not available.'**
  String get farmInformationUnavailable;

  /// No description provided for @farmInformationUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Farm information updated successfully.'**
  String get farmInformationUpdatedSuccessfully;

  /// No description provided for @unableToSaveFarm.
  ///
  /// In en, this message translates to:
  /// **'Unable to save farm: {error}'**
  String unableToSaveFarm(Object error);

  /// No description provided for @birdMortalityRate.
  ///
  /// In en, this message translates to:
  /// **'Bird Mortality Rate'**
  String get birdMortalityRate;

  /// No description provided for @openDetailedRecords.
  ///
  /// In en, this message translates to:
  /// **'Open detailed records'**
  String get openDetailedRecords;
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
      <String>['am', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
