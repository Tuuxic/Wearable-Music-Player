import 'dart:async';
import 'dart:io';

import 'package:esense_flutter/esense.dart';
import 'package:permission_handler/permission_handler.dart';

class ESenseController {
  ESenseController(
      {required this.deviceName,
      required this.onRightShake,
      required this.onLeftShake});

  final String deviceName;
  final Function onRightShake;
  final Function onLeftShake;

  late ESenseManager eSenseManager = ESenseManager(deviceName);
  StreamSubscription? subscription;

  bool connected = false;
  bool listening = false;

  int mAccelCurrent = 0;
  int mAccelLast = 0;
  static const int shakeTreshold = 300;

  void connect() async {
    eSenseManager.connectionEvents.listen((event) {
      connected = event.type == ConnectionType.connected;
      if (listening) detectShake();
    });

    if (Platform.isAndroid) await _requestBluetoothAndLocationPermission();

    await eSenseManager.connect();
  }

  void startListening() {
    listening = true;
    detectShake();
  }

  void detectShake() {
    if (connected) {
      subscription = eSenseManager.sensorEvents.listen((event) {
        if (event.accel == null) return;

        List<int> accelVector = event.accel ?? [0, 0, 0];
        int z = accelVector[2];

        mAccelLast = mAccelCurrent;
        mAccelCurrent = z;
        int delta = mAccelCurrent - mAccelLast;
        if (delta.abs() > shakeTreshold) {
          if (delta >= 0) {
            onLeftShake();
          } else {
            onRightShake();
          }
        }
      });
    }
  }

  void stopListening() {
    subscription?.cancel();
  }

  void disconnect() {
    eSenseManager.disconnect();
  }

  Future<void> _requestBluetoothAndLocationPermission() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.locationWhenInUse.request();
  }
}
