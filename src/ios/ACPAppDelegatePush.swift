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

    // MARK: - App ID from Info.plist
    static private var appId: String {
        return Bundle.main.object(forInfoDictionaryKey: "AppId") as! String
    }

    // MARK: - Register Adobe Extensions (no configuration yet)
    static func registerExtensions() {
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
                // Do not configure yet — wait for OneTrust/ATT consent
                NSLog("Adobe SDK: Extensions registered, waiting for user consent (OneTrust/ATT)")
            }
        )
        
        // Push notification observers
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNotificationDispatched(notification:)),
            name: NSNotification.Name("FirebaseRemoteNotificationReceivedDispatch"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleClickNotificationDispatched(notification:)),
            name: NSNotification.Name("FirebaseRemoteNotificationClickedDispatch"),
            object: nil
        )
        
        // ATT status listener (iOS 14+)
        if #available(iOS 14, *) {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleATTStatusChange),
                name: UIApplication.didBecomeActiveNotification,
                object: nil
            )
        }
    }

    // MARK: - Main Consent Handler (Call from OneTrust)
    static func handleUserConsent(granted: Bool) {
        if granted {
            NSLog("Adobe SDK: User granted consent, initializing SDK...")
            initializeAdobeSDKAfterConsent()
        } else {
            NSLog("Adobe SDK: User rejected consent. SDK will not initialize.")
            MobileCore.setPrivacyStatus(.optedOut)
        }
    }

    // MARK: - SDK Initialization (only called after consent)
    static private func initializeAdobeSDKAfterConsent() {
        setPrivacyStatusBasedOnATT()
        
        MobileCore.configureWith(appId: appId)
        
        if UIApplication.shared.applicationState != .background {
            MobileCore.lifecycleStart(additionalContextData: nil)
        }
        
        NSLog("Adobe SDK: Successfully initialized after consent")
    }

    // MARK: - ATT / Privacy Status
    static func setPrivacyStatusBasedOnATT() {
        if #available(iOS 14, *) {
            let attStatus = ATTrackingManager.trackingAuthorizationStatus
            
            switch attStatus {
            case .authorized:
                let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                if idfa != "00000000-0000-0000-0000-000000000000" {
                    MobileCore.setAdvertisingIdentifier(idfa)
                    MobileCore.setPrivacyStatus(.optedIn)
                    NSLog("Adobe SDK: Privacy set to OptedIn with IDFA: %@", idfa)
                } else {
                    MobileCore.setPrivacyStatus(.optedOut)
                    NSLog("Adobe SDK: Privacy set to OptedOut (LAT enabled despite ATT authorized)")
                }
                
            case .denied, .restricted:
                MobileCore.setPrivacyStatus(.optedOut)
                NSLog("Adobe SDK: Privacy set to OptedOut (ATT Denied/Restricted)")
                
            case .notDetermined:
                MobileCore.setPrivacyStatus(.unknown)
                NSLog("Adobe SDK: Privacy set to Unknown (ATT Not Determined)")
                
            @unknown default:
                MobileCore.setPrivacyStatus(.unknown)
                NSLog("Adobe SDK: Privacy set to Unknown (Unknown ATT Status)")
            }
        } else {
            // iOS 13 or earlier
            let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            if idfa != "00000000-0000-0000-0000-000000000000" {
                MobileCore.setAdvertisingIdentifier(idfa)
                MobileCore.setPrivacyStatus(.optedIn)
                NSLog("Adobe SDK: Privacy set to OptedIn (iOS 13 or earlier)")
            } else {
                MobileCore.setPrivacyStatus(.optedOut)
                NSLog("Adobe SDK: Privacy set to OptedOut (LAT enabled on iOS 13)")
            }
        }
    }

    // MARK: - ATT Status Change Monitoring
    @available(iOS 14, *)
    @objc static func handleATTStatusChange() {
        setPrivacyStatusBasedOnATT()
    }

    // MARK: - Push Notification Handlers
    @objc static func handleNotificationDispatched(notification: NSNotification) {
        sendTracking(notification: notification, action: "7", skipDeepLink: false)
    }

    @objc static func handleClickNotificationDispatched(notification: NSNotification) {
        sendTracking(notification: notification, action: "2", skipDeepLink: true)
        sendTracking(notification: notification, action: "1", skipDeepLink: false)
    }

    // MARK: - Adobe Campaign Tracking
    static func sendTracking(notification: NSNotification, action: String, skipDeepLink: Bool) {
        guard let userInfo = notification.object as? [String: Any],
              let deliveryId = userInfo["_dId"] as? String,
              let broadlogId = userInfo["_mId"] as? String else {
            NSLog("Adobe Campaign: Tracking not sent - invalid notification data")
            return
        }
        
        let acsDeliveryTracking = userInfo["_acsDeliveryTracking"] as? String ?? "on"
        
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
        
        if !skipDeepLink, let deepLink = userInfo["uri"] as? String, !deepLink.isEmpty {
            openScreenByDeepLink(deepLink)
        }
    }

    // MARK: - Deep Link Handling
    static func openScreenByDeepLink(_ deepLink: String) {
        guard let url = URL(string: deepLink) else {
            NSLog("Adobe Campaign: Invalid deep link URL: %@", deepLink)
            return
        }
        
        DispatchQueue.main.async {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:]) { success in
                    NSLog("Adobe Campaign: Deep link opened: %@", success ? "YES" : "NO")
                }
            } else {
                let success = UIApplication.shared.openURL(url)
                NSLog("Adobe Campaign: Deep link opened: %@", success ? "YES" : "NO")
            }
        }
    }
}
