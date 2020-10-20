import 'dart:async';

import 'package:another_location_plugin/another_location_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget with WidgetsBindingObserver {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _initialized = false;
  var _latitude = 'No latitude';
  var _longitude = 'No longitude';
  var _permissionGranted = false;
  var _messageFromActivity = 'No message for now';
  String status = 'No located';
  Map<dynamic, dynamic> _coordinates = {};
  bool located = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> initializePlugin() async {
    bool initialize;
    try {
      initialize = await AnotherLocationPlugin.initializePlugin;
    } on PlatformException {
      print("No initialization");
    }

    if (!mounted) return;

    if (initialize) {
      setState(() {
        _initialized = true;
      });
    }
  }

  Future<void> getLastLocation() async {
    Map<dynamic, dynamic> coordinates;
    try {
      coordinates = await AnotherLocationPlugin.lastCoordinates;
      print(coordinates);
      if (coordinates['status'] == null) {
        located = true;
      }
    } on PlatformException {
      _coordinates['latitude'] = 'no latitude';
      _coordinates['longitude'] = 'no longitude';
    }

    if (!mounted) return;

    AnotherLocationPlugin.locationEventStream.listen((coordinates) {
      setState(() {
        _coordinates = coordinates;
        _latitude = _coordinates['latitude'].toStringAsFixed(2);
        _longitude = _coordinates['longitude'].toStringAsFixed(2);
      });
    });
  }

  Future<void> getResultFromActivity() async {
    bool result;
    try {
      result = await AnotherLocationPlugin.resultFromActivity;
    } on PlatformException {
      print("No result");
    }

    if (!mounted) return;

    AnotherLocationPlugin.activityResultEventStream.listen((result) {
      setState(() {
        if (result != null) {
          _messageFromActivity = result;
        } else {
          _messageFromActivity = "nothing came back";
        }
        print(result);
      });
    });
  }

  Future<void> checkPermission() async {
    bool result;
    try {
      result = await AnotherLocationPlugin.checkPermission;
    } on PlatformException {
      print("No result");
    }

    if (!mounted) return;

    if (!result) {
      setState(() {
        _permissionGranted = true;
      });
    }
  }

  Future<void> requestPermission() async {
    try {
      await AnotherLocationPlugin.requestPermission;
    } on PlatformException {
      print("No permission requested");
    }
    if (!mounted) return;
  }

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
                  FlatButton(
                    child: Text('Initialize Plugin'),
                    color: Colors.red,
                    onPressed: () {
                      initializePlugin();
                    },
                  ),
                  Text(_initialized
                      ? 'THE PLUGIN IS UP AND RUNNING'
                      : 'THE PLUGIN IS SLEEPING'),
                ],
              ),
              Column(
                children: [
                  FlatButton(
                    child: Text('Check if Permissions are granted'),
                    color: Colors.amber,
                    onPressed: () {
                      checkPermission();
                    },
                  ),
                  Text(_permissionGranted ? 'Go ahead' : 'No permission'),
                ],
              ),
              Column(
                children: [
                  FlatButton(
                    child: Text('Request for Permissions of location'),
                    color: Colors.pinkAccent,
                    onPressed: () {
                      requestPermission();
                    },
                  ),
                ],
              ),
              Column(
                children: [
                  FlatButton(
                    child: Text('Start listening Location'),
                    color: Colors.blue,
                    onPressed: () {
                      getLastLocation();
                    },
                  ),
                  Text('Latitude: $_latitude \nLongitude: $_longitude'),
                ],
              ),
              Column(
                children: [
                  FlatButton(
                    child: Text('Go to new Activity'),
                    color: Colors.lightGreenAccent,
                    onPressed: () {
                      getResultFromActivity();
                    },
                  ),
                  Text("Message: $_messageFromActivity"),
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
