import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Service for logging events and errors to a remote database.
///
/// This service provides a centralized way to log application events,
/// errors, and debugging information to a Supabase database table named
/// `monitor_logs`. It allows developers to track application behavior
/// and debug issues in production.
///
/// Usage:
/// ```dart
/// RemoteLogger.info('User logged in');
/// RemoteLogger.error('Failed to fetch data', error);
/// ```
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

  /// Logs an informational message.
  static void info(String message) => _instance.log('INFO', message);

  /// Logs an error message with optional error details.
  static void error(String message, [dynamic error]) =>
      _instance.log('ERROR', message, metadata: {'error': error.toString()});

  /// Logs a debugging message.
  static void debug(String message) => _instance.log('DEBUG', message);
}
