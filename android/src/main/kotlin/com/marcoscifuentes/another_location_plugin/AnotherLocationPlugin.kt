package com.marcoscifuentes.another_location_plugin

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import com.google.android.gms.location.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** AnotherLocationPlugin */
class AnotherLocationPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel

    private val mapper = LocationMapper()
    private var context: Context? = null
    private var activity: Activity? = null
    private var fusedLocationClient: FusedLocationProviderClient? = null
    private var locationRequest: LocationRequest? = null
    private var locationCallback: LocationCallback? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "another_location_plugin")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

        when (call.method) {
            "initialize" -> initializePlugin(result)
            "checkPermission" -> onCheckPermission(result)
            "isLocationServiceEnabled" -> onIsLocationServiceEnabled(result)
            "requestPermission" -> onRequestPermission()
            "getLastKnownPosition" -> onGetLastKnownPosition(result)
            else -> result.notImplemented()
        }
    }

    private fun initializePlugin(result: Result) {
        fusedLocationClient = activity?.let { LocationServices.getFusedLocationProviderClient(it) }
        context?.run {
            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED
                    && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(activity!!, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION),
                        500)
            } else {
                locationRequest = LocationRequest.create();
                locationRequest?.priority = LocationRequest.PRIORITY_HIGH_ACCURACY;
                locationRequest?.interval = 20 * 1000;

                locationCallback = object : LocationCallback() {
                    override fun onLocationResult(locationResult: LocationResult) {
                    }
                }
                fusedLocationClient?.requestLocationUpdates(locationRequest, locationCallback, null)
            }
        }
        result.success(true)
    }

    private fun onGetLastKnownPosition(result: Result) {
        context?.run {
            locationRequest = LocationRequest.create();
            locationRequest?.priority = LocationRequest.PRIORITY_HIGH_ACCURACY;
            locationRequest?.interval = 20 * 1000;

            locationCallback = object : LocationCallback() {
                override fun onLocationResult(locationResult: LocationResult) {
                    if (locationResult == null) {
                        return
                    }
                }
            }
            fusedLocationClient?.requestLocationUpdates(locationRequest, locationCallback, null)
        }
        activity?.let {
            fusedLocationClient?.lastLocation?.addOnSuccessListener(it) { location: Location? ->
                result.success(mapper.toHashMap(location))
            }
            fusedLocationClient?.lastLocation?.addOnFailureListener {
                result.success(mapper.toHashMap(null))
            }
        }
    }

    private fun onRequestPermission() {
        context?.run {
            ActivityCompat.requestPermissions(activity!!, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION),
                    500)
        }
    }

    private fun onIsLocationServiceEnabled(result: Any) {

    }

    private fun onCheckPermission(result: Result) {
        context?.run {
            result.success(ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED
                    && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED)
        }
    }

    private fun generateRequestAndCallback() {
        context?.run {
            locationRequest = LocationRequest.create();
            locationRequest?.priority = LocationRequest.PRIORITY_HIGH_ACCURACY;
            locationRequest?.interval = 20 * 1000;

            locationCallback = object : LocationCallback() {
                override fun onLocationResult(locationResult: LocationResult) {
                    if (locationResult == null) {
                        return
                    }
                }
            }
            fusedLocationClient?.requestLocationUpdates(locationRequest, locationCallback, null)
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
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
}
