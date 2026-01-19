// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Dopply';

  @override
  String get appTagline => 'Monitoring Janin Canggih';

  @override
  String get dashboardTitle => 'Dasbor Dopply';

  @override
  String get monitoringTitle => 'Monitoring Janin';

  @override
  String get myHistory => 'Riwayat Saya';

  @override
  String get myPatients => 'Pasien Saya';

  @override
  String get adminPanel => 'Panel Admin';

  @override
  String get notifications => 'Notifikasi';

  @override
  String get profile => 'Profil';

  @override
  String get requests => 'Permintaan';

  @override
  String get startRecording => 'Mulai Rekam';

  @override
  String get stopRecording => 'Stop Rekam';

  @override
  String get saveRecord => 'Simpan Rekaman';

  @override
  String get connect => 'Hubungkan';

  @override
  String get disconnect => 'Putuskan';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get cancel => 'Batal';

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get accept => 'Terima';

  @override
  String get dismiss => 'Tutup';

  @override
  String get skip => 'Lewati';

  @override
  String get logout => 'Keluar';

  @override
  String get connectionStatus => 'Status Koneksi';

  @override
  String get connected => 'Terhubung ke Monitor';

  @override
  String get disconnected => 'Perangkat Terputus';

  @override
  String get scanning => 'Mencari...';

  @override
  String get simulationMode => 'Menggunakan Mode Simulasi';

  @override
  String get realDevice => 'Perangkat Asli Terhubung';

  @override
  String get dopplerMonitor => 'Monitor Doppler';

  @override
  String get bpmLabel => 'DPM';

  @override
  String statusLabel(String status) {
    return 'Status: $status';
  }

  @override
  String durationSeconds(int seconds) {
    return 'Durasi: ${seconds}d';
  }

  @override
  String get requestPermissionToMonitor => 'Minta Izin untuk Monitoring';

  @override
  String get waitingForDoctorApproval => 'Menunggu Persetujuan Dokter';

  @override
  String get requestSentToDoctor => 'Permintaan telah dikirim ke dokter Anda.';

  @override
  String get medicalDisclaimerTitle => 'Penafian Medis';

  @override
  String get medicalDisclaimerSubtitle => 'Informasi Penting';

  @override
  String get medicalDisclaimerContent =>
      'Aplikasi ini hanya untuk tujuan skrining dan bukan pengganti saran medis profesional. Selalu konsultasikan dengan dokter.';

  @override
  String get disclaimerPoint1 => 'Perangkat ini hanya alat skrining';

  @override
  String get disclaimerPoint2 => 'Tidak disetujui FDA untuk diagnosis medis';

  @override
  String get disclaimerPoint3 =>
      'Selalu konsultasikan dengan dokter untuk saran medis';

  @override
  String get disclaimerPoint4 =>
      'Segera cari bantuan jika Anda melihat gejala yang mengkhawatirkan';

  @override
  String get iUnderstand => 'Saya Mengerti';

  @override
  String get iUnderstandAndAccept => 'Saya Mengerti dan Menerima';

  @override
  String helloUser(String name) {
    return 'Halo, $name';
  }

  @override
  String roleLabel(String role) {
    return 'Peran: $role';
  }

  @override
  String get profileIncomplete => 'Profil Belum Lengkap';

  @override
  String get completeProfileMessage =>
      'Anda harus melengkapi profil pasien sebelum dapat menggunakan aplikasi.';

  @override
  String get completeProfileNow => 'Lengkapi Profil Sekarang';

  @override
  String get assignedDoctor => 'Dokter yang Ditugaskan';

  @override
  String get requestDoctorTransfer => 'Minta Transfer Dokter';

  @override
  String get error => 'Error';

  @override
  String get errorOccurred => 'Terjadi kesalahan';

  @override
  String get errorLoadProfile => 'Gagal Memuat';

  @override
  String get errorNetwork => 'Error Jaringan';

  @override
  String get errorBluetooth => 'Error Bluetooth';

  @override
  String get errorPermission => 'Izin Ditolak';

  @override
  String get connectionLost => 'Koneksi terputus';

  @override
  String get tryAgain => 'Coba lagi';

  @override
  String get checkConnection => 'Silakan periksa koneksi internet Anda';

  @override
  String get loading => 'Memuat...';

  @override
  String get loadingProfile => 'Memuat profil...';

  @override
  String get loadingData => 'Memuat data...';

  @override
  String get connectingDevice => 'Menghubungkan perangkat...';

  @override
  String get pleaseWait => 'Mohon tunggu...';

  @override
  String get noRecordsYet => 'Belum Ada Rekaman';

  @override
  String get noRecordsMessage =>
      'Mulai sesi monitoring pertama Anda untuk melihat hasil di sini';

  @override
  String get startMonitoring => 'Mulai Monitoring';

  @override
  String get noPatientsYet => 'Belum Ada Pasien';

  @override
  String get noPatientsMessage =>
      'Pasien yang ditugaskan kepada Anda akan muncul di sini';

  @override
  String get noNotifications => 'Tidak Ada Notifikasi';

  @override
  String get noNotificationsMessage => 'Anda sudah mengecek semuanya!';

  @override
  String get status => 'Status';

  @override
  String get duration => 'Durasi';

  @override
  String get date => 'Tanggal';

  @override
  String get time => 'Waktu';

  @override
  String get notes => 'Catatan';

  @override
  String get save => 'Simpan';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Hapus';

  @override
  String get search => 'Cari';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Urutkan';
}
