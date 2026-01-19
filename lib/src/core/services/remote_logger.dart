import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class RemoteLogger {
  static final RemoteLogger _instance = RemoteLogger._internal();
  factory RemoteLogger() => _instance;
  RemoteLogger._internal();

  SupabaseClient get _supabase => Supabase.instance.client;

  Future<void> log(
    String level,
    String message, {
    Map<String, dynamic>? metadata,
  }) async {
    // Only log in release mode or if explicitly requested
    // For now we log everything to help debug
    try {
      final user = _supabase.auth.currentUser;
      await _supabase.from('monitor_logs').insert({
        'level': level,
        'message': message,
        'metadata': metadata,
        'user_id': user?.id,
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (kDebugMode) {
        print("[RemoteLogger] $level: $message");
      }
    } catch (e) {
      if (kDebugMode) {
        print("[RemoteLogger] Failed to log: $e");
      }
    }
  }

  static void info(String message) => _instance.log('INFO', message);
  static void error(String message, [dynamic error]) =>
      _instance.log('ERROR', message, metadata: {'error': error.toString()});
  static void debug(String message) => _instance.log('DEBUG', message);
}
