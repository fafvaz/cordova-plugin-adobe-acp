package com.adobe.marketing.mobile.cordova;

import static com.adobe.marketing.mobile.cordova.ACPPlacesMonitor_Cordova.PLACES_MONITOR_TAG;

import android.annotation.SuppressLint;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.adobe.marketing.mobile.Places;
import com.google.android.gms.location.Geofence;
import com.google.android.gms.location.GeofencingEvent;

public class GeofenceBroadcastReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        try {
            GeofencingEvent event = GeofencingEvent.fromIntent(intent);
            String transition = mapTransition(event.getGeofenceTransition());
            Log.d(PLACES_MONITOR_TAG, "Receiving broadcast Geofence " + transition);
            Places.processGeofenceEvent(event);
        } catch (Exception e) {
            Log.e(PLACES_MONITOR_TAG, "Erro no broadcast places monitor -> " + e.getMessage());
        }
    }

    @SuppressLint("VisibleForTests")
    private String mapTransition(int event) {
        switch (event) {
            case Geofence.GEOFENCE_TRANSITION_ENTER:
                return "ENTER";
            case Geofence.GEOFENCE_TRANSITION_EXIT:
                return "EXIT";
            default:
                return "UNKNOWN";
        }
    }
}
