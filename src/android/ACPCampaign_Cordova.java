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

import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.util.Log;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;

import com.adobe.marketing.mobile.AdobeCallback;
import com.adobe.marketing.mobile.Campaign;
import com.adobe.marketing.mobile.MobileCore;

import java.util.HashMap;

public class ACPCampaign_Cordova extends CordovaPlugin {

    private String typeId;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) {

        if ("extensionVersion".equals(action)) {
            extensionVersion(callbackContext);
            return true;
        } else if ("setPushIdentifier".equals(action)) {
            setPushIdentifier(args, callbackContext);
            return true;
        }

        return false;
    }

    private void extensionVersion(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                String extensionVersion = Campaign.extensionVersion();
                if (extensionVersion.length() > 0) {
                    callbackContext.success(extensionVersion);
                } else {
                    callbackContext.error("Extension version is null or empty");
                }
            }
        });
    }

    private void setPushIdentifier(final JSONArray args, final CallbackContext callbackContext) {

        // Read TypeId from AndroidManifest meta-data
        try {
            ApplicationInfo ai = cordova.getActivity()
                .getPackageManager()
                .getApplicationInfo(
                    cordova.getActivity().getPackageName(),
                    PackageManager.GET_META_DATA
                );
            typeId = ai.metaData.getString("com.adobe.TypeId");
            Log.d("ACP_CAMPAIGN", "TypeId loaded: " + typeId);
        } catch (PackageManager.NameNotFoundException e) {
            Log.e("ACP_CAMPAIGN", "Failed to read TypeId from AndroidManifest: " + e.getMessage());
            typeId = "";
        }

        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                if (args == null || args.length() != 2) {
                    callbackContext.error("Invalid argument count, expected length 2.");
                    return;
                }
                try {
                    String deviceToken = args.getString(0);
                    String valueTypeId = args.getString(1);
                    HashMap<String, String> data = new HashMap<>();
                    data.put(typeId, valueTypeId);
                    MobileCore.setPushIdentifier(deviceToken);
                    MobileCore.collectPii(data);
                    callbackContext.success();
                } catch (JSONException e) {
                    callbackContext.error("Error while parsing argument, Error " + e.getLocalizedMessage());
                }
            }
        });
    }
}