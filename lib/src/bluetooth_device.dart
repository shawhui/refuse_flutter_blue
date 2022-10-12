// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of refuse_flutter_blue;

class RefuseBluetoothDevice {
  final DeviceIdentifier id;
  final String name;
  final RefuseBluetoothDeviceType type;

  RefuseBluetoothDevice.fromProto(protos.BluetoothDevice p)
      : id = new DeviceIdentifier(p.remoteId),
        name = p.name,
        type = RefuseBluetoothDeviceType.values[p.type.value];

  BehaviorSubject<bool> _isDiscoveringServices = BehaviorSubject.seeded(false);
  Stream<bool> get isDiscoveringServices => _isDiscoveringServices.stream;

  /// Establishes a connection to the Bluetooth Device.
  Future<void> connect({
    Duration timeout,
    bool autoConnect = true,
  }) async {
    var request = protos.ConnectRequest.create()
      ..remoteId = id.toString()
      ..androidAutoConnect = autoConnect;

    Timer timer;
    if (timeout != null) {
      timer = Timer(timeout, () {
        disconnect();
        throw TimeoutException('Failed to connect in time.', timeout);
      });
    }

    await RefuseFlutterBlue.instance._channel
        .invokeMethod('connect', request.writeToBuffer());

    await state.firstWhere((s) => s == RefuseBluetoothDeviceState.connected);

    timer?.cancel();

    return;
  }

  /// Cancels connection to the Bluetooth Device
  Future disconnect() =>
      RefuseFlutterBlue.instance._channel.invokeMethod('disconnect', id.toString());

  BehaviorSubject<List<RefuseBluetoothService>> _services =
      BehaviorSubject.seeded([]);

  /// Discovers services offered by the remote device as well as their characteristics and descriptors
  Future<List<RefuseBluetoothService>> discoverServices() async {
    final s = await state.first;
    if (s != RefuseBluetoothDeviceState.connected) {
      return Future.error(new Exception(
          'Cannot discoverServices while device is not connected. State == $s'));
    }
    var response = RefuseFlutterBlue.instance._methodStream
        .where((m) => m.method == "DiscoverServicesResult")
        .map((m) => m.arguments)
        .map((buffer) => new protos.DiscoverServicesResult.fromBuffer(buffer))
        .where((p) => p.remoteId == id.toString())
        .map((p) => p.services)
        .map((s) => s.map((p) => new RefuseBluetoothService.fromProto(p)).toList())
        .first
        .then((list) {
      _services.add(list);
      _isDiscoveringServices.add(false);
      return list;
    });

    await RefuseFlutterBlue.instance._channel
        .invokeMethod('discoverServices', id.toString());

    _isDiscoveringServices.add(true);

    return response;
  }

  /// Returns a list of Bluetooth GATT services offered by the remote device
  /// This function requires that discoverServices has been completed for this device
  Stream<List<RefuseBluetoothService>> get services async* {
    yield await RefuseFlutterBlue.instance._channel
        .invokeMethod('services', id.toString())
        .then((buffer) =>
            new protos.DiscoverServicesResult.fromBuffer(buffer).services)
        .then((i) => i.map((s) => new RefuseBluetoothService.fromProto(s)).toList());
    yield* _services.stream;
  }

  /// The current connection state of the device
  Stream<RefuseBluetoothDeviceState> get state async* {
    yield await RefuseFlutterBlue.instance._channel
        .invokeMethod('deviceState', id.toString())
        .then((buffer) => new protos.DeviceStateResponse.fromBuffer(buffer))
        .then((p) => RefuseBluetoothDeviceState.values[p.state.value]);

    yield* RefuseFlutterBlue.instance._methodStream
        .where((m) => m.method == "DeviceState")
        .map((m) => m.arguments)
        .map((buffer) => new protos.DeviceStateResponse.fromBuffer(buffer))
        .where((p) => p.remoteId == id.toString())
        .map((p) => RefuseBluetoothDeviceState.values[p.state.value]);
  }

  /// The MTU size in bytes
  Stream<int> get mtu async* {
    yield await RefuseFlutterBlue.instance._channel
        .invokeMethod('mtu', id.toString())
        .then((buffer) => new protos.MtuSizeResponse.fromBuffer(buffer))
        .then((p) => p.mtu);

    yield* RefuseFlutterBlue.instance._methodStream
        .where((m) => m.method == "MtuSize")
        .map((m) => m.arguments)
        .map((buffer) => new protos.MtuSizeResponse.fromBuffer(buffer))
        .where((p) => p.remoteId == id.toString())
        .map((p) => p.mtu);
  }

  /// Request to change the MTU Size
  /// Throws error if request did not complete successfully
  Future<void> requestMtu(int desiredMtu) async {
    var request = protos.MtuSizeRequest.create()
      ..remoteId = id.toString()
      ..mtu = desiredMtu;

    return RefuseFlutterBlue.instance._channel
        .invokeMethod('requestMtu', request.writeToBuffer());
  }

  /// Indicates whether the Bluetooth Device can send a write without response
  Future<bool> get canSendWriteWithoutResponse =>
      new Future.error(new UnimplementedError());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefuseBluetoothDevice &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RefuseBluetoothDevice{id: $id, name: $name, type: $type, isDiscoveringServices: ${_isDiscoveringServices?.value}, _services: ${_services?.value}';
  }
}

enum RefuseBluetoothDeviceType { unknown, classic, le, dual }

enum RefuseBluetoothDeviceState { disconnected, connecting, connected, disconnecting }
