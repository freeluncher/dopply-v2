import 'dart:async';
import 'dart:math';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dopply_v2/src/core/utils/bpm_classifier.dart';
import '../../../core/services/offline_service.dart';
import '../data/monitoring_repository.dart';
import 'monitoring_state.dart';

final monitoringControllerProvider =
    StateNotifierProvider.family<MonitoringController, MonitoringState, int?>((
      ref,
      patientId,
    ) {
      final repository = ref.watch(monitoringRepositoryProvider);
      final offlineService = ref.watch(offlineServiceProvider);
      return MonitoringController(repository, offlineService, patientId);
    });

class MonitoringController extends StateNotifier<MonitoringState> {
  final MonitoringRepository _repository;
  final OfflineService _offlineService;
  final int? _patientId;

  Timer? _timer;
  final Random _random = Random();
  DateTime? _startTime;
  StreamSubscription? _bpmSubscription;
  StreamSubscription? _connectionStateSubscription;
  StreamSubscription? _adapterStateSubscription;

  MonitoringController(this._repository, this._offlineService, this._patientId)
    : super(const MonitoringState()) {
    // Listen to Adapter State
    _adapterStateSubscription = _repository.bleRepository.adapterStateStream
        .listen((state) {
          if (state == BluetoothAdapterState.off) {
            if (mounted &&
                this.state.connectionStatus ==
                    DeviceConnectionStatus.connected) {
              this.state = this.state.copyWith(
                connectionStatus: DeviceConnectionStatus.disconnected,
                errorMessage: "Bluetooth adapter turned off.",
              );
            }
          }
        });

    // Listen to Auth Changes (Fix for Realtime Token Expiry)
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed ||
          event == AuthChangeEvent.initialSession) {
        _initPermission();
      }
    });

    _initPermission();
  }

  StreamSubscription? _authSubscription;

  // PERMISSION LOGIC
  StreamSubscription? _requestsSubscription;

  Future<void> _initPermission() async {
    if (_patientId != null) {
      // Doctor mode: Always Granted
      state = state.copyWith(permissionStatus: PermissionStatus.granted);
      return;
    }

    try {
      state = state.copyWith(permissionStatus: PermissionStatus.loading);
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Get Patient ID
      final patient = await Supabase.instance.client
          .from('patients')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (patient == null) {
        state = state.copyWith(permissionStatus: PermissionStatus.none);
        return;
      }

      final patientId = patient['id'];

      // Setup Realtime Subscription
      _requestsSubscription?.cancel();
      _requestsSubscription = Supabase.instance.client
          .from('monitoring_requests')
          .stream(primaryKey: ['id'])
          .eq('patient_id', patientId)
          .order('created_at', ascending: false)
          .limit(1)
          .listen(
            (List<Map<String, dynamic>> data) {
              if (!mounted) return;

              if (data.isEmpty) {
                state = state.copyWith(permissionStatus: PermissionStatus.none);
                return;
              }

              final latestRequest = data.first;
              final status = latestRequest['status'];

              if (status == 'approved') {
                state = state.copyWith(
                  permissionStatus: PermissionStatus.granted,
                );
              } else if (status == 'pending') {
                state = state.copyWith(
                  permissionStatus: PermissionStatus.pending,
                );
              } else {
                // rejected or completed
                state = state.copyWith(permissionStatus: PermissionStatus.none);
              }
            },
            onError: (err) {
              if (mounted) {
                state = state.copyWith(errorMessage: 'Realtime Error: $err');
              }
            },
          );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error checking permission: $e');
    }
  }

  Future<void> requestPermission() async {
    try {
      state = state.copyWith(permissionStatus: PermissionStatus.loading);
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final patient = await Supabase.instance.client
          .from('patients')
          .select('id')
          .eq('user_id', user.id)
          .single();

      final patientId = patient['id'];

      // Find assigned doctor
      final assignment = await Supabase.instance.client
          .from('doctor_patient')
          .select('doctor_id')
          .eq('patient_id', patientId)
          .maybeSingle();

      if (assignment == null) {
        state = state.copyWith(
          errorMessage: "No doctor assigned. Cannot request permission.",
          permissionStatus: PermissionStatus.none,
        );
        return;
      }

      // Create Request
      await Supabase.instance.client.from('monitoring_requests').insert({
        'patient_id': patientId,
        'doctor_id': assignment['doctor_id'],
        'status': 'pending',
      });

      // Notify Doctor
      await Supabase.instance.client.from('notifications').insert({
        'recipient_id': assignment['doctor_id'],
        'sender_id': user.id,
        'title': 'Monitoring Request',
        'message': 'Patient has requested to start monitoring.',
      });

      state = state.copyWith(permissionStatus: PermissionStatus.pending);
    } catch (e) {
      state = state.copyWith(
        errorMessage: "Failed to request: $e",
        permissionStatus: PermissionStatus.none,
      );
    }
  }

  Future<void> connectToDevice() async {
    if (!mounted) return;

    try {
      state = state.copyWith(
        connectionStatus: DeviceConnectionStatus.scanning,
        errorMessage: null,
      );
      await _repository.bleRepository.init();
      await _repository.bleRepository.scanAndConnect();

      if (!mounted) return;
      state = state.copyWith(
        connectionStatus: DeviceConnectionStatus.connected,
        isSimulation: false,
      );

      _connectionStateSubscription?.cancel();
      _connectionStateSubscription = _repository
          .bleRepository
          .connectionStateStream
          .listen((event) {
            if (!mounted) return;
            if (event == BluetoothConnectionState.connected) {
              state = state.copyWith(
                connectionStatus: DeviceConnectionStatus.connected,
              );
            } else if (event == BluetoothConnectionState.disconnected) {
              state = state.copyWith(
                connectionStatus: DeviceConnectionStatus.disconnected,
                errorMessage: "Device disconnected",
              );
            }
          });

      _bpmSubscription?.cancel();
      _bpmSubscription = _repository.bleRepository.bpmStream.listen((bpm) {
        if (state.status == MonitoringStatus.monitoring) {
          _handleNewBpm(bpm);
        }
      });
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        connectionStatus: DeviceConnectionStatus.disconnected,
        errorMessage: "BLE Error: $e",
        isSimulation: true,
      );
    }
  }

  void startMonitoring() {
    if (!mounted) return;

    // Check permission again just in case
    if (state.permissionStatus != PermissionStatus.granted) {
      state = state.copyWith(errorMessage: "Permission required to monitor.");
      return;
    }

    state = state.copyWith(
      status: MonitoringStatus.monitoring,
      bpmData: [],
      durationSeconds: 0,
      errorMessage: null,
    );
    _startTime = DateTime.now();

    if (state.isSimulation) {
      _startSimulationTimer();
    } else {
      if (state.connectionStatus != DeviceConnectionStatus.connected) {
        state = state.copyWith(
          errorMessage: "Device not connected. Please connect first.",
        );
      }
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final duration = DateTime.now().difference(_startTime!).inSeconds;
      state = state.copyWith(durationSeconds: duration);
    });
  }

  void _startSimulationTimer() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted ||
          state.status != MonitoringStatus.monitoring ||
          !state.isSimulation) {
        timer.cancel();
        return;
      }

      final newBpm = 110 + _random.nextInt(40);
      _handleNewBpm(newBpm);
    });
  }

  void _handleNewBpm(int newBpm) {
    if (!mounted) return;
    final currentBpmData = List<int>.from(state.bpmData);
    currentBpmData.add(newBpm);

    state = state.copyWith(bpmData: currentBpmData, currentBpm: newBpm);
  }

  void stopMonitoring() {
    _timer?.cancel();
    if (mounted) {
      state = state.copyWith(status: MonitoringStatus.completed);
    }
  }

  Future<void> saveRecord({String? notes}) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      int patientIdToSave;

      if (_patientId != null) {
        patientIdToSave = _patientId;
      } else {
        final patientData = await Supabase.instance.client
            .from('patients')
            .select('id, hpht')
            .eq('user_id', user.id)
            .maybeSingle();

        if (patientData == null) {
          throw Exception('Patient profile not found');
        }
        patientIdToSave = patientData['id'];
      }

      final currentData = state.bpmData;
      final classification = BpmClassifier.classify(currentData, 24);
      final avgBpm = currentData.isEmpty
          ? 0
          : currentData.reduce((a, b) => a + b) / currentData.length;

      final durationMins = state.durationSeconds / 60;

      final Map<String, dynamic> dataToInsert = {
        'patient_id': patientIdToSave,
        'created_by': user.id,
        'start_time': _startTime!.toIso8601String(),
        'end_time': DateTime.now().toIso8601String(),
        'duration_minutes': durationMins,
        'bpm_data': currentData,
        'average_bpm': avgBpm,
        'classification': classification,
        'gestational_age_weeks': 24,
      };

      if (_patientId != null) {
        // Doctor Mode
        dataToInsert['doctor_notes'] = notes;
      } else {
        // Patient Mode
        dataToInsert['notes'] = notes;
      }

      // OFFLINE CHECK
      if (!_offlineService.isOnline) {
        await _offlineService.addToQueue(
          'records',
          dataToInsert,
          type: 'insert',
        );
        // Can add logic here to show a toast "Saved Offline" if UI supported it
      } else {
        await Supabase.instance.client.from('records').insert(dataToInsert);
      }

      // If Patient Mode: Mark permission used
      if (_patientId == null) {
        if (_offlineService.isOnline) {
          final request = await Supabase.instance.client
              .from('monitoring_requests')
              .select('id')
              .eq('patient_id', patientIdToSave)
              .eq('status', 'approved')
              .limit(1)
              .maybeSingle();

          if (request != null) {
            await Supabase.instance.client
                .from('monitoring_requests')
                .update({'status': 'completed'})
                .eq('id', request['id']);
          }
        }

        if (mounted) {
          state = state.copyWith(permissionStatus: PermissionStatus.none);
        }
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(errorMessage: e.toString());
      }
      rethrow;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bpmSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _requestsSubscription?.cancel();
    _adapterStateSubscription?.cancel();
    _authSubscription?.cancel();
    _repository.bleRepository.disconnect();
    super.dispose();
  }
}
