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
      
      self.typeId = Bundle.main.object(forInfoDictionaryKey: "TypeId") as? String ?? ""
      
      // Request notification permissions on main thread
      DispatchQueue.main.async {
          let center = UNUserNotificationCenter.current()
          center.delegate = self
          
          // Request authorization with all relevant options
          center.requestAuthorization(options: [.sound, .alert, .badge]) { granted, error in
              
              if let error = error {
                  NSLog("Push notification authorization error: %@", error.localizedDescription)
                  let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription)
                  self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                  return
              }
              
              if granted {
                  NSLog("Push notification authorization granted")
                  
                  // Collect PII data
                  MobileCore.collectPii([self.typeId: valueTypeId])
                  
                  // Register for remote notifications on main thread
                  DispatchQueue.main.async {
                      UIApplication.shared.registerForRemoteNotifications()
                  }
              } else {
                  NSLog("Push notification authorization denied by user")
              }
              
              let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: granted ? "granted" : "denied")
              self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
          }
      }
  }

  @objc(getTypeId:)
  func getTypeId(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let pluginResult: CDVPluginResult! = CDVPluginResult(
        status: CDVCommandStatus_OK, messageAs: self.typeId)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }
  
  // MARK: - UNUserNotificationCenterDelegate
  
  // Handle notifications when app is in foreground
  func userNotificationCenter(_ center: UNUserNotificationCenter, 
                             willPresent notification: UNNotification, 
                             withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      // Show notification even when app is in foreground
      if #available(iOS 14.0, *) {
          completionHandler([.banner, .sound, .badge])
      } else {
          completionHandler([.alert, .sound, .badge])
      }
  }
  
  // Handle notification tap
  func userNotificationCenter(_ center: UNUserNotificationCenter, 
                             didReceive response: UNNotificationResponse, 
                             withCompletionHandler completionHandler: @escaping () -> Void) {
      let userInfo = response.notification.request.content.userInfo
      
      // Track notification interaction
      if let deliveryId = userInfo["_dId"] as? String,
         let broadlogId = userInfo["_mId"] as? String {
          MobileCore.collectMessageInfo([
              "deliveryId": deliveryId,
              "broadlogId": broadlogId,
              "action": "1" // Click action
          ])
      }
      
      completionHandler()
  }
}