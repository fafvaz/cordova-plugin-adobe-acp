/*
Copyright 2020 Adobe. All rights reserved.
This file is licensed to you under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License. You may obtain a copy
of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under
the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
OF ANY KIND, either express or implied. See the License for the specific language
governing permissions and limitations under the License.
*/

package com.adobe.marketing.mobile.cordova;

import static android.content.Intent.getIntent;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;

import androidx.core.app.NotificationManagerCompat;

import com.adobe.marketing.mobile.Analytics;
import com.adobe.marketing.mobile.Assurance;
import com.adobe.marketing.mobile.Campaign;
import com.adobe.marketing.mobile.Event;
import com.adobe.marketing.mobile.Extension;
import com.adobe.marketing.mobile.Identity;
import com.adobe.marketing.mobile.Lifecycle;
import com.adobe.marketing.mobile.LoggingMode;
import com.adobe.marketing.mobile.MobileCore;
import com.adobe.marketing.mobile.MobilePrivacyStatus;
import com.adobe.marketing.mobile.MobileServices;
import com.adobe.marketing.mobile.Places;
import com.adobe.marketing.mobile.Signal;
import com.adobe.marketing.mobile.Target;
import com.adobe.marketing.mobile.UserProfile;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PermissionHelper;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Objects;

public class ACPCore_Cordova extends CordovaPlugin {
    final static String METHOD_CORE_DISPATCH_EVENT = "dispatchEvent";
    final static String METHOD_CORE_DISPATCH_EVENT_WITH_RESPONSE_CALLBACK = "dispatchEventWithResponseCallback";
    final static String METHOD_CORE_DISPATCH_RESPONSE_EVENT = "dispatchResponseEvent";
    final static String METHOD_CORE_DOWNLOAD_RULES = "downloadRules";
    final static String METHOD_CORE_EXTENSION_VERSION_CORE = "extensionVersion";
    final static String METHOD_CORE_GET_PRIVACY_STATUS = "getPrivacyStatus";
    final static String METHOD_CORE_GET_SDK_IDENTITIES = "getSdkIdentities";
    final static String METHOD_CORE_SET_ADVERTISING_IDENTIFIER = "setAdvertisingIdentifier";
    final static String METHOD_CORE_SET_LOG_LEVEL = "setLogLevel";
    final static String METHOD_CORE_SET_PRIVACY_STATUS = "setPrivacyStatus";
    final static String METHOD_CORE_TRACK_ACTION = "trackAction";
    final static String METHOD_CORE_TRACK_STATE = "trackState";
    final static String METHOD_CORE_UPDATE_CONFIGURATION = "updateConfiguration";
    final static String METHOD_CORE_GET_APP_ID = "getAppId";
    final static String METHOD_CORE_OPEN_DEEPLINK = "openDeepLink";

    final static String METHOD_CORE_PUSH_GET_STATUS = "getPushNotificationStatus";
    final static String METHOD_CORE_PUSH_REQUEST_PERMISSION = "requestPushNotificationPermission";
    final static int PERMISSION_REQUEST_CODE = 20230426;
    
    private static final String PERMISSION_POST_NOTIFICATIONS = "android.permission.POST_NOTIFICATIONS";

    private String appId;
    private String initTime;
    private CallbackContext _tmpCallbackContext;

    public static ACPCore_Cordova intance;
    
