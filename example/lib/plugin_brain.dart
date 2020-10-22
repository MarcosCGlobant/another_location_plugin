import 'dart:async';

import 'package:another_location_plugin/another_location_plugin.dart';
import 'package:flutter/services.dart';

class PluginBrain {
  Stream<dynamic> get locationStream => AnotherLocationPlugin.locationEventStream;

  Stream<dynamic> get activityResultStream => AnotherLocationPlugin.activityResultEventStream;

  Future<bool> initializePlugin() async {
    bool initialize;
    try {
      initialize = await AnotherLocationPlugin.initializePlugin;
    } on PlatformException {
      print("No initialization");
    }
    return initialize ? true : false;
  }

  Future<bool> checkPermission() async {
    bool result;
    try {
      result = await AnotherLocationPlugin.checkPermission;
    } on PlatformException {
      print("No result");
    }
    return !result ? true : false;
  }

  Future<void> requestPermission() async {
    try {
      await AnotherLocationPlugin.requestPermission;
    } on PlatformException {
      print("No permission requested");
    }
  }

  Future<Map<dynamic, dynamic>> getLastLocation() async {
    Map<dynamic, dynamic> coordinates;
    try {
      coordinates = await AnotherLocationPlugin.lastCoordinates;
    } on PlatformException {
      print('no latitude');
      print('no longitude');
    }
    return coordinates;
  }

  Future<void> stopLocationUpdates() async {
    try {
      await AnotherLocationPlugin.stopLocationUpdates;
    } on PlatformException {
      print("Updates couldn't be stopped");
    }
  }

  Future<void> getResultFromActivity() async {
    try {
      await AnotherLocationPlugin.resultFromActivity;
    } on PlatformException {
      print("No result");
    }
  }
}
