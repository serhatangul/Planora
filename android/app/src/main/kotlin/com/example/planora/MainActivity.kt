package com.example.planora

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val storageChannelName = "planora/storage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val preferences = getSharedPreferences("planora_storage", Context.MODE_PRIVATE)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, storageChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getString" -> {
                        val key = call.argument<String>("key")
                        if (key.isNullOrBlank()) {
                            result.error("INVALID_ARGUMENTS", "Missing storage key", null)
                        } else {
                            result.success(preferences.getString(key, null))
                        }
                    }

                    "setString" -> {
                        val key = call.argument<String>("key")
                        val value = call.argument<String>("value")

                        if (key.isNullOrBlank() || value == null) {
                            result.error("INVALID_ARGUMENTS", "Missing storage key or value", null)
                        } else {
                            val saved = preferences.edit().putString(key, value).commit()
                            if (saved) {
                                result.success(null)
                            } else {
                                result.error("STORAGE_ERROR", "Failed to save data", null)
                            }
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
