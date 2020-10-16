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
  // String _platformVersion = 'Unknown';
  // String _stringPermission = 'Unauthorized';
  Map<dynamic, dynamic> _coordinates = {};

  @override
  void initState() {
    super.initState();
    initializePlugin();
  }

  void callMethods() async {
    // await AnotherLocationPlugin.checkPermission;
    // await AnotherLocationPlugin.requestPermission;
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

  // Future<void> getStringPermissions() async {
  //   String stringPermission = 'Got permission';
  //   try {
  //     await AnotherLocationPlugin.requestPermission;
  //   } on PlatformException {
  //     stringPermission = 'Failed to get string permission.';
  //   }
  //
  //   if (!mounted) return;
  //
  //   setState(() {
  //     _stringPermission = stringPermission;
  //   });
  // }

  Future<void> getLastLocation() async {
    Map<dynamic, dynamic> coordinates;
    try {
      coordinates = await AnotherLocationPlugin.lastCoordinates;
    } on PlatformException {
      coordinates['latitude'] = 'no latitude';
      coordinates['longitude'] = 'no longitude';
    }

    if (!mounted) return;

    setState(() {
      _coordinates = coordinates;
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
              child: Text(
                  '${_coordinates['latitude']}, ${_coordinates['longitude']}, ${_coordinates['status']}'),
            ),
          ],
        ),
      ),
    );
  }
}
