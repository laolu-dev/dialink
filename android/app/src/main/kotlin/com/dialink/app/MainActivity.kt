package com.dialink.app

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    /** The launcher alias to switch to once the app leaves the screen. */
    private var pendingIcon: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // The app icon follows the theme. Each icon is an <activity-alias>
        // in AndroidManifest.xml; null is the default (Clinical).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dialink/app_icon")
            .setMethodCallHandler { call, result ->
                if (call.method != "setIcon") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                // The theme, e.g. "Sage", or null for the primary icon.
                val alias = (call.arguments as? String)?.let { "Launcher$it" } ?: DEFAULT_ALIAS
                if (alias !in ALIASES) {
                    result.error("icon", "Unknown icon $alias", null)
                    return@setMethodCallHandler
                }
                pendingIcon = alias
                result.success(true)
            }
    }

    // Switching the launcher component can close the app and drop its
    // shortcuts, so it waits until the app is in the background.
    override fun onStop() {
        super.onStop()
        val alias = pendingIcon ?: return
        pendingIcon = null

        for (name in ALIASES) {
            val state = if (name == alias) {
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            } else {
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED
            }
            // The aliases live in the code's package, which the dev build's
            // application ID (".dev") doesn't match.
            val component = ComponentName(packageName, "${javaClass.`package`!!.name}.$name")
            if (packageManager.getComponentEnabledSetting(component) != state) {
                packageManager.setComponentEnabledSetting(
                    component, state, PackageManager.DONT_KILL_APP,
                )
            }
        }
    }

    private companion object {
        const val DEFAULT_ALIAS = "LauncherClinical"
        val ALIASES = listOf(
            "LauncherClinical",
            "LauncherSage",
            "LauncherSunset",
            "LauncherMidnight",
            "LauncherHighContrast",
            "LauncherEasyRead",
        )
    }
}
