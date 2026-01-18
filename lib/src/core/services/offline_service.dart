import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final offlineServiceProvider = Provider<OfflineService>(
  (ref) => OfflineService(),
);

class OfflineService {
  late Box _cacheBox;
  late Box _queueBox;
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  Future<void> init() async {
    await Hive.initFlutter();
    _cacheBox = await Hive.openBox('app_cache');
    _queueBox = await Hive.openBox('sync_queue');

    // Check initial connection
    final results = await Connectivity().checkConnectivity();
    _isOnline = _hasConnection(results);

    // Listen to changes
    Connectivity().onConnectivityChanged.listen((results) {
      _isOnline = _hasConnection(results);
      if (_isOnline) {
        _processSyncQueue();
      }
    });

    if (_isOnline) {
      _processSyncQueue();
    }
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }

  // --- Caching (Read) ---

  Future<void> saveToCache(String key, dynamic data) async {
    await _cacheBox.put(key, jsonEncode(data));
  }

  dynamic getFromCache(String key) {
    final data = _cacheBox.get(key);
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  Future<void> clearCache() async {
    await _cacheBox.clear();
  }

  // --- Queue (Write) ---

  Future<void> addToQueue(
    String table,
    Map<String, dynamic> data, {
    String type = 'insert',
  }) async {
    final item = {
      'table': table,
      'data': data,
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _queueBox.add(item);
  }

  Future<void> _processSyncQueue() async {
    if (_queueBox.isEmpty) return;

    print(
      "OfflineService: Processing Sync Queue (${_queueBox.length} items)...",
    );

    final keysToDelete = <dynamic>[];

    for (var i = 0; i < _queueBox.length; i++) {
      final item = _queueBox.getAt(i) as Map;
      final table = item['table'];
      final data = Map<String, dynamic>.from(item['data']);
      final type = item['type'];

      try {
        if (type == 'insert') {
          await Supabase.instance.client.from(table).insert(data);
        } else if (type == 'update') {
          // Assuming 'id' is in data for updates
          final id = data['id'];
          if (id != null) {
            await Supabase.instance.client
                .from(table)
                .update(data)
                .eq('id', id);
          }
        }
        keysToDelete.add(_queueBox.keyAt(i));
      } catch (e) {
        print("OfflineService: Sync failed for item $i: $e");
        // Keep in queue to retry later? Or robust retry strategy?
        // For now, if it's a network error, we stop processing.
        // If it's a unique constraint or logical error, maybe delete?
        // Let's assume transient network errors are handled by isOnline check.
      }
    }

    // Delete processed items
    await _queueBox.deleteAll(keysToDelete);
    print("OfflineService: Processed ${keysToDelete.length} items.");
  }
}
