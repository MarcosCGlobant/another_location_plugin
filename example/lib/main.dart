import 'dart:async';

import 'package:another_location_plugin/another_location_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String latitude = 'No latitude';
  String longitude = 'No longitude';
  String status = 'No location';
  Map<dynamic, dynamic> _coordinates = {};
  bool located = false;

  @override
  void initState() {
    super.initState();
    initializePlugin();
  }

  void callMethods() async {
    await getLastLocation();
  }

  Future<void> initializePlugin() async {
    bool initialize;
    try {
      initialize = await AnotherLocationPlugin.initializePlugin;
      if (initialize) {
        callMethods();
      }
    } on PlatformException {
      initialize = false;
    }

    if (!mounted) return;
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

    AnotherLocationPlugin.eventStream.listen((coordinates) {
      setState(() {
        _coordinates = coordinates;
        latitude = _coordinates['latitude'].toString();
        longitude = _coordinates['longitude'].toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Center(
              child: Text(located ? '$latitude, $longitude' : status),
            ),
          ],
        ),
      ),
    );
  }
}
