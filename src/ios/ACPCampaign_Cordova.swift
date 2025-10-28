import AEPCampaign
import AEPCore
import UserNotifications

@objc(ACPCampaign_Cordova) class ACPCampaign_Cordova: CDVPlugin, UNUserNotificationCenterDelegate {

  var typeId: String!

  @objc(extensionVersion:)
  func extensionVersion(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      var pluginResult: CDVPluginResult! = nil
      let extensionVersion: String! = Campaign.extensionVersion

      if extensionVersion != nil && extensionVersion.count > 0 {
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: extensionVersion)
      } else {
        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
      }

      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(setPushIdentifier:)
  func setPushIdentifier(command: CDVInvokedUrlCommand) {
      guard let valueTypeId = command.arguments[1] as? String else {
          let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Invalid type ID")
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
          return
      }
      
      let center = UNUserNotificationCenter.current()
      center.delegate = self
      center.requestAuthorization(options: [.sound, .alert, .badge]) { granted, error in
          self.typeId = Bundle.main.object(forInfoDictionaryKey: "TypeId") as? String ?? ""
          
          if error == nil {
              MobileCore.collectPii([self.typeId: valueTypeId])
              
              DispatchQueue.main.async {
                  UIApplication.shared.registerForRemoteNotifications()
              }
              
              NSLog("Push registration success.")
          } else {
              NSLog("Push registration FAILED: %@", error?.localizedDescription ?? "")
          }
          
          let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      }
      MobileCore.setLogLevel(.debug)
  }

  @objc(getTypeId:)
  func getTypeId(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let pluginResult: CDVPluginResult! = CDVPluginResult(
        status: CDVCommandStatus_OK, messageAs: self.typeId)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }
}