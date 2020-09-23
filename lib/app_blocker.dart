import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

//void _appBlockerSetupBackgroundChannel(
//    {MethodChannel backgroundChannel =
//        const MethodChannel('club.cato/app_blocker_background')}) async {
//  // Setup Flutter state needed for MethodChannels.
//  WidgetsFlutterBinding.ensureInitialized();
//
//  // This is where the magic happens and we handle background events from the
//  // native portion of the plugin.
//  backgroundChannel.setMethodCallHandler((MethodCall call) async {
//    if (call.method == 'handleBackgroundMessage') {
//      final CallbackHandle handle =
//          CallbackHandle.fromRawHandle(call.arguments['handle']);
//      final Function handlerFunction =
//          PluginUtilities.getCallbackFromHandle(handle);
//      try {
//        await handlerFunction(call.arguments['appPackage']);
//      } catch (e) {
//        print('Unable to handle incoming background message.');
//        print(e);
//      }
//      return Future<void>.value();
//    }
//  });
//
//  // Once we've finished initializing, let the native portion of the plugin
//  // know that it can start scheduling handling messages.
//  backgroundChannel.invokeMethod<void>('AppBlockerDartService#initialized');
//}

class AppBlocker {
  static const MethodChannel _channel = const MethodChannel('club.cato/app_blocker');

  static Future<bool> enableAppBlocker() async {
    final bool isEnabled = await _channel.invokeMethod('enableAppBlocker');
    return isEnabled;
  }

  static Future<bool> disableAppBlocker() async {
    final bool isDisable = await _channel.invokeMethod('disableAppBlocker');
    return isDisable;
  }

  static Future<bool> addPackage(String packageName) async {
    final bool willBlock =
        await _channel.invokeMethod('addPackage', packageName);
    return willBlock;
  }

  static Future<bool> removePackage(String packageName) async {
    final bool isUnBlock =
        await _channel.invokeMethod('removePackage', packageName);
    return isUnBlock;
  }

}
