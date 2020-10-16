import 'dart:async';

import 'package:flutter/services.dart';

class AnotherLocationPlugin {
  static const MethodChannel _channel =
      const MethodChannel('another_location_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> get checkPermission async {
    final bool permitted = await _channel.invokeMethod('checkPermission');
    return permitted;
  }

  static Future<void> get requestPermission async {
    await _channel.invokeMethod('requestPermission');
    return;
  }

  static Future<Map<dynamic, dynamic>> get lastCoordinates async {
    final Map<dynamic, dynamic> coordinates =
        await _channel.invokeMethod('getLastKnownPosition');
    return coordinates;
  }

  static Future<bool> get initializePlugin async {
    final bool initialize = await _channel.invokeMethod('initialize');
    return initialize;
  }
}
