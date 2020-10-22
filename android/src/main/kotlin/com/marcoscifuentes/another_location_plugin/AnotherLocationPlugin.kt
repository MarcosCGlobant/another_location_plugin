package com.marcoscifuentes.another_location_plugin

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.app.ActivityCompat.startActivityForResult
import com.google.android.gms.location.*
import com.marcoscifuentes.another_location_plugin.ForOrderActivity.Companion.ORDER
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry


/** AnotherLocationPlugin */
class AnotherLocationPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    private lateinit var channel: MethodChannel

    private val mapper = LocationMapper()
    private var context: Context? = null
    private var activity: Activity? = null
    private var fusedLocationClient: FusedLocationProviderClient? = null
    private var locationRequest: LocationRequest? = null
    private var locationCallback: LocationCallback? = null

    private var locationEventSource: EventChannel.EventSink? = null
    private var activityEventSource: EventChannel.EventSink? = null
    private var locationEventChannel: EventChannel? = null
    private var activityEventChannel: EventChannel? = null

    private var locationListener: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            locationEventSource = events
        }

        override fun onCancel(arguments: Any?) {
            locationEventSource = null
        }
    }

    private var activityListener: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            activityEventSource = events
        }

        override fun onCancel(arguments: Any?) {
            activityEventSource = null
        }
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "another_location_plugin")
        channel.setMethodCallHandler(this)
        locationEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "location_event_channel")
        locationEventChannel?.setStreamHandler(locationListener)
        activityEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "activity_event_channel")
        activityEventChannel?.setStreamHandler(activityListener)

    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

        when (call.method) {
            "initialize" -> initializePlugin(result)
            "isLocationServiceEnabled" -> onIsLocationServiceEnabled(result)
            "getLastKnownPosition" -> onGetLastKnownPosition(result)
            "requestActivityForResult" -> onRequestActivityForResult(result)
            "requestPermission" -> onRequestPermission()
            "checkPermission" -> onCheckPermissions(result)
            "stopLocationUpdates" -> onStopLocationUpdates(result)
            else -> result.notImplemented()
        }
    }

    private fun initializePlugin(result: Result) {
        fusedLocationClient = activity?.let { LocationServices.getFusedLocationProviderClient(it) }
        context?.run {
            if (checkPermissionIsDenied()) {
                result.success(false)
            } else {
                locationRequest = LocationRequest.create()
                locationRequest?.priority = LocationRequest.PRIORITY_HIGH_ACCURACY
                locationRequest?.interval = 2000

                locationCallback = object : LocationCallback() {
                    override fun onLocationResult(locationResult: LocationResult) {
                        Log.d("HARRYLOG", "${locationResult.lastLocation.latitude},${locationResult.lastLocation.longitude}")
                        locationEventSource?.success(mapper.toHashMap(locationResult.lastLocation))
                    }
                }
                result.success(true)
            }
        }
    }

    private fun checkPermissionIsDenied(): Boolean {
        var permitted = false
        context?.run {
            permitted = ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED
                    && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED
        }
        return permitted
    }

    private fun onCheckPermissions(result: Result) {
        result.success(checkPermissionIsDenied())
    }

    private fun onRequestPermission() {
        context?.run {
            ActivityCompat.requestPermissions(activity!!, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION),
                    500)
        }
    }

    private fun onGetLastKnownPosition(result: Result) {
        activity?.let {
            fusedLocationClient?.requestLocationUpdates(locationRequest, locationCallback, null)
            fusedLocationClient?.lastLocation?.addOnSuccessListener(it) { location: Location? ->
                result.success(mapper.toHashMap(location))
            }
            fusedLocationClient?.lastLocation?.addOnFailureListener {
                result.success(mapper.toHashMap(null))
            }
        }
    }

    private fun onIsLocationServiceEnabled(result: Any) {

    }

    private fun onRequestActivityForResult(result: Result) {
        val launchSecondActivity = 639
        result.success(true)
        startActivityForResult(activity!!, context?.let { ForOrderActivity.getIntent(it) }!!, launchSecondActivity, null)
    }

    private fun onStopLocationUpdates(result: Result) {
        context?.run {
            fusedLocationClient?.removeLocationUpdates(locationCallback)
        }
        result.success(true)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == 639) {
            if (resultCode == Activity.RESULT_OK) {
                Log.d("ACTIVITYHARRYLOG", "${data?.getStringExtra(ORDER)}")
                activityEventSource?.success(data?.getStringExtra(ORDER))
                return true
            }
        }
        return false
    }
}
