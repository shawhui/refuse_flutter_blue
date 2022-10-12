// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of refuse_flutter_blue;

class RefuseBluetoothService {
  final RefuseGuid uuid;
  final DeviceIdentifier deviceId;
  final bool isPrimary;
  final List<RefuseBluetoothCharacteristic> characteristics;
  final List<RefuseBluetoothService> includedServices;

  RefuseBluetoothService.fromProto(protos.BluetoothService p)
      : uuid = new RefuseGuid(p.uuid),
        deviceId = new DeviceIdentifier(p.remoteId),
        isPrimary = p.isPrimary,
        characteristics = p.characteristics
            .map((c) => new RefuseBluetoothCharacteristic.fromProto(c))
            .toList(),
        includedServices = p.includedServices
            .map((s) => new RefuseBluetoothService.fromProto(s))
            .toList();

  @override
  String toString() {
    return 'RefuseBluetoothService{uuid: $uuid, deviceId: $deviceId, isPrimary: $isPrimary, characteristics: $characteristics, includedServices: $includedServices}';
  }
}
