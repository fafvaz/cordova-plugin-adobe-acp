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

import android.net.Uri;

import com.adobe.marketing.mobile.AdobeCallback;
import com.adobe.marketing.mobile.LoggingMode;
import com.adobe.marketing.mobile.MobileCore;
import com.adobe.marketing.mobile.Target;
import com.adobe.marketing.mobile.target.TargetOrder;
import com.adobe.marketing.mobile.target.TargetParameters;
import com.adobe.marketing.mobile.target.TargetPrefetch;
import com.adobe.marketing.mobile.target.TargetProduct;
import com.adobe.marketing.mobile.target.TargetRequest;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;


/**
 * This class echoes a string called from JavaScript.
 */
public class ACPTarget_Cordova extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) {

         if ("clearPrefetchCache".equals(action)) {
            clearPrefetchCache(callbackContext);
            return true;
        } else if ("extensionVersion".equals((action))) {
            extensionVersion(callbackContext);
            return true;
        } else if ("getThirdPartyId".equals((action))) {
            getThirdPartyId(callbackContext);
            return true;
        } else if ("getTntId".equals((action))) {
            getTntId(callbackContext);
            return true;
        } else if ("resetExperience".equals((action))) {
            resetExperience(callbackContext);
            return true;
        } else if ("setThirdPartyId".equals((action))) {
            setThirdPartyId(args,callbackContext);
            return true;
        } else if ("setPreviewRestartDeepLink".equals((action))) {
            setPreviewRestartDeepLink(args,callbackContext);
            return true;
        } else if ("retrieveLocationContent".equals((action))) {
            retrieveLocationContent(args,callbackContext);
            return true;
        } else if ("locationClicked".equals((action))) {
            locationClicked(args,callbackContext);
            return true;
        } else if ("locationsDisplayed".equals((action))) {
            locationsDisplayed(args,callbackContext);
            return true;
        } else if ("prefetchContent".equals((action))) {
            prefetchContent(args,callbackContext);
            return true;
        }

