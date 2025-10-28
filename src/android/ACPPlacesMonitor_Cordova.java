package com.adobe.marketing.mobile.cordova;


import android.annotation.SuppressLint;
import android.app.PendingIntent;
import android.content.Intent;
import android.location.Location;
import android.os.Build;
import android.os.Looper;
import android.util.Log;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.Geofence;
import com.google.android.gms.location.GeofencingClient;
import com.google.android.gms.location.GeofencingRequest;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

public class ACPPlacesMonitor_Cordova extends CordovaPlugin {

    public static final String PLACES_MONITOR_TAG = "PLACES_MONITOR";
    private static final String ERROR_MONITOR_NOT_STARTED = "Monitor not started";
    private static final String ERROR_GPS_ISSUE = "GPS Permission Issues";
    private static final String OK_MONITORING = "Monitoring";
    private static final String OK_MONITORING_REGION = "Monitoring Region";
    private static final String OK_STOPPED = "Stopped";
    private static boolean STARTED = false;
    private static final String ACCESS_FINE_LOCATION = "android.permission.ACCESS_FINE_LOCATION";
    private static final String ACCESS_COARSE_LOCATION = "android.permission.ACCESS_COARSE_LOCATION";
    private static final String ACCESS_BACKGROUND_LOCATION = "android.permission.ACCESS_BACKGROUND_LOCATION";

    private static final int REQUEST_CODE_ENABLE_PERMISSION = -1020;
    private FusedLocationProviderClient fusedLocationClient;
    private GeofencingClient geofencingClient;
    private PendingIntent geofencePendingIntent;
    private LocationCallback locationCallback;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {

        if ("start".equals(action)) {
            this.start(callbackContext);
            return true;
        } else if (action.equals("updateLocation")) {
            this.updateLocation(callbackContext);
            return true;
        } else if (action.equals("startMonitoringForRegion")) {
            this.startMonitoringForRegion(args, callbackContext);
            return true;
        } else if (action.equals("stop")) {
            this.stop(callbackContext);
            return true;
        }

        return false;
    }

    private void start(final CallbackContext callbackContext) {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            //https://developer.android.com/develop/sensors-and-location/location/permissions#approximate-request
            if (!cordova.hasPermission(ACCESS_FINE_LOCATION)) {
                callbackContext.error(ERROR_GPS_ISSUE);
                cordova.requestPermissions(this, REQUEST_CODE_ENABLE_PERMISSION,
                        new String[]{ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION});
            } else if (!cordova.hasPermission(ACCESS_BACKGROUND_LOCATION)) {
                callbackContext.error(ERROR_GPS_ISSUE);
                cordova.requestPermission(this, REQUEST_CODE_ENABLE_PERMISSION, ACCESS_BACKGROUND_LOCATION);
            } else {
                STARTED = true;
                startLocationUpdates();
                callbackContext.success(OK_MONITORING);
            }
        } else {
            if (!cordova.hasPermission(ACCESS_FINE_LOCATION)) {
                callbackContext.error(ERROR_GPS_ISSUE);
                cordova.requestPermission(this, REQUEST_CODE_ENABLE_PERMISSION, ACCESS_FINE_LOCATION);
            } else if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q && !cordova.hasPermission(ACCESS_BACKGROUND_LOCATION)) {
                callbackContext.error(ERROR_GPS_ISSUE);
                cordova.requestPermission(this, REQUEST_CODE_ENABLE_PERMISSION, ACCESS_BACKGROUND_LOCATION);
            } else {
                STARTED = true;
                startLocationUpdates();
                callbackContext.success(OK_MONITORING);
            }
        }
    }

    @SuppressLint("MissingPermission")
    private void updateLocation(final CallbackContext callbackContext) {
        if (STARTED) {
            fusedLocationClient.getLastLocation()
                    .addOnSuccessListener(this.cordova.getActivity(), location -> {
                        if (location != null) {
                            System.out.println("location:: " + location);
                            callbackContext.success(OK_MONITORING);
                        }

                    });
        } else {
            callbackContext.error(ERROR_MONITOR_NOT_STARTED);
        }
    }

    @SuppressLint({"MissingPermission", "VisibleForTests"})
    private void startMonitoringForRegion(final JSONArray args, final CallbackContext callbackContext) {

        if (STARTED) {
            try {
                double lat = args.getDouble(0);
                double lng = args.getDouble(1);
                double radius = args.getDouble(2);
                String identifier = args.getString(3);

                final Geofence geofence = new Geofence.Builder()
                        .setRequestId(identifier)
                        .setCircularRegion(lat, lng, (float) radius)
                        .setExpirationDuration(Geofence.NEVER_EXPIRE)
                        .setTransitionTypes(Geofence.GEOFENCE_TRANSITION_ENTER |
                                Geofence.GEOFENCE_TRANSITION_EXIT)
                        .build();

                GeofencingRequest geofencingRequest = new GeofencingRequest.Builder()
                        .addGeofence(geofence)
                        .setInitialTrigger(GeofencingRequest.INITIAL_TRIGGER_ENTER)
                        .build();
                geofencingClient.addGeofences(geofencingRequest, getGeofencePendingIntent())
                        .addOnSuccessListener(cordova.getActivity(), aVoid -> callbackContext.success(OK_MONITORING_REGION))
                        .addOnFailureListener(cordova.getActivity(), e -> callbackContext.error(e.getMessage()));
            } catch (Exception e) {
                callbackContext.error(e.getMessage());
            }
        } else {
            callbackContext.error(ERROR_MONITOR_NOT_STARTED);
        }

    }

    private void stop(final CallbackContext callbackContext) {
        STARTED = false;
        geofencingClient.removeGeofences(getGeofencePendingIntent());
        fusedLocationClient.removeLocationUpdates(locationCallback);
        callbackContext.success(OK_STOPPED);
    }

    private PendingIntent getGeofencePendingIntent() {
        if (geofencePendingIntent != null) {
            return geofencePendingIntent;
        }
        Intent intent = new Intent(this.cordova.getActivity(), GeofenceBroadcastReceiver.class);
        geofencePendingIntent = PendingIntent.getBroadcast(this.cordova.getActivity(), 0, intent,
                PendingIntent.FLAG_MUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);
        return geofencePendingIntent;
    }

    @Override
    protected void pluginInitialize() {
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(cordova.getActivity());
        geofencingClient = LocationServices.getGeofencingClient(cordova.getActivity());
        locationCallback = new LocationCallback() {
            @Override
            public void onLocationResult(LocationResult locationResult) {
                if (locationResult == null) {
                    return;
                }
                for (Location location : locationResult.getLocations()) {
                    Log.d("LOCATION", location.toString());
                }
            }
        };
    }

    @SuppressLint("MissingPermission")
    private void startLocationUpdates() {

        LocationRequest locationRequest = new LocationRequest();
        locationRequest.setInterval(10000);
        locationRequest.setFastestInterval(5000);
        locationRequest.setPriority(LocationRequest.PRIORITY_BALANCED_POWER_ACCURACY);
        fusedLocationClient.requestLocationUpdates(locationRequest,
                locationCallback,
                Looper.getMainLooper());
    }
}