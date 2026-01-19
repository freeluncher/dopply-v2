// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dopply';

  @override
  String get appTagline => 'Advanced Fetal Monitoring';

  @override
  String get dashboardTitle => 'Dopply Dashboard';

  @override
  String get monitoringTitle => 'Fetal Monitoring';

  @override
  String get myHistory => 'My History';

  @override
  String get myPatients => 'My Patients';

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get notifications => 'Notifications';

  @override
  String get profile => 'Profile';

  @override
  String get requests => 'Requests';

  @override
  String get startRecording => 'Start Recording';

  @override
  String get stopRecording => 'Stop Recording';

  @override
  String get saveRecord => 'Save Record';

  @override
  String get connect => 'Connect';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get accept => 'Accept';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get skip => 'Skip';

  @override
  String get logout => 'Log Out';

  @override
  String get connectionStatus => 'Connection Status';

  @override
  String get connected => 'Connected to Monitor';

  @override
  String get disconnected => 'Device Disconnected';

  @override
  String get scanning => 'Scanning...';

  @override
  String get simulationMode => 'Using Simulation Mode';

  @override
  String get realDevice => 'Real Device Connected';

  @override
  String get dopplerMonitor => 'Doppler Monitor';

  @override
  String get bpmLabel => 'BPM';

  @override
  String statusLabel(String status) {
    return 'Status: $status';
  }

  @override
  String durationSeconds(int seconds) {
    return 'Duration: ${seconds}s';
  }

  @override
  String get requestPermissionToMonitor => 'Request Permission to Monitor';

  @override
  String get waitingForDoctorApproval => 'Waiting For Doctor Approval';

  @override
  String get requestSentToDoctor => 'A request has been sent to your doctor.';

  @override
  String get medicalDisclaimerTitle => 'Medical Disclaimer';

  @override
  String get medicalDisclaimerSubtitle => 'Important Information';

  @override
  String get medicalDisclaimerContent =>
      'This app is for screening purposes only and not a substitute for professional medical advice. Always consult a doctor.';

  @override
  String get disclaimerPoint1 => 'This device is a screening tool only';

  @override
  String get disclaimerPoint2 => 'Not FDA approved for medical diagnosis';

  @override
  String get disclaimerPoint3 =>
      'Always consult your doctor for medical advice';

  @override
  String get disclaimerPoint4 =>
      'Seek immediate help if you notice concerning symptoms';

  @override
  String get iUnderstand => 'I Understand';

  @override
  String get iUnderstandAndAccept => 'I Understand and Accept';

  @override
  String helloUser(String name) {
    return 'Hello, $name';
  }

  @override
  String roleLabel(String role) {
    return 'Role: $role';
  }

  @override
  String get profileIncomplete => 'Profile Incomplete';

  @override
  String get completeProfileMessage =>
      'You must complete your patient profile before you can use the application.';

  @override
  String get completeProfileNow => 'Complete Profile Now';

  @override
  String get assignedDoctor => 'Assigned Doctor';

  @override
  String get requestDoctorTransfer => 'Request Doctor Transfer';

  @override
  String get error => 'Error';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get errorLoadProfile => 'Failed to Load';

  @override
  String get errorNetwork => 'Network Error';

  @override
  String get errorBluetooth => 'Bluetooth Error';

  @override
  String get errorPermission => 'Permission Denied';

  @override
  String get connectionLost => 'Connection lost';

  @override
  String get tryAgain => 'Try again';

  @override
  String get checkConnection => 'Please check your internet connection';

  @override
  String get loading => 'Loading...';

  @override
  String get loadingProfile => 'Loading profile...';

  @override
  String get loadingData => 'Loading data...';

  @override
  String get connectingDevice => 'Connecting device...';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get noRecordsYet => 'No Records Yet';

  @override
  String get noRecordsMessage =>
      'Start your first monitoring session to see results here';

  @override
  String get startMonitoring => 'Start Monitoring';

  @override
  String get noPatientsYet => 'No Patients Yet';

  @override
  String get noPatientsMessage => 'Patients assigned to you will appear here';

  @override
  String get noNotifications => 'No Notifications';

  @override
  String get noNotificationsMessage => 'You\'re all caught up!';

  @override
  String get status => 'Status';

  @override
  String get duration => 'Duration';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get notes => 'Notes';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get settings => 'Settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get notificationsSettings => 'Notifications';

  @override
  String get manageNotificationSettings =>
      'Manage system notification settings';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get appVersion => 'App Version';

  @override
  String get diagnostics => 'Diagnostics';

  @override
  String get online => 'Online';

  @override
  String get offlineMode => 'Offline Mode';

  @override
  String get areYouSureLogout => 'Are you sure you want to log out?';

  @override
  String get account => 'Account';

  @override
  String get preferences => 'Preferences';

  @override
  String get legalAndAbout => 'Legal & About';

  @override
  String get myProfile => 'My Profile';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get fullName => 'Full Name';

  @override
  String get email => 'Email';

  @override
  String get role => 'Role';

  @override
  String get specialization => 'Specialization';

  @override
  String get specializationHint => 'e.g. Obstetrician';

  @override
  String get hpht => 'HPHT (Last Period)';

  @override
  String get address => 'Address';

  @override
  String get medicalNotes => 'Medical Notes';

  @override
  String get medicalNotesHint => 'Allergies, history, etc.';

  @override
  String get birthDate => 'Birth Date';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileUpdatedSuccessfully => 'Profile Updated Successfully';

  @override
  String get failedToLoadProfile => 'Failed to load profile';

  @override
  String get required => 'Required';

  @override
  String get fetalMonitoring => 'Fetal Monitoring';

  @override
  String get doctorAnalysis => 'Doctor Analysis';

  @override
  String get recordingInProgress => 'Recording in Progress';

  @override
  String get monitoringSession => 'Monitoring Session';

  @override
  String get createAccount => 'Create Account';

  @override
  String get register => 'Register';

  @override
  String get login => 'Login';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Register';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get completeProfile => 'Complete Profile';

  @override
  String get toStartMonitoring => 'To start monitoring, we need a few details.';

  @override
  String get saveProfile => 'Save Profile';

  @override
  String get password => 'Password';

  @override
  String get recordDetails => 'Record Details';

  @override
  String get newestFirst => 'Newest First';

  @override
  String get oldestFirst => 'Oldest First';

  @override
  String get bpmHighToLow => 'BPM (High to Low)';

  @override
  String get bpmLowToHigh => 'BPM (Low to High)';

  @override
  String get newMeasurement => 'New Measurement';

  @override
  String get averageBpm => 'Average BPM';

  @override
  String get failedToGeneratePdf => 'Failed to generate PDF';

  @override
  String get allMarkedAsRead => 'All marked as read';

  @override
  String get noNotificationsYet => 'No notifications';

  @override
  String get monitoringRequests => 'Monitoring Requests';

  @override
  String get requestDoctorTransferTitle => 'Request Doctor Transfer';

  @override
  String get addPatient => 'Add Patient';

  @override
  String get addPatientMessage =>
      'Enter the patient\'s email address to assign them.';

  @override
  String get add => 'Add';

  @override
  String get hphtLabel => 'HPHT';

  @override
  String get notAvailable => 'N/A';

  @override
  String get adminConsole => 'Admin Console';

  @override
  String get addNewUser => 'Add New User';

  @override
  String get editUser => 'Edit User';

  @override
  String get iAgreeAndContinue => 'I Agree & Continue';

  @override
  String get decline => 'Decline';

  @override
  String get youMustAcceptTerms => 'You must accept the Terms to use Dopply.';

  @override
  String get updateAvailable => 'Update Available';

  @override
  String updateAvailableVersion(String version) {
    return 'Update Available $version';
  }

  @override
  String get newVersionAvailable => 'A new version of Dopply is available.';

  @override
  String get downloadingUpdate => 'Downloading Update...';

  @override
  String get later => 'Later';

  @override
  String get updateNow => 'Update Now';

  @override
  String get permissionNotGranted => 'Permission not granted to install apk.';

  @override
  String languageChanged(String language) {
    return 'Language changed to $language';
  }

  @override
  String get pleaseManageNotifications =>
      'Please manage notifications in your Device Settings.';
}
