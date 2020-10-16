package com.marcoscifuentes.another_location_plugin

import android.location.Location
import android.os.Build

class LocationMapper {
    fun toHashMap(location: Location?): Map<String, Any>? {
        val position: MutableMap<String, Any> = mutableMapOf()
        if (location == null) {
            position["status"] = "null location"
            return position
        }

        position["latitude"] = location.latitude
        position["longitude"] = location.longitude
        position["timestamp"] = location.time
        if (location.hasAltitude()) position["altitude"] = location.altitude
        if (location.hasAccuracy()) position["accuracy"] = location.accuracy.toDouble()
        if (location.hasBearing()) position["heading"] = location.bearing.toDouble()
        if (location.hasSpeed()) position["speed"] = location.speed.toDouble()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && location.hasSpeedAccuracy()) position["speed_accuracy"] = location.speedAccuracyMetersPerSecond.toDouble()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
            position["is_mocked"] = location.isFromMockProvider
        } else {
            position["is_mocked"] = false
        }
        return position
    }
}
