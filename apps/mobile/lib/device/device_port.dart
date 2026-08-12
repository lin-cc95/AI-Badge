import 'dart:async';

import '../models/app_models.dart';

class DeviceSnapshot {
  const DeviceSnapshot({
    required this.status,
    required this.battery,
    required this.progress,
    this.name = 'AI Badge Sim',
  });

  final DeviceStatus status;
  final int battery;
  final double progress;
  final String name;

  DeviceSnapshot copyWith({
    DeviceStatus? status,
    int? battery,
    double? progress,
    String? name,
  }) => DeviceSnapshot(
    status: status ?? this.status,
    battery: battery ?? this.battery,
    progress: progress ?? this.progress,
    name: name ?? this.name,
  );
}

abstract interface class DevicePort {
  Stream<DeviceSnapshot> get snapshots;
  DeviceSnapshot get current;
  Future<void> scanAndPair();
  Future<void> disconnect();
  Future<void> reconnect();
  Future<void> syncCharacter(BadgeCharacter character);
  Future<void> testAction(String eventType);
  void dispose();
}

class VirtualDeviceAdapter implements DevicePort {
  final _controller = StreamController<DeviceSnapshot>.broadcast();
  DeviceSnapshot _current = const DeviceSnapshot(
    status: DeviceStatus.unbound,
    battery: 86,
    progress: 0,
  );

  @override
  DeviceSnapshot get current => _current;

  @override
  Stream<DeviceSnapshot> get snapshots => _controller.stream;

  void _emit(DeviceSnapshot next) {
    _current = next;
    _controller.add(next);
  }

  @override
  Future<void> scanAndPair() async {
    _emit(_current.copyWith(status: DeviceStatus.scanning));
    await Future<void>.delayed(const Duration(milliseconds: 650));
    _emit(_current.copyWith(status: DeviceStatus.pairing));
    await Future<void>.delayed(const Duration(milliseconds: 650));
    _emit(_current.copyWith(status: DeviceStatus.connected));
  }

  @override
  Future<void> disconnect() async =>
      _emit(_current.copyWith(status: DeviceStatus.offline));

  @override
  Future<void> reconnect() async {
    _emit(_current.copyWith(status: DeviceStatus.reconnecting));
    await Future<void>.delayed(const Duration(milliseconds: 700));
    _emit(_current.copyWith(status: DeviceStatus.connected));
  }

  @override
  Future<void> syncCharacter(BadgeCharacter character) async {
    if (_current.status != DeviceStatus.connected) {
      throw StateError('DEVICE_NOT_CONNECTED');
    }
    for (var i = 0; i <= 10; i++) {
      _emit(
        _current.copyWith(status: DeviceStatus.transferring, progress: i / 10),
      );
      await Future<void>.delayed(const Duration(milliseconds: 130));
    }
    _emit(_current.copyWith(status: DeviceStatus.connected, progress: 1));
  }

  @override
  Future<void> testAction(String eventType) async {
    if (_current.status != DeviceStatus.connected) {
      throw StateError('DEVICE_NOT_CONNECTED');
    }
    await Future<void>.delayed(const Duration(milliseconds: 280));
  }

  @override
  void dispose() => _controller.close();
}

/// Real BLE implementation boundary. UUIDs, command frames, authentication and
/// OTA are deliberately blocked on the hardware team's BLE V1 contract.
abstract interface class BleDeviceAdapter implements DevicePort {}
