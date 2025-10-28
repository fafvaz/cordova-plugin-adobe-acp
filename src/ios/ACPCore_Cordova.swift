import AEPAnalytics
import AEPCampaign
import AEPCore
import AEPMobileServices
import AEPPlaces
import AEPServices
import AEPTarget
import AEPUserProfile
import AppTrackingTransparency
import AdSupport

@objc(ACPCore_Cordova) class ACPCore_Cordova: CDVPlugin {

  var appId: String!
  var initTime: String!

  // MARK: - Event Dispatching
  
  @objc(dispatchEvent:)
  func dispatchEvent(command: CDVInvokedUrlCommand) {
      self.commandDelegate.run(inBackground: {
          guard let eventInput = command.arguments[0] as? [String: Any],
                let name = eventInput["name"] as? String,
                let type = eventInput["type"] as? String,
                let source = eventInput["source"] as? String else {
              let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Invalid event data")
              self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
              return
          }
          
          let event = Event(name: name, type: type, source: source, data: eventInput["data"] as? [String: Any])
          MobileCore.dispatch(event: event)
          
          let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      })
  }

  @objc(dispatchEventWithResponseCallback:)
  func dispatchEventWithResponseCallback(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      guard let eventInput = command.arguments[0] as? NSDictionary else {
        self.commandDelegate.send(
          CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: "Unable to dispatch event. Input was malformed"),
          callbackId: command.callbackId)
        return
      }

      let event: AEPCore.Event! = self.getExtensionEventFromJavascriptObject(event: eventInput)

