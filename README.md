
# App Blocker & App Redirect (app_blocker) Plugin  
  
This is a modified app blocker plugin which is used to open your app when any restricted app (set by user) is opened. So, it works like an app redirect plugin. Works only on Android.
  
  
## Getting Started  
  
To use this package, add this package as the dependency to your flutter app. Then follows these steps.  
  In your flutter main function use this code to configure AppRedirect plugin.  
  
```dart
 if(Platform.isAndroid) { 
	AppBlocker appBlocker = AppBlocker(); 
	appBlocker.configure(onResume: (packageName) async {
		appBlocker.bringAppToFront(); 
	}, onBackgroundMessage: null); 
 }
 ```  
  
The above code will configure the the AppBlocker/App Redirect Plugin for use.  
  
Then as required, you can call methods on appBlocker.
| Method | Description |
|--|--|
| ```Future<bool> isEnabled()``` | Returns whether or not is AppBlocker is Enabled. |
| ```Future<bool> enableAppBlocker()``` | Enables the App Blocker to block the apps. |
| ```Future<bool> disableAppBlocker()``` | Disables the App Blocker. |
| ```Future<bool> setRestrictionTime(String startTime, String endTime)``` | Set the restriction time window for the App Blocker. The time string must be in HH:MM:SS 24 hours format. |
| ```Future<bool> resetRestrictionTime()``` | Resets the restriction time window for the App Blocker to block apps anytime of the day. |
| ```Future<Map<String, String>> getRestrictionTime()``` | Returns the map containing startTime and endTime for the restriction time period. |
| ```Future<bool> setRestrictionWeekDays(List<int> weekDays)``` | Set the weekdays when you want to App Blocker to block apps. Sunday (1) to Saturday (7).|
| ```Future<List<int>> getRestrictedWeekDays()``` | Returns the list of restricted week days for the plugin. |
| ```Future<bool> resetRestrictionWeekDays()``` | Resets the weekdays to be restricted |
| ```Future<bool> updateBlockedPackages(List<String> packages)``` | Blocks the given list of packages. To reset the blocked packages send an empty list. Each call send a full list of packages to be blocked. |
| ```Future<List<String>> getBlockedPackages()``` | Returns the list of blocked packages. |
| ```void bringAppToFront()``` | Call this method to bring app to front. You don't need to call this as you might have already done this on onResume handler of the configure function above. |
| ```Future<bool> isAppUsagePermissionGranted()``` | Returns Future bool whether or not the app usage permission is granted or not |
| ```void openAppUsageSettings()``` | Launch intent for the app usage permission screen for our app. |
| ```Future<bool> isBatteryOptimizationIgnored()``` | Returns Future bool whether the battery optimization for our app is ignored or not. |
| ```void openBatteryOptimizationSettings()``` | Opens Battery Optimization Ignore Popup/Screen |
| ```Future<bool> isOverlayPermissionGranted()``` | Returns Future bool whether the overlay permission is granted or not |
| ```void requestOverlayPermission()``` | Method to request for the overlay permission |