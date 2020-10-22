import 'dart:async';

import 'package:another_location_plugin_example/plugin_brain.dart';
import 'package:another_location_plugin_example/plugin_button.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

PluginBrain pluginBrain = new PluginBrain();

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  var _initialized = false;
  var _permissionGranted = false;
  var _latitude = 'No latitude';
  var _longitude = 'No longitude';
  var _messageFromActivity = 'No message for now';
  Map<dynamic, dynamic> _coordinates = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.detached:
        print("detached");
        break;
      case AppLifecycleState.inactive:
        print("inactive");
        break;
      case AppLifecycleState.paused:
        print("paused");
        break;
      case AppLifecycleState.resumed:
        print("resumed");
        break;
    }
    setState(() {});
  }

  Future<void> initializePlugin() async => _initialized = await pluginBrain.initializePlugin();

  Future<void> checkPermission() async => _permissionGranted = await pluginBrain.checkPermission();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  PluginButton(
                      text: 'Initialize Plugin',
                      color: Colors.red,
                      onPressed: () {
                        setState(() {
                          initializePlugin();
                        });
                      }),
                  Text(_initialized ? 'THE PLUGIN IS UP AND RUNNING' : 'THE PLUGIN IS SLEEPING'),
                ],
              ),
              Column(
                children: [
                  PluginButton(
                      text: 'Check if Permissions are granted',
                      color: Colors.amber,
                      onPressed: () {
                        setState(() {
                          checkPermission();
                        });
                      }),
                  Text(_permissionGranted ? 'Go ahead' : 'No permission'),
                ],
              ),
              Column(
                children: [
                  PluginButton(
                      text: 'Request for Permissions of location',
                      color: Colors.pinkAccent,
                      onPressed: () {
                        pluginBrain.requestPermission();
                      }),
                ],
              ),
              Column(
                children: [
                  PluginButton(
                      text: 'Start listening Location',
                      color: Colors.blue,
                      onPressed: () {
                        pluginBrain.getLastLocation();
                      }),
                  StreamBuilder<dynamic>(
                      stream: pluginBrain.locationStream,
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          _coordinates = snapshot.data;
                          _latitude = _coordinates['latitude'].toStringAsFixed(2);
                          _longitude = _coordinates['longitude'].toStringAsFixed(2);
                        }
                        return Text('Latitude: $_latitude \nLongitude: $_longitude');
                      }),
                ],
              ),
              Column(
                children: [
                  PluginButton(
                      text: 'Stop listening Location',
                      color: Colors.purple,
                      onPressed: () {
                        pluginBrain.stopLocationUpdates();
                      }),
                ],
              ),
              Column(
                children: [
                  PluginButton(
                      text: 'Go to new Activity',
                      color: Colors.lightGreenAccent,
                      onPressed: () {
                        pluginBrain.getResultFromActivity();
                      }),
                  StreamBuilder<dynamic>(
                      stream: pluginBrain.activityResultStream,
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          _messageFromActivity = snapshot.data;
                        }
                        return Text("Message: $_messageFromActivity");
                      }),
                ],
              ),
              // Center(
              //   child: Text(located ? '$latitude, $longitude' : status),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
