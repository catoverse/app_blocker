package club.cato.app_blocker.service.utils

import android.content.Context
import android.content.SharedPreferences

object PrefManager {
    private const val PREF_FILE = "appblocker_pref"
    private const val PREF_IS_ENABLED = "is_enabled"
    private const val PREF_BLACKLISTED_PACKAGES = "blacklist_package"

    private fun getPref(context: Context): SharedPreferences {
        return context.getSharedPreferences(PREF_FILE, Context.MODE_PRIVATE)
    }

    fun isAppBlockerEnabled(context: Context): Boolean {
        val pref = getPref(context)
        return pref.getBoolean(PREF_IS_ENABLED, false)
    }

    fun setAppBlockEnabled(context: Context, isEnabled: Boolean) {
        val pref = getPref(context)
        pref.edit().putBoolean(PREF_IS_ENABLED, isEnabled).apply()
    }

    fun getAllBlackListedPackages(context: Context): MutableSet<String> {
        return getPref(context).getStringSet(PREF_BLACKLISTED_PACKAGES, setOf()) ?: mutableSetOf()
    }

    fun blockPackage(context: Context, packageName: String) {
        val pref = getPref(context)
        val packages = getAllBlackListedPackages(context)
        packages.add(packageName)
        pref.edit().putStringSet(PREF_BLACKLISTED_PACKAGES, packages).apply()
    }

    fun unBlockPackage(context: Context, packageName: String) {
        val pref = getPref(context)
        val packages = getAllBlackListedPackages(context)
        packages.remove(packageName)
        pref.edit().putStringSet(PREF_BLACKLISTED_PACKAGES, packages).apply()
    }

}