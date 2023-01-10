import 'dart:async';
import 'dart:io';

import 'package:esense_flutter/esense.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class ESenseController {
  ESenseController(
      {required this.deviceName,
      required this.onConnectionChange,
      required this.onRightShake,
      required this.onLeftShake});

  final String deviceName;
  final Function onConnectionChange;
  final Function onRightShake;
  final Function onLeftShake;

  late ESenseManager eSenseManager = ESenseManager(deviceName);
  StreamSubscription? subscription;

  bool connected = false;
  bool listening = false;
  bool permissionsGranted = false;

  int mAccelCurrent = 0;
  int mAccelLast = 0;

  DateTime lastShake = DateTime.now();
  static const int shakeTreshold = 2750;
  static const int timeBetweenShakesInMilliseconds = 750;

  void connect() async {
    if (connected) return;

    if (Platform.isAndroid) {
      permissionsGranted = await _areBluetoothAndLocationPermissionGranted();
    }

    eSenseManager.connectionEvents.listen((event) {
      connected = event.type == ConnectionType.connected;
      onConnectionChange();

      if (kDebugMode) print(event.type.toString());

      if (listening) _detectShake();
    });

    if (permissionsGranted) await eSenseManager.connect();
  }

  void startListening() {
    listening = true;
    _detectShake();
  }

  void _detectShake() {
    if (!permissionsGranted) return;
    if (!connected) return;

    subscription = eSenseManager.sensorEvents.listen((event) {
      if (event.accel == null) return;

      List<int> accelVector = event.accel!;
      int z = accelVector[2];

      mAccelLast = mAccelCurrent;
      mAccelCurrent = z;
      int delta = mAccelCurrent - mAccelLast;

      // Detect shake right or left
      if (delta.abs() > shakeTreshold) {
        DateTime now = event.timestamp;
        if (now.difference(lastShake).inMilliseconds <
            timeBetweenShakesInMilliseconds) return;
        lastShake = now;
        if (delta >= 0) {
          // The shake was in the right direction
          onRightShake();
        } else {
          // The shake was in the left direction
          onLeftShake();
        }
      }
    });
  }

  void stopListening() {
    listening = false;
    subscription?.cancel();
  }

  void disconnect() {
    if (!permissionsGranted) return;
    eSenseManager.disconnect();
  }

  Future<bool> _areBluetoothAndLocationPermissionGranted() async {
    bool allGranted = true;
    allGranted = allGranted && await Permission.bluetooth.isGranted;
    allGranted = allGranted && await Permission.locationWhenInUse.isGranted;
    allGranted = allGranted && await Permission.bluetoothScan.isGranted;
    allGranted = allGranted && await Permission.bluetoothConnect.isGranted;
    return allGranted;
  }
}
