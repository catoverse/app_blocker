package club.cato.app_blocker

import android.app.Activity
import android.content.ContentValues.TAG
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.annotation.NonNull
import club.cato.app_blocker.service.AppBlockerService
import club.cato.app_blocker.service.ServiceStarter
import club.cato.app_blocker.service.utils.PrefManager
import club.cato.app_blocker.service.worker.WorkerStarter
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar


/** AppBlockerPlugin */
class AppBlockerPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.NewIntentListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var applicationContext: Context
  private var mainActivity: Activity? = null

  private fun onAttachedToEngine(context: Context, binaryMessenger: BinaryMessenger) {
    applicationContext = context
    channel = MethodChannel(binaryMessenger, "club.cato/app_blocker")
    channel.setMethodCallHandler(this)

    val backgroundCallbackChannel = MethodChannel(binaryMessenger, "club.cato/app_blocker_background")
    backgroundCallbackChannel.setMethodCallHandler(this)
    AppBlockerService.setBackgroundChannel(backgroundCallbackChannel)
  }

  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    onAttachedToEngine(binding.applicationContext, binding.binaryMessenger);
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {

  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    binding.addOnNewIntentListener(this)
    mainActivity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    mainActivity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    binding.addOnNewIntentListener(this)
    mainActivity = binding.activity
  }

  override fun onDetachedFromActivity() {
    mainActivity = null
  }


  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

    /*  Even when the app is not active the `FirebaseMessagingService` extended by
     *  `FlutterFirebaseMessagingService` allows incoming FCM messages to be handled.
     *
     *  `FcmDartService#start` and `FcmDartService#initialized` are the two methods used
     *  to optionally setup handling messages received while the app is not active.
     *
     *  `FcmDartService#start` sets up the plumbing that allows messages received while
     *  the app is not active to be handled by a background isolate.
     *
     *  `FcmDartService#initialized` is called by the Dart side when the plumbing for
     *  background message handling is complete.
     */
    if("enableAppBlocker" == call.method) {
      result.success(enableAppBlocker())
    } else {
      result.notImplemented()
    }
  }

  override fun onNewIntent(intent: Intent): Boolean {
    return true
//    val res: Boolean = sendMessageFromIntent("onResume", intent)
//    if (res && mainActivity != null) {
//      mainActivity!!.intent = intent
//    }
//    return res
  }

  private fun sendMessageFromIntent(method: String, intent: Intent): Boolean {
//    if (CLICK_ACTION_VALUE.equals(intent.action)
//            || CLICK_ACTION_VALUE.equals(intent.getStringExtra("click_action"))) {
//      val message: MutableMap<String, Any> = HashMap()
//      val extras = intent.extras ?: return false
//      val notificationMap: Map<String, Any> = HashMap()
//      val dataMap: MutableMap<String, Any> = HashMap()
//      for (key in extras.keySet()) {
//        val extra = extras[key]
//        if (extra != null) {
//          dataMap[key] = extra
//        }
//      }
//      message["notification"] = notificationMap
//      message["data"] = dataMap
//      channel.invokeMethod(method, message)
//      return true
//    }
    return false
  }

  private fun disableAppBlocker(): Boolean {
    if(!::applicationContext.isInitialized) return false
    PrefManager.setAppBlockEnabled(applicationContext, false)
    WorkerStarter.stopServiceCheckerWorker()
    ServiceStarter.stopService(applicationContext)
    return true
  }

  private fun enableAppBlocker(): Boolean {
    Log.d("🙏", "Enabling AppBlocker")
    if(!::applicationContext.isInitialized) return false
    Log.d("🙏", "AppBlocker State Passed")
    PrefManager.setAppBlockEnabled(applicationContext, true)
    ServiceStarter.startService(applicationContext)
    WorkerStarter.startServiceCheckerWorker()
    return true
  }

  private fun blockUnBlockApp(packageName: String, shouldBlock: Boolean = true): Boolean {
    if(!::applicationContext.isInitialized) return false

    if(shouldBlock) {
      PrefManager.blockPackage(applicationContext, packageName)
    } else {
      PrefManager.unBlockPackage(applicationContext, packageName)
    }
    return true
  }

  private fun getAllBlockApps(): MutableSet<String>? {
    if(!::applicationContext.isInitialized) return null
    return PrefManager.getAllBlackListedPackages(applicationContext)
  }


  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val instance = AppBlockerPlugin()
      instance.mainActivity = registrar.activity()
      registrar.addNewIntentListener(instance)
      instance.onAttachedToEngine(registrar.context(), registrar.messenger())
    }

    fun getLauncherIntentFromAppContext(context: Context): Intent? {

      val appPackage = context.applicationContext.packageName
      return context.packageManager.getLaunchIntentForPackage(appPackage)
    }
  }
}
