package com.adobe.marketing.mobile.cordova;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CordovaInterface;
import org.json.JSONArray;
import org.json.JSONException;

import android.webkit.WebView;
import android.webkit.WebViewClient;

public class WebViewEventPlugin extends CordovaPlugin {

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);

        // Configurar o WebViewClient personalizado
        WebView systemWebView = (WebView) webView.getView();
        systemWebView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                // Notificar o evento onPageFinished para o JavaScript
                String js = "javascript:cordova.fireDocumentEvent('onPageFinished', {'url':'" + url + "'});";
                view.loadUrl(js);
            }
        });
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        return false;
    }
}
