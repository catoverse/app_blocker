import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef Future<dynamic> MessageHandler(String message);


// TODO: Currently we are not making any background channel for
// message passing when the app is not actively running process.
// Instead we open the app forcefully directly.
// void _appBlockerSetupBackgroundChannel(
//     {MethodChannel backgroundChannel =
//         const MethodChannel(AppBlocker.APP_CHANNEL_BACKGROUND)}) async {
// // Setup Flutter state needed for MethodChannels.
//   WidgetsFlutterBinding.ensureInitialized();
//
// // This is where the magic happens and we handle background events from the
// // native portion of the plugin.
//   backgroundChannel.setMethodCallHandler((MethodCall call) async {
//     if (call.method == 'handleBackgroundMessage') {
//       final CallbackHandle handle =
//           CallbackHandle.fromRawHandle(call.arguments['handle']);
//       final Function handlerFunction =
//           PluginUtilities.getCallbackFromHandle(handle);
//       try {
//         await handlerFunction(call.arguments['appPackage']);
//       } catch (e) {
//         print('Unable to handle incoming background message.');
//         print(e);
//       }
//       return Future<void>.value();
//     }
//   });
//
// // Once we've finished initializing, let the native portion of the plugin
// // know that it can start scheduling handling messages.
//   backgroundChannel.invokeMethod<void>('AppBlockerService#initialized');
// }

class AppBlocker {
  static const APP_CHANNEL = 'club.cato/app_blocker';
  static const APP_CHANNEL_BACKGROUND = 'club.cato/app_blocker_background';

  factory AppBlocker() => _instance;

  @visibleForTesting
  AppBlocker.private(MethodChannel channel) : _channel = channel;

  static final AppBlocker _instance =
      AppBlocker.private(const MethodChannel(APP_CHANNEL));

  final MethodChannel _channel;

  MessageHandler _onResume;
  //MessageHandler _onBackgroundMessage;

  void configure({
    MessageHandler onResume,
    MessageHandler onBackgroundMessage,
  }) {
    _onResume = onResume;

    _channel.setMethodCallHandler(_handleMethod);
    _channel.invokeMethod<void>('configure');

    // TODO: Doesn't need background message handling for now
    // if (onBackgroundMessage != null) {
    //   _onBackgroundMessage = onBackgroundMessage;
    //   final CallbackHandle backgroundSetupHandle =
    //       PluginUtilities.getCallbackHandle(_appBlockerSetupBackgroundChannel);
    //
    //   final CallbackHandle backgroundMessageHandle =
    //       PluginUtilities.getCallbackHandle(_onBackgroundMessage);
    //
    //   if (backgroundMessageHandle == null) {
    //     throw ArgumentError('''
    //       Failed to setup background message handler!
    //       ''');
    //   }
    //
    //   _channel.invokeMethod<bool>(
    //     'AppBlockerService#start',
    //     <String, dynamic>{
    //       'setupHandle': backgroundSetupHandle.toRawHandle(),
    //       'backgroundHandle': backgroundMessageHandle.toRawHandle()
    //     },
    //   );
    // }
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onResume':
        {
          return _onResume(call.arguments.toString());
        }

      default:
        throw UnsupportedError('Unrecognized JSON message');
    }
  }

  /// Return AppBlocker state
  Future<bool> isEnabled() async {
    return await _channel.invokeMethod('isEnabled');
  }

  /// Enables the appBlocker to block the apps
  Future<bool> enableAppBlocker() async {
    return await _channel.invokeMethod('enableAppBlocker');
  }

  /// Disables the appBlocker
  Future<bool> disableAppBlocker() async {
    return await _channel.invokeMethod('disableAppBlocker');
  }

  /// Set the restriction time window for the appBlocker.
  ///
  /// The appBlocker will only block apps between time [startTime] and [endTime]
  /// startTime and endTime must be in the format "HH:MM:SS" in 24 hours time.
  Future<bool> setRestrictionTime(String startTime, String endTime) async {
    return await _channel.invokeMethod(
      'setTime',
      {'startTime': startTime, 'endTime': endTime},
    );
  }

  /// Resets the restriction time window for the appBlocker to block app
  /// anytime of the day.
  Future<bool> resetRestrictionTime() async {
    return await setRestrictionTime('-1', '-1');
  }

  /// Returns the map containing startTime and endTime for the restriction time period.
  Future<Map<String, String>> getRestrictionTime() async {
    return await _channel.invokeMapMethod('getTime');
  }

  /// Set the weekdays when you want to appBlocker to block apps.
  Future<bool> setRestrictionWeekDays(List<int> weekDays) async {
    List<String> weekDaysInt = weekDays.map((e) => e.toString()).toList();
    return await _channel.invokeMethod('setWeekDays', weekDaysInt);
  }

  /// Returns the list of restricted week days for the plugin.
  Future<List<int>> getRestrictedWeekDays() async {
    return await _channel.invokeListMethod('getWeekDays');
  }

  /// Resets the weekdays to be restricted
  Future<bool> resetRestrictionWeekDays() async {
    return await setRestrictionWeekDays(List());
  }

  /// Blocks the given list of packages.
  ///
  /// To reset the blocked packages send an empty list.
  /// Each time send a full list of packages to be blocked.
  Future<bool> updateBlockedPackages(List<String> packages) async {
    return await _channel.invokeMethod('updateBlockedPackages', packages);
  }

  /// Returns the list of blocked packages
  Future<List<String>> getBlockedPackages() async {
    List<String> packages =  await _channel.invokeListMethod('getBlockedPackages');
    return List()..addAll(packages);
  }

  /// Call this method to make sure the app can be bring to front if in the recent
  /// tasks list of the phone.
  ///
  /// You should call this method on onResume handler of `configure` method when
  /// you configure the library from the app.
  void bringAppToFront() {
    _channel.invokeMethod("bringAppToForeground");
  }

  /// Returns Future bool whether or not the app usage permission is granted or not
  Future<bool> isAppUsagePermissionGranted() async {
    return await _channel.invokeMethod("isAppUsagePermissionGranted");
  }

  /// Launch intent for the app usage permission screen for our app.
  void openAppUsageSettings() {
    _channel.invokeMethod("openAppUsageSettings");
  }

  /// Returns Future bool whether the battery optimization for our app
  /// is ignored or not.
  Future<bool> isBatteryOptimizationIgnored() async {
    return await _channel.invokeMethod("isBatteryOptimizationBypass");
  }

  /// Opens Battery Optimization Popup/Screen which helps to run
  /// the app background service for longer.
  void openBatteryOptimizationSettings() {
    _channel.invokeMethod("openBatteryOptimization");
  }

  /// Returns Future bool whether the overlay permission is granted or not
  ///
  /// The overlay permission is required in API 30 and above in order to open
  /// activity from background.
  Future<bool> isOverlayPermissionGranted() async {
    return await _channel.invokeMethod("isOverlayPermissionGranted");
  }

  /// Method to request for the overlay permission
  void requestOverlayPermission() {
    _channel.invokeMethod("requestOverlayPermission");
  }
}
