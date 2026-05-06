package com.example.mosques_app

import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.mosques_app/time_format"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "is24HourFormat") {
                    // Read the LIVE system setting — not a cached value.
                    val value = Settings.System.getString(
                        contentResolver,
                        Settings.System.TIME_12_24
                    )
                    // "24" means 24-hour, anything else (null / "12") means 12-hour.
                    result.success(value == "24")
                } else {
                    result.notImplemented()
                }
            }
    }
}