    // ===============================================================
    // all calls filter through this method
    // ===============================================================
    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {

        if (METHOD_CORE_DISPATCH_EVENT.equals(action)) {
            this.dispatchEvent(args, callbackContext);
            return true;
        } else if (METHOD_CORE_DISPATCH_EVENT_WITH_RESPONSE_CALLBACK.equals(action)) {
            this.dispatchEventWithResponseCallback(args, callbackContext);
            return true;
        } else if (METHOD_CORE_DISPATCH_RESPONSE_EVENT.equals(action)) {
            this.dispatchResponseEvent(args, callbackContext);
            return true;
        } else if (METHOD_CORE_DOWNLOAD_RULES.equals(action)) {
            this.downloadRules(callbackContext);
            return true;
        } else if (METHOD_CORE_EXTENSION_VERSION_CORE.equals(action)) {
            this.extensionVersion(callbackContext);
            return true;
        } else if (METHOD_CORE_GET_PRIVACY_STATUS.equals(action)) {
            this.getPrivacyStatus(callbackContext);
            return true;
        } else if (METHOD_CORE_GET_SDK_IDENTITIES.equals(action)) {
            this.getSdkIdentities(callbackContext);
            return true;
        } else if (METHOD_CORE_SET_ADVERTISING_IDENTIFIER.equals(action)) {
            this.setAdvertisingIdentifier(args, callbackContext);
            return true;
        } else if (METHOD_CORE_SET_LOG_LEVEL.equals(action)) {
            this.setLogLevel(args, callbackContext);
            return true;
        } else if (METHOD_CORE_SET_PRIVACY_STATUS.equals(action)) {
            this.setPrivacyStatus(args, callbackContext);
            return true;
        } else if (METHOD_CORE_TRACK_ACTION.equals(action)) {
            this.trackAction(args, callbackContext);
            return true;
        } else if (METHOD_CORE_TRACK_STATE.equals(action)) {
            this.trackState(args, callbackContext);
            return true;
        } else if (METHOD_CORE_UPDATE_CONFIGURATION.equals(action)) {
            this.updateConfiguration(args, callbackContext);
            return true;
        } else if (METHOD_CORE_GET_APP_ID.equals(action)) {
            this.getAppId(callbackContext);
            return true;
        }  else if (METHOD_CORE_PUSH_GET_STATUS.equals(action)) {
            this.getPushNotificationStatus(callbackContext);
            return true;
        }  else if (METHOD_CORE_PUSH_REQUEST_PERMISSION.equals(action)) {
            this.requestPushNotificationPermission(callbackContext);
            return true;
        }  else if (METHOD_CORE_OPEN_DEEPLINK.equals(action)) {
            this.openScreenByDeepLink(args.getString(0));
            return true;
        }
        
        return false;
    }
    
    // ===============================================================
    // MobileCore Methods
    // ===============================================================
    private void dispatchEvent(final JSONArray args, final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(() -> {
            try {
                final HashMap<String, Object> eventMap = getObjectMapFromJSON(args.getJSONObject(0));
                final Event event = getEventFromMap(eventMap);

                MobileCore.dispatchEvent(event, extensionError -> callbackContext.error(extensionError.getErrorName()));

                callbackContext.success();
            } catch (Exception ex) {
                final String errorMessage = String.format("Exception in call to dispatchEvent: %s",
                ex.getLocalizedMessage());
                MobileCore.log(LoggingMode.WARNING, "AEP SDK", errorMessage);
                callbackContext.error(errorMessage);
            }
        });
    }
    
    private void dispatchEventWithResponseCallback(final JSONArray args, final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(() -> {
            try {
                final HashMap<String, Object> eventMap = getObjectMapFromJSON(args.getJSONObject(0));
                final Event event = getEventFromMap(eventMap);
                
                MobileCore.dispatchEventWithResponseCallback(event, event1 -> {
                    final HashMap<String, Object> eventMap1 = getMapFromEvent(event1);
                    final JSONObject eventJson = new JSONObject(eventMap1);
                    callbackContext.success(eventJson);
                }, extensionError -> callbackContext.error(extensionError.getErrorName()));
                
                callbackContext.success();
            } catch (Exception ex) {
                final String errorMessage = String.format(
                "Exception in call to dispatchEventWithResponseCallback: %s", ex.getLocalizedMessage());
                MobileCore.log(LoggingMode.WARNING, "AEP SDK", errorMessage);
                callbackContext.error(errorMessage);
            }
        });
    }
    
    private void dispatchResponseEvent(final JSONArray args, final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(() -> {
            try {
                final HashMap<String, Object> responseEventMap = getObjectMapFromJSON(args.getJSONObject(0));
                final Event responseEvent = getEventFromMap(responseEventMap);
                final HashMap<String, Object> requestEventMap = getObjectMapFromJSON(args.getJSONObject(1));
                final Event requestEvent = getEventFromMap(requestEventMap);

                MobileCore.dispatchResponseEvent(responseEvent, requestEvent,
                        extensionError -> callbackContext.error(extensionError.getErrorName()));

                callbackContext.success();
            } catch (Exception ex) {
                final String errorMessage = String.format("Exception in call to dispatchResponseEvent: %s",
                ex.getLocalizedMessage());
                MobileCore.log(LoggingMode.WARNING, "AEP SDK", errorMessage);
                callbackContext.error(errorMessage);
            }
        });
    }
    
    private void downloadRules(final CallbackContext callbackContext) {
        // TODO: this method is not implemented in Android
        cordova.getThreadPool().execute(callbackContext::success);
    }
    
    private void extensionVersion(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(() -> {
            final String version = initTime + ": " + MobileCore.extensionVersion();
            callbackContext.success(version);
        });
    }
    
    private void getPrivacyStatus(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(() -> MobileCore.getPrivacyStatus(mobilePrivacyStatus -> callbackContext.success(mobilePrivacyStatus.getValue())));
    }
    
    private void getSdkIdentities(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(() -> MobileCore.getSdkIdentities(callbackContext::success));
    }
    
