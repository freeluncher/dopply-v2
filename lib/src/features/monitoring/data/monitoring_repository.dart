import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ble_repository.dart';

/// Provides a [MonitoringRepository] instance.
///
/// This provider is used to create a [MonitoringRepository] instance.
///
/// Usage:
/// ```dart
/// final monitoringRepository = ref.read(monitoringRepositoryProvider);
/// ```
final monitoringRepositoryProvider = Provider<MonitoringRepository>((ref) {
  return MonitoringRepository(BleRepository(), Supabase.instance.client);
});

class MonitoringRepository {
  final BleRepository bleRepository;

  MonitoringRepository(this.bleRepository, SupabaseClient supabase);

  // Expose stream for controller
  Stream<dynamic> get adapterStateStream => bleRepository.adapterStateStream;
}
