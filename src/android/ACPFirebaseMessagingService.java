package com.adobe.marketing.mobile.cordova;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

import com.adobe.marketing.mobile.MobileCore;
import com.google.firebase.messaging.RemoteMessage;

import org.apache.cordova.firebase.FirebasePluginMessageReceiver;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

public class ACPFirebaseMessagingService extends FirebasePluginMessageReceiver {


  @Override
  public boolean onMessageReceived(RemoteMessage remoteMessage) {
    // Aqui você lida com o recebimento da notificação push
    // Extrai as informações necessárias do objeto remoteMessage, como deliveryId, messageId e acsDeliveryTracking

    System.out.println("ACPFirebaseMessagingService: onMessageReceived");

    Map<String, String> data = remoteMessage.getData();

    String deliveryId = data.get("_dId");
    String messageId = data.get("_mId");
    String acsDeliveryTracking = data.get("_acsDeliveryTracking");

    if (acsDeliveryTracking == null) {
      acsDeliveryTracking = "on";
    }

    // Verifica se a notificação push contém os dados necessários para o rastreamento
    if (deliveryId != null && messageId != null && acsDeliveryTracking.equals("on")) {
      handleTracking(data, "7", false);
      return true;
    }

    return false;
  }

  public static void handleMessage(Bundle bundle) {
    Log.d("ACPFirebaseMessagingService", "ACPFirebaseMessagingService called");

    if (bundle != null) {
      Map<String, String> data = new HashMap<>();
      Set<String> keys = bundle.keySet();
      for (String key : keys) {
        data.put(key, bundle.getString(key, null));
      }

      handleTracking(data, "2", false);
      handleTracking(data, "1", true);
      Log.d("ACPFirebaseMessagingService", "Handled successfully");
    }
  }

  private static void handleTracking(Map<String, String> data, String action, boolean skipDeepLink) {


    String deliveryId = data.get("_dId");
    String messageId = data.get("_mId");
    String acsDeliveryTracking = data.get("_acsDeliveryTracking");
    String deepLink = data.get("uri");

    if (acsDeliveryTracking == null) {
      acsDeliveryTracking = "on";
    }

    Log.d("ACPFirebaseMessagingService", "handleTracking");
    // Verifica se a notificação push contém os dados necessários para o rastreamento
    if (deliveryId != null && messageId != null && acsDeliveryTracking.equals("on")) {

      HashMap<String, Object> contextData = new HashMap<>();

      contextData.put("deliveryId", deliveryId);
      contextData.put("broadlogId", messageId);
      contextData.put("action", action);

      MobileCore.collectMessageInfo(contextData);

      if (deepLink != null && !deepLink.isEmpty() && !skipDeepLink) {
        ACPCore_Cordova.intance.openScreenByDeepLink(deepLink);
      }
      Log.d("ACPFirebaseMessagingService", "handleTracking successfully");
    }
  }

}