    private void setAdvertisingIdentifier(final JSONArray args, final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(() -> {
            try {
                final String newAdId = args.getString(0);
                MobileCore.setAdvertisingIdentifier(newAdId);
                callbackContext.success();
            } catch (final Exception ex) {
                final String errorMessage = String.format("Exception in call to setAdvertisingIdentifier: %s",
                ex.getLocalizedMessage());
                MobileCore.log(LoggingMode.WARNING, "AEP SDK", errorMessage);
                callbackContext.error(errorMessage);
            }
        });
    }
    
    private void setLogLevel(final JSONArray args, final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(() -> {
            try {
                LoggingMode newLogLevel;
                switch (args.getInt(0)) {
                    case 0:
                    default:
                    newLogLevel = LoggingMode.ERROR;
                    break;
                    case 1:
                    newLogLevel = LoggingMode.WARNING;
                    break;
                    case 2:
                    newLogLevel = LoggingMode.DEBUG;
                    break;
                    case 3:
                    newLogLevel = LoggingMode.VERBOSE;
                    break;
                }
                MobileCore.setLogLevel(newLogLevel);
                callbackContext.success();
            } catch (final Exception ex) {
                final String errorMessage = String.format("Exception in call to setLogLevel: %s",
                ex.getLocalizedMessage());
                MobileCore.log(LoggingMode.WARNING, "AEP SDK", errorMessage);
                callbackContext.error(errorMessage);
            }
        });
    }
    
    private void setPrivacyStatus(final JSONArray args, final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(() -> {
            try {
                MobilePrivacyStatus newPrivacyStatus;
                switch (args.getInt(0)) {
                    case 0:
                    newPrivacyStatus = MobilePrivacyStatus.OPT_IN;
                    break;
                    case 1:
                    newPrivacyStatus = MobilePrivacyStatus.OPT_OUT;
                    break;
                    case 2:
                    default:
                    newPrivacyStatus = MobilePrivacyStatus.UNKNOWN;
                    break;
                }
                MobileCore.setPrivacyStatus(newPrivacyStatus);
                callbackContext.success();
            } catch (final Exception ex) {
                final String errorMessage = String.format("Exception in call to setPrivacyStatus: %s",
                ex.getLocalizedMessage());
                MobileCore.log(LoggingMode.WARNING, "AEP SDK", errorMessage);
                callbackContext.error(errorMessage);
            }
        });
    }
    
    private void trackAction(final JSONArray args, final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(() -> {
            try {
                final String action = args.getString(0);
                final HashMap<String, String> contextData = getStringMapFromJSON(args.getJSONObject(1));
                MobileCore.trackAction(action, contextData);
                callbackContext.success();
            } catch (final Exception ex) {
                final String errorMessage = String.format("Exception in call to trackAction: %s",
                ex.getLocalizedMessage());
                MobileCore.log(LoggingMode.WARNING, "AEP SDK", errorMessage);
                callbackContext.error(errorMessage);
            }
        });
    }
    
    private void trackState(final JSONArray args, final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(() -> {
            try {
                final String state = args.getString(0);
                final HashMap<String, String> contextData = getStringMapFromJSON(args.getJSONObject(1));

                MobileCore.trackState(state, contextData);
                callbackContext.success();
                System.out.println("Passei no trackstate");
            } catch (final Exception ex) {
                final String errorMessage = String.format("Exception in call to trackState: %s",
                ex.getLocalizedMessage());
                MobileCore.log(LoggingMode.WARNING, "AEP SDK", errorMessage);
                callbackContext.error(errorMessage);
            }
        });
    }
    
    private void updateConfiguration(final JSONArray args, final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(() -> {
            try {
                final HashMap<String, Object> newConfig = getObjectMapFromJSON(args.getJSONObject(0));

                MobileCore.updateConfiguration(newConfig);
                callbackContext.success();
            } catch (final Exception ex) {
                final String errorMessage = String.format("Exception in call to updateConfiguration: %s",
                ex.getLocalizedMessage());
                MobileCore.log(LoggingMode.WARNING, "AEP SDK", errorMessage);
                callbackContext.error(errorMessage);
            }
        });
    }

    private void getAppId(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(() -> callbackContext.success(appId));
    }
    
