import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

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
    Locale('id'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Dopply'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Advanced Fetal Monitoring'**
  String get appTagline;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dopply Dashboard'**
  String get dashboardTitle;

  /// No description provided for @monitoringTitle.
  ///
  /// In en, this message translates to:
  /// **'Fetal Monitoring'**
  String get monitoringTitle;

  /// No description provided for @myHistory.
  ///
  /// In en, this message translates to:
  /// **'My History'**
  String get myHistory;

  /// No description provided for @myPatients.
  ///
  /// In en, this message translates to:
  /// **'My Patients'**
  String get myPatients;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @startRecording.
  ///
  /// In en, this message translates to:
  /// **'Start Recording'**
  String get startRecording;

  /// No description provided for @stopRecording.
  ///
  /// In en, this message translates to:
  /// **'Stop Recording'**
  String get stopRecording;

  /// No description provided for @saveRecord.
  ///
  /// In en, this message translates to:
  /// **'Save Record'**
  String get saveRecord;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @connectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Connection Status'**
  String get connectionStatus;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected to Monitor'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Device Disconnected'**
  String get disconnected;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// No description provided for @simulationMode.
  ///
  /// In en, this message translates to:
  /// **'Using Simulation Mode'**
  String get simulationMode;

  /// No description provided for @realDevice.
  ///
  /// In en, this message translates to:
  /// **'Real Device Connected'**
  String get realDevice;

  /// No description provided for @dopplerMonitor.
  ///
  /// In en, this message translates to:
  /// **'Doppler Monitor'**
  String get dopplerMonitor;

  /// No description provided for @bpmLabel.
  ///
  /// In en, this message translates to:
  /// **'BPM'**
  String get bpmLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String statusLabel(String status);

  /// No description provided for @durationSeconds.
  ///
  /// In en, this message translates to:
  /// **'Duration: {seconds}s'**
  String durationSeconds(int seconds);

  /// No description provided for @requestPermissionToMonitor.
  ///
  /// In en, this message translates to:
  /// **'Request Permission to Monitor'**
  String get requestPermissionToMonitor;

  /// No description provided for @waitingForDoctorApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting For Doctor Approval'**
  String get waitingForDoctorApproval;

  /// No description provided for @requestSentToDoctor.
  ///
  /// In en, this message translates to:
  /// **'A request has been sent to your doctor.'**
  String get requestSentToDoctor;

  /// No description provided for @medicalDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical Disclaimer'**
  String get medicalDisclaimerTitle;

  /// No description provided for @medicalDisclaimerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Important Information'**
  String get medicalDisclaimerSubtitle;

  /// No description provided for @medicalDisclaimerContent.
  ///
  /// In en, this message translates to:
  /// **'This app is for screening purposes only and not a substitute for professional medical advice. Always consult a doctor.'**
  String get medicalDisclaimerContent;

  /// No description provided for @disclaimerPoint1.
  ///
  /// In en, this message translates to:
  /// **'This device is a screening tool only'**
  String get disclaimerPoint1;

  /// No description provided for @disclaimerPoint2.
  ///
  /// In en, this message translates to:
  /// **'Not FDA approved for medical diagnosis'**
  String get disclaimerPoint2;

  /// No description provided for @disclaimerPoint3.
  ///
  /// In en, this message translates to:
  /// **'Always consult your doctor for medical advice'**
  String get disclaimerPoint3;

  /// No description provided for @disclaimerPoint4.
  ///
  /// In en, this message translates to:
  /// **'Seek immediate help if you notice concerning symptoms'**
  String get disclaimerPoint4;

  /// No description provided for @iUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I Understand'**
  String get iUnderstand;

  /// No description provided for @iUnderstandAndAccept.
  ///
  /// In en, this message translates to:
  /// **'I Understand and Accept'**
  String get iUnderstandAndAccept;

  /// No description provided for @helloUser.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String helloUser(String name);

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role: {role}'**
  String roleLabel(String role);

  /// No description provided for @profileIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Profile Incomplete'**
  String get profileIncomplete;

  /// No description provided for @completeProfileMessage.
  ///
  /// In en, this message translates to:
  /// **'You must complete your patient profile before you can use the application.'**
  String get completeProfileMessage;

  /// No description provided for @completeProfileNow.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile Now'**
  String get completeProfileNow;

  /// No description provided for @assignedDoctor.
  ///
  /// In en, this message translates to:
  /// **'Assigned Doctor'**
  String get assignedDoctor;

  /// No description provided for @requestDoctorTransfer.
  ///
  /// In en, this message translates to:
  /// **'Request Doctor Transfer'**
  String get requestDoctorTransfer;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @errorLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to Load'**
  String get errorLoadProfile;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network Error'**
  String get errorNetwork;

  /// No description provided for @errorBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Error'**
  String get errorBluetooth;

  /// No description provided for @errorPermission.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get errorPermission;

  /// No description provided for @connectionLost.
  ///
  /// In en, this message translates to:
  /// **'Connection lost'**
  String get connectionLost;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection'**
  String get checkConnection;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @loadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Loading profile...'**
  String get loadingProfile;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loadingData;

  /// No description provided for @connectingDevice.
  ///
  /// In en, this message translates to:
  /// **'Connecting device...'**
  String get connectingDevice;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @noRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No Records Yet'**
  String get noRecordsYet;

  /// No description provided for @noRecordsMessage.
  ///
  /// In en, this message translates to:
  /// **'Start your first monitoring session to see results here'**
  String get noRecordsMessage;

  /// No description provided for @startMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Start Monitoring'**
  String get startMonitoring;

  /// No description provided for @noPatientsYet.
  ///
  /// In en, this message translates to:
  /// **'No Patients Yet'**
  String get noPatientsYet;

  /// No description provided for @noPatientsMessage.
  ///
  /// In en, this message translates to:
  /// **'Patients assigned to you will appear here'**
  String get noPatientsMessage;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No Notifications'**
  String get noNotifications;

  /// No description provided for @noNotificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get noNotificationsMessage;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

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

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;
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
      <String>['en', 'id'].contains(locale.languageCode);

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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
