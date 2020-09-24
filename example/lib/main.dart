import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:app_blocker/app_blocker.dart';

void main() {
  runApp(MyApp());
}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String title = 'Unknown state';
  AppBlocker _appBlocker = AppBlocker();

  @override
  void initState() {
    super.initState();
    _appBlocker.configure(
      onResume: (String packageName) async {
        print("onResume: $packageName");
        _appBlocker.bringAppToFront();
      },
      onBackgroundMessage: null
    );
//    initPlatformState();
  }

//  // Platform messages are asynchronous, so we initialize in an async method.
//  Future<void> initPlatformState() async {
//    String platformVersion;
//    // Platform messages may fail, so we use a try/catch PlatformException.
//    try {
//      platformVersion = "2"; //await AppBlocker.platformVersion;
//    } on PlatformException {
//      platformVersion = 'Failed to get platform version.';
//    }
//
//    // If the widget was removed from the tree while the asynchronous platform
//    // message was in flight, we want to discard the reply rather than calling
//    // setState to update our non-existent appearance.
//    if (!mounted) return;
//
//    setState(() {
//      _platformVersion = platformVersion;
//    });
//  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(
          child: FloatingActionButton(
            onPressed: () async {
              var isGranted = await _appBlocker.isAppUsagePermissionGranted();
              var isOptimizationBypassed = await _appBlocker.isBatteryOptimizationIgnored();
              print('App usage permission is granted = $isGranted');
              print('Battery optimization bypassed = $isOptimizationBypassed');
              _appBlocker.openBatteryOptimizationSettings();
              // await _appBlocker.updateBlockedPackages(["com.facebook.katana"]);
              // bool isBlocked = await _appBlocker.enableAppBlocker();
              //
              // setState(() {
              //   title = "AppBlocker isBlocked = $isBlocked";
              // });
            },

          ),
        ),
      ),
    );
  }
}
