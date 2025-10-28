package com.galp.bluetooh;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import com.adobe.marketing.mobile.MobileCore;

import java.util.HashMap;

public class NotificationDismissedReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        Bundle data = intent.getExtras();

        if(data != null) {
            String deliveryId = data.getString("_dId");
            String messageId = data.getString("_mId");
            String acsDeliveryTracking = data.getString("_acsDeliveryTracking");

            if( acsDeliveryTracking == null ) {
                acsDeliveryTracking = "on";
            }

            HashMap<String, Object> contextData = new HashMap<>();

            //We only send the click tracking since the user dismissed the notification
            if (deliveryId != null && messageId != null && acsDeliveryTracking.equals("on")) {
                contextData.put("deliveryId", deliveryId);
                contextData.put("broadlogId", messageId);
                contextData.put("action", "2");
                MobileCore.collectMessageInfo(contextData);
            }
        }
    }
}
