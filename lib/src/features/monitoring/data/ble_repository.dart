import 'dart:async';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleRepository {
  // UUIDs from esp32.ino
  static const String serviceUuid = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  static const String charUuid = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";

  BluetoothDevice? _connectedDevice;
  StreamSubscription? _scanSubscription;

  // Stream of BPM values (integers)
  final _bpmController = StreamController<int>.broadcast();
  Stream<int> get bpmStream => _bpmController.stream;

  // Connection State Stream
  Stream<BluetoothConnectionState> get connectionStateStream async* {
    if (_connectedDevice != null) {
      yield* _connectedDevice!.connectionState;
    } else {
      yield BluetoothConnectionState.disconnected;
    }
  }

  // Adapter State Stream
  Stream<BluetoothAdapterState> get adapterStateStream =>
      FlutterBluePlus.adapterState;

  Future<void> init() async {
    // 1. Request Runtime Permissions (Crucial for Android 12+)
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (statuses.values.any((s) => s.isDenied || s.isPermanentlyDenied)) {
      throw Exception("Bluetooth permissions are required for monitoring.");
    }

    // 2. Check if BLE is supported/on
    if (await FlutterBluePlus.isSupported == false) {
      throw Exception("Bluetooth not supported");
    }

    // 3. On Android, turn on BT if off
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
  }

  Future<void> scanAndConnect() async {
    if (_connectedDevice != null) return;

    print("Starting BLE Scan...");

    final completer = Completer<void>();

    _scanSubscription = FlutterBluePlus.onScanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.device.platformName == "Dopply-FetalMonitor" ||
            r.advertisementData.serviceUuids.contains(Guid(serviceUuid))) {
          print("Found Dopply Monitor: ${r.device.platformName}");

          // Stop scanning
          FlutterBluePlus.stopScan();
          _scanSubscription?.cancel();

          await _connectToDevice(r.device);
          if (!completer.isCompleted) completer.complete();
          break;
        }
      }
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    // If scan finishes without finding
    await Future.delayed(const Duration(seconds: 10));
    if (!completer.isCompleted) {
      _scanSubscription?.cancel();
      throw Exception("Device not found. Make sure it's on and in range.");
    }

    return completer.future;
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(autoConnect: false);
      _connectedDevice = device;

      // Discover services
      final services = await device.discoverServices();
      for (BluetoothService s in services) {
        if (s.uuid.toString() == serviceUuid) {
          for (BluetoothCharacteristic c in s.characteristics) {
            if (c.uuid.toString() == charUuid) {
              await _setupNotifications(c);
              return;
            }
          }
        }
      }
    } catch (e) {
      _connectedDevice = null;
      rethrow;
    }
  }

  Future<void> _setupNotifications(BluetoothCharacteristic c) async {
    await c.setNotifyValue(true);
    c.lastValueStream.listen((value) {
      try {
        final stringVal = String.fromCharCodes(value).trim();
        // ESP32 sends: "120"
        // Previous assumed: "120 (Normal)" which was incorrect.

        final bpm = int.tryParse(stringVal);
        if (bpm != null) {
          _bpmController.add(bpm);
        }
      } catch (e) {
        // Validation error
      }
    });
  }

  Future<void> disconnect() async {
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
  }
}
