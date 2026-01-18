import 'package:equatable/equatable.dart';

enum MonitoringStatus { idle, monitoring, completed }

enum DeviceConnectionStatus { disconnected, scanning, connected }

enum PermissionStatus { none, pending, granted, loading }

class MonitoringState extends Equatable {
  final MonitoringStatus status;
  final DeviceConnectionStatus connectionStatus;
  final PermissionStatus permissionStatus; // New: Authorization
  final List<int> bpmData;
  final int? currentBpm;
  final int durationSeconds;
  final String? errorMessage;
  final bool isSimulation;

  const MonitoringState({
    this.status = MonitoringStatus.idle,
    this.connectionStatus = DeviceConnectionStatus.disconnected,
    this.permissionStatus = PermissionStatus.none,
    this.bpmData = const [],
    this.currentBpm,
    this.durationSeconds = 0,
    this.errorMessage,
    this.isSimulation = true,
  });

  MonitoringState copyWith({
    MonitoringStatus? status,
    DeviceConnectionStatus? connectionStatus,
    PermissionStatus? permissionStatus,
    List<int>? bpmData,
    int? currentBpm,
    int? durationSeconds,
    String? errorMessage,
    bool? isSimulation,
  }) {
    return MonitoringState(
      status: status ?? this.status,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      bpmData: bpmData ?? this.bpmData,
      currentBpm: currentBpm ?? this.currentBpm,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      errorMessage: errorMessage,
      isSimulation: isSimulation ?? this.isSimulation,
    );
  }

  @override
  List<Object?> get props => [
    status,
    connectionStatus,
    permissionStatus,
    bpmData,
    currentBpm,
    durationSeconds,
    errorMessage,
    isSimulation,
  ];
}
