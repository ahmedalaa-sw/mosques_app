package com.example.mosques_app

import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val TIME_CHANNEL   = "com.example.mosques_app/time_format"
    private val SYSTEM_CHANNEL = "com.example.mosques_app/system"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TIME_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "is24HourFormat") {
                    val value = Settings.System.getString(
                        contentResolver,
                        Settings.System.TIME_12_24
                    )
                    result.success(value == "24")
                } else {
                    result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SYSTEM_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "canScheduleExactAlarms" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            val am = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                            result.success(am.canScheduleExactAlarms())
                        } else {
                            result.success(true)
                        }
                    }
                    "isIgnoringBatteryOptimizations" -> {
                        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                        result.success(pm.isIgnoringBatteryOptimizations(packageName))
                    }
                    "requestIgnoreBatteryOptimizations" -> {
                        try {
                            val intent = Intent(
                                Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                                Uri.parse("package:$packageName")
                            )
                            startActivity(intent)
                            result.success(null)
                        } catch (e: Exception) {
                            // Fallback: open general battery settings if specific intent fails
                            try {
                                startActivity(Intent(Settings.ACTION_BATTERY_SAVER_SETTINGS))
                            } catch (_: Exception) { /* ignore */ }
                            result.success(null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
