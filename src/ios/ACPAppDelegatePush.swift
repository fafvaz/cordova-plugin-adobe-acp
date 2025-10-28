import AEPAnalytics
import AEPAssurance
import AEPCampaign
import AEPCore
import AEPIdentity
import AEPLifecycle
import AEPMobileServices
import AEPPlaces
import AEPSignal
import AEPTarget
import AEPUserProfile
import FirebaseMessaging

@objc(ACPAppDelegatePush) class ACPAppDelegatePush: NSObject {

  static func registerExtensions() {

    let appId = Bundle.main.object(forInfoDictionaryKey: "AppId") as! String
    let appState = UIApplication.shared.applicationState

    MobileCore.setLogLevel(.trace)
    MobileCore.registerExtensions(
      [
        Signal.self,
        Lifecycle.self,
        UserProfile.self,
        Identity.self,
        Assurance.self,
        Campaign.self,
        Places.self,
        Analytics.self,
        AEPMobileServices.self,
        Target.self
     ],
      {
        MobileCore.setPrivacyStatus(.optedIn)
        MobileCore.configureWith(appId: appId)
        if appState != .background {
          MobileCore.lifecycleStart(additionalContextData: nil)
        }
      })

    NotificationCenter.default.addObserver(
      self, selector: #selector(handleNotificationDispatched(notification:)),
      name: NSNotification.Name("FirebaseRemoteNotificationReceivedDispatch"), object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(handleClickNotificationDispatched(notification:)),
      name: NSNotification.Name("FirebaseRemoteNotificationClickedDispatch"), object: nil)
  }

  @objc static func handleNotificationDispatched(notification: NSNotification) {
    sendTracking(notification: notification, action: "7", skipDeepLink: "false")
  }

  @objc static func handleClickNotificationDispatched(notification: NSNotification) {
    sendTracking(notification: notification, action: "2", skipDeepLink: "true")
    sendTracking(notification: notification, action: "1", skipDeepLink: "false")
  }

  static func sendTracking(notification: NSNotification, action: String, skipDeepLink: String) {
    guard let userInfo = notification.object as? [String: Any],
          let deliveryId = userInfo["_dId"] as? String,
          let broadlogId = userInfo["_mId"] as? String else {
        print("Tracking not delivered: Invalid notification data")
        return
    }
    let acsDeliveryTracking = userInfo["_acsDeliveryTracking"] as? String ?? "on"
    if acsDeliveryTracking.caseInsensitiveCompare("on") == .orderedSame {
        MobileCore.collectMessageInfo(["deliveryId": deliveryId, "broadlogId": broadlogId, "action": action])
    } else {
        print("Tracking not delivered: ACS tracking disabled")
    }
    if skipDeepLink == "false", let deepLink = userInfo["uri"] as? String {
        openScreenByDeepLink(deepLink)
    }
  }
    
  static func openScreenByDeepLink(_ deepLink: String) {
      print("Abrindo o deeplink " + deepLink)

      if (deepLink != nil) {
          guard let url = URL(string: deepLink) else {
            return //be safe
          }

          if #available(iOS 10.0, *) {
              UIApplication.shared.open(url, options: [:], completionHandler: nil)
          } else {
              UIApplication.shared.openURL(url)
          }
      }
  }

}