      MobileCore.dispatch(
        event: event,
        responseCallback: { (response: AEPCore.Event!) in
          let responseEvent: NSDictionary! = self.getJavascriptDictionaryFromEvent(event: response)
          let pluginResult: CDVPluginResult! = CDVPluginResult(
            status: CDVCommandStatus_OK, messageAs: responseEvent as? [AnyHashable: Any])
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        })
    })
  }

  @objc(dispatchResponseEvent:)
  func dispatchResponseEvent(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      guard let inputResponseEvent = command.arguments[0] as? NSDictionary else {
        self.commandDelegate.send(
          CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: "Unable to dispatch event. InputResponse was malformed"),
          callbackId: command.callbackId)
        return
      }

      guard let inputRequestEvent = command.arguments[1] as? NSDictionary else {
        self.commandDelegate.send(
          CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: "Unable to dispatch event. InputRequest was malformed"),
          callbackId: command.callbackId)
        return
      }

      self.commandDelegate.send(
        CDVPluginResult(
          status: CDVCommandStatus_ERROR,
          messageAs: "Deprecated - use dispatchEvent instead"),
        callbackId: command.callbackId)
    })
  }

  // MARK: - Core SDK Methods
  
  @objc(downloadRules:)
  func downloadRules(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      // Not implemented on iOS
      let pluginResult: CDVPluginResult! = CDVPluginResult(
        status: CDVCommandStatus_ERROR, 
        messageAs: "downloadRules not available on iOS")
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(extensionVersion:)
  func extensionVersion(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let version: String! = self.initTime.appending(": ").appending(MobileCore.extensionVersion)
      let pluginResult: CDVPluginResult! = CDVPluginResult(
        status: CDVCommandStatus_OK, messageAs: version)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(getPrivacyStatus:)
  func getPrivacyStatus(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      MobileCore.getPrivacyStatus { privacyStatus in
        let pluginResult: CDVPluginResult! = CDVPluginResult(
          status: CDVCommandStatus_OK, messageAs: privacyStatus.rawValue)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      }
    })
  }

  @objc(getSdkIdentities:)
  func getSdkIdentities(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      MobileCore.getSdkIdentities { content, error in
        if let error = error {
          let pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR, 
            messageAs: error.localizedDescription)
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        } else {
          let pluginResult = CDVPluginResult(
            status: CDVCommandStatus_OK, messageAs: content)
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
      }
    })
  }

  @objc(setAdvertisingIdentifier:)
  func setAdvertisingIdentifier(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      guard let newIdentifier = command.arguments[0] as? String else {
        let pluginResult = CDVPluginResult(
          status: CDVCommandStatus_ERROR, 
          messageAs: "Invalid advertising identifier")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        return
      }
      
      MobileCore.setAdvertisingIdentifier(newIdentifier)
      
      let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(setLogLevel:)
  func setLogLevel(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      guard let logLevelInt = command.arguments[0] as? Int else {
        let pluginResult = CDVPluginResult(
          status: CDVCommandStatus_ERROR, 
          messageAs: "Invalid log level")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        return
      }
      
      let logLevel: AEPServices.LogLevel
      switch logLevelInt {
        case 0: logLevel = .error
        case 1: logLevel = .warning
        case 2: logLevel = .debug
        case 3: logLevel = .trace
        default: logLevel = .warning
      }

      MobileCore.setLogLevel(logLevel)

      let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(setPrivacyStatus:)
  func setPrivacyStatus(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      guard let privacyStatusInt = command.arguments[0] as? Int else {
        let pluginResult = CDVPluginResult(
          status: CDVCommandStatus_ERROR, 
          messageAs: "Invalid privacy status")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        return
      }
      
      let privacyStatus: PrivacyStatus
      switch privacyStatusInt {
        case 0: privacyStatus = .optedIn
        case 1: privacyStatus = .optedOut
        case 2: privacyStatus = .unknown
        default: privacyStatus = .unknown
      }

      MobileCore.setPrivacyStatus(privacyStatus)
      
      let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(trackAction:)
  func trackAction(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let firstArg: AnyObject! = command.arguments[0] as AnyObject
      let secondArg: AnyObject! = command.arguments[1] as AnyObject

      if firstArg is NSDictionary {
        MobileCore.track(action: nil, data: firstArg as? [String: String])
      } else {
        MobileCore.track(action: firstArg as? String, data: secondArg as? [String: String])
      }

      let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(trackState:)
  func trackState(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let firstArg: AnyObject! = command.arguments[0] as AnyObject
      let secondArg: AnyObject! = command.arguments[1] as AnyObject

      if firstArg is NSDictionary {
        MobileCore.track(state: nil, data: firstArg as? [String: String])
      } else {
        MobileCore.track(state: firstArg as? String, data: secondArg as? [String: String])
      }

      let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(updateConfiguration:)
  func updateConfiguration(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      guard let config = command.arguments[0] as? [String: Any] else {
        self.commandDelegate.send(
          CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: "Invalid configuration object"),
          callbackId: command.callbackId)
        return
      }

      MobileCore.updateConfigurationWith(configDict: config)

      let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(getAppId:)
  func getAppId(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let pluginResult = CDVPluginResult(
        status: CDVCommandStatus_OK, messageAs: self.appId)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(openDeepLink:)
  func openDeepLink(command: CDVInvokedUrlCommand!) {
    guard let deepLink = command.arguments[0] as? String else {
      let pluginResult = CDVPluginResult(
        status: CDVCommandStatus_ERROR, 
        messageAs: "Invalid deep link")
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      return
    }
    
    ACPAppDelegatePush.openScreenByDeepLink(deepLink)
    
    let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
  }

  // MARK: - App Tracking Transparency (ATT)
  
  /// Requests App Tracking Transparency authorization from user
  /// MUST be called on main thread as it shows UI
  /// Best practice: Call after user has experienced app value, not immediately on launch
  @objc(requestTrackingAuthorization:)
  func requestTrackingAuthorization(command: CDVInvokedUrlCommand!) {
    // CRITICAL: Must run on main thread for UI presentation
    DispatchQueue.main.async {
      if #available(iOS 14, *) {
        ATTrackingManager.requestTrackingAuthorization { status in
          let statusString: String
          
          switch status {
          case .authorized:
            statusString = "authorized"
            // User authorized - collect IDFA and update Adobe privacy
            let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            
            if idfa != "00000000-0000-0000-0000-000000000000" {
              MobileCore.setAdvertisingIdentifier(idfa)
              MobileCore.setPrivacyStatus(.optedIn)
              NSLog("ATT: Authorized with IDFA: %@", idfa)
            } else {
              // Zero UUID despite authorization (LAT enabled)
              MobileCore.setPrivacyStatus(.optedOut)
              NSLog("ATT: Authorized but LAT enabled")
            }
            
          case .denied:
            statusString = "denied"
            MobileCore.setPrivacyStatus(.optedOut)
            NSLog("ATT: Denied by user")
            
          case .restricted:
            statusString = "restricted"
            MobileCore.setPrivacyStatus(.optedOut)
            NSLog("ATT: Restricted by device")
            
          case .notDetermined:
            statusString = "notDetermined"
            // This shouldn't happen after request, but handle it
            MobileCore.setPrivacyStatus(.unknown)
            NSLog("ATT: Not determined after request")
            
          @unknown default:
            statusString = "unknown"
            MobileCore.setPrivacyStatus(.unknown)
            NSLog("ATT: Unknown status")
          }
          
          let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: statusString)
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
      } else {
        // iOS 13 or earlier - ATT not available
        // Check LAT setting and set accordingly
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        if idfa != "00000000-0000-0000-0000-000000000000" {
          MobileCore.setAdvertisingIdentifier(idfa)
          MobileCore.setPrivacyStatus(.optedIn)
        } else {
          MobileCore.setPrivacyStatus(.optedOut)
        }
        
        let pluginResult = CDVPluginResult(
          status: CDVCommandStatus_OK, 
          messageAs: "authorized_legacy")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      }
    }
  }

  /// Gets current ATT authorization status without prompting user
  @objc(getTrackingAuthorizationStatus:)
  func getTrackingAuthorizationStatus(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      if #available(iOS 14, *) {
        let status = ATTrackingManager.trackingAuthorizationStatus
        let statusString: String
        
        switch status {
        case .authorized:
          statusString = "authorized"
        case .denied:
          statusString = "denied"
        case .notDetermined:
          statusString = "notDetermined"
        case .restricted:
          statusString = "restricted"
        @unknown default:
          statusString = "unknown"
        }
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: statusString)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      } else {
        // iOS 13 or earlier - check LAT status
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        let statusString = idfa != "00000000-0000-0000-0000-000000000000" ? "authorized_legacy" : "denied_legacy"
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: statusString)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      }
    })
  }

  // MARK: - Helper Functions
  
  func getExtensionEventFromJavascriptObject(event: NSDictionary!) -> AEPCore.Event! {
    let newEvent = AEPCore.Event(
      name: event.value(forKey: "name") as! String,
      type: event.value(forKey: "type") as! String,
      source: event.value(forKey: "source") as! String,
      data: event.value(forKey: "data") as? [String: Any])

    return newEvent
  }

  func getJavascriptDictionaryFromEvent(event: AEPCore.Event!) -> NSDictionary! {
    return [
      "name": event.name,
      "type": event.type,
      "source": event.source,
      "data": event.data ?? [:],
    ]
  }

  // MARK: - Plugin Lifecycle
  
  override func pluginInitialize() {
    let date = NSDate()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
    initTime = dateFormatter.string(from: date as Date)
    
    self.appId = Bundle.main.object(forInfoDictionaryKey: "AppId") as? String
    
    // Initialize Adobe SDK extensions
    ACPAppDelegatePush.registerExtensions()
  }
}