        return false;
    }

    private void clearPrefetchCache(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                Target.clearPrefetchCache();
                callbackContext.success();
            }
        });
    }
	
    private void extensionVersion(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                String extensionVersion = Target.extensionVersion();
                if (extensionVersion.length() > 0) {
                    callbackContext.success(extensionVersion);
                } else {
                    callbackContext.error("Extension version is null or empty");
                }
            }
        });
    }
	
	private void getThirdPartyId(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
				Target.getThirdPartyId(new AdobeCallback<String>() {
				  @Override
				  public void call(String thirdPartyId) {
					callbackContext.success(thirdPartyId);
				  }
				});
            }
        });
    }
	
    private void getTntId(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(() -> Target.getTntId(callbackContext::success));
    }
	
	private void resetExperience(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(() -> {
            Target.resetExperience();
            callbackContext.success();
        });
    }
	
	private void setThirdPartyId(final JSONArray args, final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(() -> {
            try {
                final String thirdPartyId = args.getString(0);
                Target.setThirdPartyId(thirdPartyId);
                callbackContext.success();
            } catch (final Exception ex) {
                final String errorMessage = String.format("Exception in call to setThirdPartyId: %s", ex.getLocalizedMessage());
                MobileCore.log(LoggingMode.WARNING, "AEP SDK", errorMessage);
                callbackContext.error(errorMessage);
            }
        });
    }
	
	private void setPreviewRestartDeepLink(final JSONArray args, final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(() -> {
            try {
                final String deepLink = args.getString(0);
                Target.setPreviewRestartDeepLink(Uri.parse(deepLink));
                callbackContext.success();
            } catch (final Exception ex) {
                final String errorMessage = String.format("Exception in call to setThirdPartyId: %s", ex.getLocalizedMessage());
                MobileCore.log(LoggingMode.WARNING, "AEP SDK", errorMessage);
                callbackContext.error(errorMessage);
            }
        });
    }
	
	
	private void retrieveLocationContent(final JSONArray args, final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                try {
					
					List<TargetRequest> locationRequests = getLocationRequestFromJson(args,callbackContext);

                    TargetParameters locationParameters = getTargetParametersFromJson(args);

					Target.retrieveLocationContent(locationRequests, locationParameters);
									
                } catch (final Exception ex) {
                    final String errorMessage = String.format("Exception in call to retrieveLocationContent: %s", ex.getLocalizedMessage());
                    callbackContext.error(errorMessage);
                }
            }
        });
    }
	
	
	
	private void locationClicked(final JSONArray args, final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(() -> {
            try {
                TargetParameters locationParameters = getTargetParametersFromJson(args);

                String mboxName = args.getString(0);

                Target.clickedLocation(mboxName, locationParameters);

                callbackContext.success();
            } catch (final Exception ex) {
                final String errorMessage = String.format("Exception in call to locationClicked: %s", ex.getLocalizedMessage());
                callbackContext.error(errorMessage);
            }
        });
    }
	
	private void locationsDisplayed(final JSONArray args, final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(() -> {
            try {

                List<String> mboxList = getListFromArray(args.getJSONArray(0));
                TargetParameters parameters = getTargetParametersFromJson(args);
                Target.displayedLocations(mboxList, parameters);

                callbackContext.success();
            } catch (final Exception ex) {
                final String errorMessage = String.format("Exception in call to locationsDisplayed: %s", ex.getLocalizedMessage());
                callbackContext.error(errorMessage);
            }
        });
    }
	
	
	private void prefetchContent(final JSONArray args, final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                try {
                    
					List<TargetPrefetch> prefetchMboxesList = getPrefetchMboxesListFromJson(args);

                    TargetParameters targetParameters = getTargetParametersFromJson(args);

					Target.prefetchContent(prefetchMboxesList, targetParameters, new AdobeCallback<String>() {
														@Override
														public void call(String value) {
															callbackContext.success();
														}
													});
					
                } catch (final Exception ex) {
                    final String errorMessage = String.format("Exception in call to prefetchContent: %s", ex.getLocalizedMessage());
                    callbackContext.error(errorMessage);
                }
            }
        });
    }
	
	
	// ===============================================================
    // Helpers
    // ===============================================================
	
	private List getLocationRequestFromJson(JSONArray data,final CallbackContext callbackContext) throws JSONException {
		List<TargetRequest> locationRequestsList = new ArrayList<>();
		
			
		JSONObject obj = data.getJSONObject(0);
		
		for (int i = 0; i < obj.length(); i++) {
			
			String j = String.valueOf(i);
			
			String mboxName = obj.getJSONObject(j).getString("mboxName");

			
			JSONObject mboxParam = obj.getJSONObject(j).getJSONObject("mboxParameter");
			
			Map<String, String> mboxParameters = getStringMapFromJSON(mboxParam);		
		
			
			
			JSONObject profileParam = obj.getJSONObject(j).getJSONObject("profileParameter");

			Map<String, String> profileParameters = getStringMapFromJSON(profileParam);

			
											
			JSONObject orderParam = obj.getJSONObject(j).getJSONObject("orderParameter");
			TargetOrder targetOrder = null;

			
			if(orderParam.length()>0){

				String orderID = orderParam.getString("orderId");
				Double total = orderParam.getDouble("orderTotal");				
				
				JSONArray purchasedIdVal = orderParam.getJSONArray("orderPurchasedIds");
				List<String> purchasedIds = getListFromArray(purchasedIdVal);
		
				targetOrder = new TargetOrder(orderID, total, purchasedIds);
			} 
			
			JSONObject productParam = obj.getJSONObject(j).getJSONObject("productParameter");
			TargetProduct targetProduct1 = null;
			if(productParam.length()>0){
				String id = productParam.getString("id");
				String categoryId = productParam.getString("categoryId");
				targetProduct1 = new TargetProduct(id, categoryId);
			}
			
			TargetParameters parameters = new TargetParameters.Builder()
											.parameters(mboxParameters)
											.profileParameters(profileParameters)
											.order(targetOrder)
											.product(targetProduct1)
											.build();
											
			TargetRequest request = new TargetRequest(mboxName, parameters, "defaultContent1",
													new AdobeCallback<String>() {
														@Override
														public void call(String value) {
															value = value.concat(",{'mboxName':'").concat(mboxName).concat("'}");
															PluginResult result = new PluginResult(PluginResult.Status.OK, value);
															result.setKeepCallback(true);
															callbackContext.sendPluginResult(result);
														}
													});												
												
			locationRequestsList.add(request);			
            
		}
			
        return locationRequestsList;
    }

	private List getPrefetchMboxesListFromJson(JSONArray data) throws JSONException {
		List<TargetPrefetch> prefetchRequestList = new ArrayList<>();
		
			
		JSONObject obj = data.getJSONObject(0);
		
		for (int i = 0; i < obj.length(); i++) {
			
			String j = String.valueOf(i);
			
			String mboxName = obj.getJSONObject(j).getString("mboxName");


			
			JSONObject mboxParam = obj.getJSONObject(j).getJSONObject("mboxParameter");
		
			Map<String, String> mboxParameters = getStringMapFromJSON(mboxParam);		

			
			JSONObject profileParam = obj.getJSONObject(j).getJSONObject("profileParameter");

			Map<String, String> profileParameters = getStringMapFromJSON(profileParam);

			
											
			JSONObject orderParam = obj.getJSONObject(j).getJSONObject("orderParameter");
			TargetOrder targetOrder = null;
			if(orderParam.length()>0){

				String orderID = orderParam.getString("orderId");
				Double total = orderParam.getDouble("orderTotal");
			
			    JSONArray purchasedIdVal = orderParam.getJSONArray("orderPurchasedIds");
				List<String> purchasedIds = getListFromArray(purchasedIdVal);
				
				targetOrder = new TargetOrder(orderID, total, purchasedIds);
			} 
			
			JSONObject productParam = obj.getJSONObject(j).getJSONObject("productParameter");
			TargetProduct targetProduct1 = null;
			if(productParam.length()>0){
				String id = productParam.getString("id");
				String categoryId = productParam.getString("categoryId");
				targetProduct1 = new TargetProduct(id, categoryId);
			}
			
			TargetParameters parameters = new TargetParameters.Builder()
											.parameters(mboxParameters)
											.profileParameters(profileParameters)
											.order(targetOrder)
											.product(targetProduct1)
											.build();
			
			TargetPrefetch prefetchRequest = new TargetPrefetch(mboxName, parameters);

												
			prefetchRequestList.add(prefetchRequest);			
            
		}
			
        return prefetchRequestList;
    }
	
	private TargetParameters getTargetParametersFromJson(JSONArray data) throws JSONException {
		List<TargetRequest> locationRequestsList = new ArrayList<>();
		
			
		JSONObject obj = data.getJSONObject(1);

		JSONObject mboxParam = obj.getJSONObject("mboxParameter");
		
		Map<String, String> mboxParameters = getStringMapFromJSON(mboxParam);		
		
		
		
		JSONObject profileParam = obj.getJSONObject("profileParameter");

		Map<String, String> profileParameters = getStringMapFromJSON(profileParam);

		
										
		JSONObject orderParam = obj.getJSONObject("orderParameter");
		TargetOrder targetOrder = null;
		if(orderParam.length()>0){

			String orderID = orderParam.getString("orderId");
			Double total = orderParam.getDouble("orderTotal");
			
			JSONArray purchasedIdVal = orderParam.getJSONArray("orderPurchasedIds");
			List<String> purchasedIds = getListFromArray(purchasedIdVal);
		
			targetOrder = new TargetOrder(orderID, total, purchasedIds);
		} 
		
		JSONObject productParam = obj.getJSONObject("productParameter");
		
		TargetProduct targetProduct = null;
		if(productParam.length()>0){
			String id = productParam.getString("id");
			String categoryId = productParam.getString("categoryId");
			targetProduct = new TargetProduct(id, categoryId);
		}

		TargetParameters parameters = new TargetParameters.Builder()
										.parameters(mboxParameters)
										.profileParameters(profileParameters)
										.order(targetOrder)
										.product(targetProduct)
										.build();
		
		return parameters;
    }
	
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

	private List getListFromJSONObject(JSONObject data) throws JSONException {
        List<String> list = new ArrayList<String>();
		@SuppressWarnings("rawtypes")
        Iterator it = data.keys();
        while (it.hasNext()) {
            String n = (String) it.next();
            try {
                list.add(data.getString(n));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        return list;
    }

	private List getListFromArray(JSONArray data) throws JSONException {
        List<String> list = new ArrayList<String>();
        for (int i = 0, size = data.length(); i < size; i++)
		{
		  list.add(data.getString(i));
		}
        return list;
    }		
}