    // ===============================================================
    // Helpers
    // ===============================================================
    private HashMap<String, String> getStringMapFromJSON(JSONObject data) {
        HashMap<String, String> map = new HashMap<String, String>();
        @SuppressWarnings("rawtypes")
        Iterator it = data.keys();
        while (it.hasNext()) {
            String n = (String) it.next();
            try {
                map.put(n, data.getString(n));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        
        return map;
    }
    
    private HashMap<String, Object> getObjectMapFromJSON(JSONObject data) {
        HashMap<String, Object> map = new HashMap<>();
        @SuppressWarnings("rawtypes")
        Iterator it = data.keys();
        while (it.hasNext()) {
            String n = (String) it.next();
            try {
                map.put(n, data.getString(n));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        
        return map;
    }
    
    private Event getEventFromMap(final HashMap<String, Object> event) throws Exception {
        return new Event.Builder(Objects.requireNonNull(event.get("name")).toString(), Objects.requireNonNull(event.get("type")).toString(),
        Objects.requireNonNull(event.get("source")).toString())
        .setEventData(getObjectMapFromJSON(new JSONObject(Objects.requireNonNull(event.get("data")).toString()))).build();
    }
    
    private HashMap<String, Object> getMapFromEvent(final Event event) {
        final HashMap<String, Object> eventMap = new HashMap<>();
        eventMap.put("name", event.getName());
        eventMap.put("type", event.getType());
        eventMap.put("source", event.getSource());
        eventMap.put("data", event.getEventData());
        
        return eventMap;
    }
    
    private void getPushNotificationStatus(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(() -> {
            try {
                NotificationManagerCompat notificationManagerCompat = NotificationManagerCompat.from(cordova.getActivity());
                callbackContext.success(String.valueOf(notificationManagerCompat.areNotificationsEnabled()));
            } catch (Exception e) {
                callbackContext.error(e.getMessage());
            }
        });
    }
    
    private void requestPushNotificationPermission(final CallbackContext callbackContext) {
        if(Build.VERSION.SDK_INT >= 33){ // Android 13+
            _tmpCallbackContext = callbackContext;
            String[] permissions = {PERMISSION_POST_NOTIFICATIONS};
            PermissionHelper.requestPermissions(this, PERMISSION_REQUEST_CODE, permissions);
        } else {
            callbackContext.success("GRANTED");
        }
    }

    @Override
    public void onRequestPermissionResult(int requestCode, String[] permissions,
    int[] grantResults) {
        for(int r:grantResults)
        {
            if(r == PackageManager.PERMISSION_DENIED)
            {
                this._tmpCallbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "NO_PERMISSION"));
                return;
            }
        }
        if(requestCode == PERMISSION_REQUEST_CODE) {
            this._tmpCallbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, "GRANTED"));
        }
        
    }

    @Override
    public void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        final Bundle data = intent.getExtras();

        if (data != null && data.containsKey("google.message_id")) {
            ACPFirebaseMessagingService.handleMessage(data);
        }
    }
 
    // ===============================================================
    // Plugin lifecycle events
    // ===============================================================
    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        MobileCore.setApplication(this.cordova.getActivity().getApplication());
        MobileCore.setLogLevel(LoggingMode.VERBOSE);
        new ACPFirebaseMessagingService();
        intance = this;

        appId = cordova.getActivity().getString(cordova.getActivity().getResources().getIdentifier("AppId", "string", cordova.getActivity().getPackageName()));
        
        try {

            MobileCore.configureWithAppID(appId);
            List<Class<? extends Extension>> extensions = new ArrayList<>();
            extensions.add(Campaign.EXTENSION);
            extensions.add(Places.EXTENSION);
            extensions.add(Analytics.EXTENSION);
            extensions.add(Target.EXTENSION);
            extensions.add(UserProfile.EXTENSION);
            extensions.add(Identity.EXTENSION);
            extensions.add(Lifecycle.EXTENSION);
            extensions.add(Signal.EXTENSION);
            extensions.add(Assurance.EXTENSION);

            MobileCore.registerExtensions(extensions, o -> {
                Log.d("ACP_CORE", "AEP Mobile SDK is initialized");
            });

            MobileServices.registerExtension();
            
        } catch (Exception e) {
            Log.d("ACP_CORE", "Erro ao inicializar o SDK");
        }
        
        initTime = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new java.util.Date());
    }
    
    
    @Override
    public void onPause(boolean multitasking) {
        super.onPause(multitasking);
        MobileCore.lifecyclePause();
    }

    @Override
    public void onResume(boolean multitasking) {
        super.onResume(multitasking);
        MobileCore.setApplication(this.cordova.getActivity().getApplication());
        MobileCore.lifecycleStart(null);
    }
 
    @Override
    public void pluginInitialize() {
        ACPFirebaseMessagingService.handleMessage(this.cordova.getActivity().getIntent().getExtras());
        super.pluginInitialize();
    }

    public void openScreenByDeepLink(String deepLink) {

        Log.d("DEEPLINK", "Abrindo o deeplink " + deepLink);
        if (deepLink != null) {
           // Criar e iniciar a nova Intent
           Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(deepLink));
           intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
           cordova.getActivity().startActivity(intent);
        }
    }

}
