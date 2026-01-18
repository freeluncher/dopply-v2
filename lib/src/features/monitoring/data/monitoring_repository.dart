import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ble_repository.dart';

final monitoringRepositoryProvider = Provider<MonitoringRepository>((ref) {
  return MonitoringRepository(BleRepository(), Supabase.instance.client);
});

class MonitoringRepository {
  final BleRepository bleRepository;

  MonitoringRepository(this.bleRepository, SupabaseClient supabase);

  // Expose stream for controller
  Stream<dynamic> get adapterStateStream => bleRepository.adapterStateStream;
}
