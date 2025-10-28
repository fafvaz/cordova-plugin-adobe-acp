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
          let event = Event(name: name, type: type, source: source, data: eventInput["data"] as? [String: String])
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
          let responseEvent: NSDictionary! = self.getJavascriptDictionaryFromEvent(
            event: response)
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
            messageAs: "Unable to dispatch event. InputResquest was malformed"),
          callbackId: command.callbackId)
        return
      }

      self.commandDelegate.send(
        CDVPluginResult(
          status: CDVCommandStatus_ERROR,
          messageAs: "Deprecated"),
        callbackId: command.callbackId)

    })
  }

  @objc(downloadRules:)
  func downloadRules(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_ERROR)
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

      MobileCore.getPrivacyStatus { PrivacyStatus in
        let pluginResult: CDVPluginResult! = CDVPluginResult(
          status: CDVCommandStatus_OK, messageAs: PrivacyStatus.rawValue)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      }
    })
  }

  @objc(getSdkIdentities:)
  func getSdkIdentities(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      MobileCore.getSdkIdentities { content, error in
        if error == nil {
          let pluginResult: CDVPluginResult! = CDVPluginResult(
            status: CDVCommandStatus_OK, messageAs: content)
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
      }
    })
  }

  @objc(setAdvertisingIdentifier:)
  func setAdvertisingIdentifier(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {

      let newIdentifier: String! = command.arguments[0] as? String
      MobileCore.setAdvertisingIdentifier(newIdentifier)

      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(setLogLevel:)
  func setLogLevel(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {

      let logLevel: AEPServices.LogLevel =
        command.arguments[0] as? AEPServices.LogLevel ?? AEPServices.LogLevel.warning

      MobileCore.setLogLevel(logLevel)

      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(setPrivacyStatus:)
  func setPrivacyStatus(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let privacyStatus: PrivacyStatus =
        command.arguments[0] as? PrivacyStatus ?? PrivacyStatus.unknown

      MobileCore.setPrivacyStatus(privacyStatus)
      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(trackAction:)
  func trackAction(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {

      let firstArg: AnyObject! = command.arguments[0] as AnyObject
      let secondArg: AnyObject! = command.arguments[1] as AnyObject

      // allows the AEPCore.trackAction(cData) call
      if firstArg is NSDictionary {
        MobileCore.track(action: nil, data: firstArg as? [String: String])
      } else {
        MobileCore.track(action: firstArg as? String, data: secondArg as? [String: String])
      }

      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(trackState:)
  func trackState(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {

      let firstArg: AnyObject! = command.arguments[0] as AnyObject
      let secondArg: AnyObject! = command.arguments[1] as AnyObject

      // allows the AEPCore.trackAction(cData) call
      if firstArg is NSDictionary {
        MobileCore.track(state: nil, data: firstArg as? [String: String])
      } else {
        MobileCore.track(state: firstArg as? String, data: secondArg as? [String: String])
      }

      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
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
            messageAs: "Unable to dispatch event. InputResponse was malformed"),
          callbackId: command.callbackId)
        return
      }

      MobileCore.updateConfigurationWith(configDict: config)

      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(getAppId:)
  func getAppId(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let pluginResult: CDVPluginResult! = CDVPluginResult(
        status: CDVCommandStatus_OK, messageAs: self.appId)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(openDeepLink:)
  func openDeepLink(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
        ACPAppDelegatePush.openScreenByDeepLink(command.arguments[0] as! String)
    })
  }

  @objc(requestTrackingAuthorization:)
  func requestTrackingAuthorization(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      ATTrackingManager.requestTrackingAuthorization { status in
        let statusString: String
        switch status {
        case .authorized:
          statusString = "authorized"
          // Set IDFA and update privacy status
          let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
          MobileCore.setAdvertisingIdentifier(idfa)
          MobileCore.setPrivacyStatus(.optedIn)
        case .denied, .restricted:
          statusString = status == .denied ? "denied" : "restricted"
          // Update privacy status to optedOut
          MobileCore.setPrivacyStatus(.optedOut)
        case .notDetermined:
          statusString = "notDetermined"
          // Keep as unknown
          MobileCore.setPrivacyStatus(.unknown)
        @unknown default:
          statusString = "unknown"
          MobileCore.setPrivacyStatus(.unknown)
        }
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: statusString)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      }
    })
  }

  @objc(getTrackingAuthorizationStatus:)
  func getTrackingAuthorizationStatus(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
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
    })
  }

  // ===========================================================================
  // helper functions
  // ===========================================================================

  func getExtensionEventFromJavascriptObject(event: NSDictionary!) -> AEPCore.Event! {

    let newEvent = AEPCore.Event.init(
      name: event.value(forKey: "name") as! String,
      type: event.value(forKey: "type") as! String,
      source: event.value(forKey: "source") as! String,
      data: event.value(forKey: "data") as? [String: String])

    return newEvent
  }

  func getJavascriptDictionaryFromEvent(event: AEPCore.Event!) -> NSDictionary! {
    return [
      "name": event.name,
      "type": event.type,
      "source": event.source,
      "data": event.data!,
    ]
  }

  // ===============================================================
  // Plugin lifecycle events
  // ===============================================================
  override func pluginInitialize() {

    let date: NSDate! = NSDate()
    let dateFormatter: DateFormatter! = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
    initTime = dateFormatter.string(from: date as Date)
    self.appId = Bundle.main.object(forInfoDictionaryKey: "AppId") as? String
    ACPAppDelegatePush.registerExtensions()
  }
}