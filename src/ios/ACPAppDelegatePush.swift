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
import AppTrackingTransparency
import AdSupport

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
        // IMPORTANT: Set privacy status based on current ATT authorization
        // This ensures we respect user's tracking preference from the start
        setPrivacyStatusBasedOnATT()
        
        MobileCore.configureWith(appId: appId)
        
        if appState != .background {
          MobileCore.lifecycleStart(additionalContextData: nil)
        }
      })

    // Register for push notification observers
    NotificationCenter.default.addObserver(
      self, 
      selector: #selector(handleNotificationDispatched(notification:)),
      name: NSNotification.Name("FirebaseRemoteNotificationReceivedDispatch"), 
      object: nil)
    
    NotificationCenter.default.addObserver(
      self, 
      selector: #selector(handleClickNotificationDispatched(notification:)),
      name: NSNotification.Name("FirebaseRemoteNotificationClickedDispatch"), 
      object: nil)
    
    // Monitor for ATT status changes (iOS 14+)
    if #available(iOS 14, *) {
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(handleATTStatusChange),
        name: UIApplication.didBecomeActiveNotification,
        object: nil)
    }
  }

  /// Sets Adobe privacy status based on ATT authorization status
  /// This method should be called:
  /// 1. On app initialization
  /// 2. After user responds to ATT prompt
  /// 3. When app becomes active (to catch Settings changes)
  static func setPrivacyStatusBasedOnATT() {
    if #available(iOS 14, *) {
      let attStatus = ATTrackingManager.trackingAuthorizationStatus
      
      switch attStatus {
      case .authorized:
        // User authorized tracking - collect IDFA and opt in
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        // Verify IDFA is valid (not zero UUID which indicates LAT enabled)
        if idfa != "00000000-0000-0000-0000-000000000000" {
          MobileCore.setAdvertisingIdentifier(idfa)
          MobileCore.setPrivacyStatus(.optedIn)
          NSLog("Adobe SDK: Privacy set to OptedIn with IDFA: %@", idfa)
        } else {
          // IDFA is zero UUID - user has LAT enabled despite authorization
          MobileCore.setPrivacyStatus(.optedOut)
          NSLog("Adobe SDK: Privacy set to OptedOut (LAT enabled)")
        }
        
      case .denied:
        // User explicitly denied tracking
        MobileCore.setPrivacyStatus(.optedOut)
        NSLog("Adobe SDK: Privacy set to OptedOut (ATT Denied)")
        
      case .restricted:
        // Device restrictions (parental controls, MDM, etc.)
        MobileCore.setPrivacyStatus(.optedOut)
        NSLog("Adobe SDK: Privacy set to OptedOut (ATT Restricted)")
        
      case .notDetermined:
        // User hasn't been asked yet - use unknown until they respond
        // DO NOT collect IDFA or track until user authorizes
        MobileCore.setPrivacyStatus(.unknown)
        NSLog("Adobe SDK: Privacy set to Unknown (ATT Not Determined)")
        NSLog("⚠️ App should request ATT authorization at appropriate time")
        
      @unknown default:
        // Future-proof for new ATT statuses
        MobileCore.setPrivacyStatus(.unknown)
        NSLog("Adobe SDK: Privacy set to Unknown (Unknown ATT Status)")
      }
      
    } else {
      // iOS 13 or earlier - ATT framework not available
      // Check if user has Limit Ad Tracking (LAT) enabled
      let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
      
      if idfa != "00000000-0000-0000-0000-000000000000" {
        // LAT is disabled - tracking allowed
        MobileCore.setAdvertisingIdentifier(idfa)
        MobileCore.setPrivacyStatus(.optedIn)
        NSLog("Adobe SDK: Privacy set to OptedIn (iOS 13 or earlier) with IDFA: %@", idfa)
      } else {
        // LAT is enabled - respect user preference
        MobileCore.setPrivacyStatus(.optedOut)
        NSLog("Adobe SDK: Privacy set to OptedOut (LAT enabled on iOS 13)")
      }
    }
  }
  
  /// Monitors for ATT status changes when app becomes active
  /// This catches cases where user changes tracking in Settings
  @available(iOS 14, *)
  @objc static func handleATTStatusChange() {
    // Re-evaluate privacy status when app becomes active
    setPrivacyStatusBasedOnATT()
  }

  @objc static func handleNotificationDispatched(notification: NSNotification) {
    sendTracking(notification: notification, action: "7", skipDeepLink: false)
  }

  @objc static func handleClickNotificationDispatched(notification: NSNotification) {
    sendTracking(notification: notification, action: "2", skipDeepLink: true)
    sendTracking(notification: notification, action: "1", skipDeepLink: false)
  }

  static func sendTracking(notification: NSNotification, action: String, skipDeepLink: Bool) {
    guard let userInfo = notification.object as? [String: Any],
          let deliveryId = userInfo["_dId"] as? String,
          let broadlogId = userInfo["_mId"] as? String else {
        NSLog("Adobe Campaign: Tracking not sent - invalid notification data")
        return
    }
    
    let acsDeliveryTracking = userInfo["_acsDeliveryTracking"] as? String ?? "on"
    
    // Only send tracking if enabled in notification payload
    if acsDeliveryTracking.caseInsensitiveCompare("on") == .orderedSame {
        let trackingData: [String: Any] = [
            "deliveryId": deliveryId,
            "broadlogId": broadlogId,
            "action": action
        ]
        
        MobileCore.collectMessageInfo(trackingData)
        NSLog("Adobe Campaign: Tracking sent - deliveryId: %@, action: %@", deliveryId, action)
    } else {
        NSLog("Adobe Campaign: Tracking disabled in notification payload")
    }
    
    // Handle deep link if present and not skipped
    if !skipDeepLink, let deepLink = userInfo["uri"] as? String, !deepLink.isEmpty {
        openScreenByDeepLink(deepLink)
    }
  }
    
  static func openScreenByDeepLink(_ deepLink: String) {
      NSLog("Adobe Campaign: Opening deep link: %@", deepLink)
      
      guard let url = URL(string: deepLink) else {
          NSLog("Adobe Campaign: Invalid deep link URL: %@", deepLink)
          return
      }
      
      // Ensure we're on main thread for UI operations
      DispatchQueue.main.async {
          if #available(iOS 10.0, *) {
              UIApplication.shared.open(url, options: [:]) { success in
                  if success {
                      NSLog("Adobe Campaign: Deep link opened successfully")
                  } else {
                      NSLog("Adobe Campaign: Failed to open deep link")
                  }
              }
          } else {
              let success = UIApplication.shared.openURL(url)
              NSLog("Adobe Campaign: Deep link opened: %@", success ? "YES" : "NO")
          }
      }
  }
}