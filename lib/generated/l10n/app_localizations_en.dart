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
}
