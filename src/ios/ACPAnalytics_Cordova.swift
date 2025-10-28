import AEPAnalytics

@objc(ACPAnalytics_Cordova) class ACPAnalytics_Cordova: CDVPlugin {

  @objc(extensionVersion:)
  func extensionVersion(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      var pluginResult: CDVPluginResult! = nil
      let extensionVersion: String! = Analytics.extensionVersion

      if extensionVersion != nil && extensionVersion.count > 0 {
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: extensionVersion)
      } else {
        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
      }

      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(sendQueuedHits:)
  func sendQueuedHits(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      Analytics.sendQueuedHits()
      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(clearQueue:)
  func clearQueue(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      Analytics.clearQueue()
      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(getQueueSize:)
  func getQueueSize(command: CDVInvokedUrlCommand) {
      self.commandDelegate.run(inBackground: {
          Analytics.getQueueSize { queueSize, error in
              if let error = error {
                  let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription)
                  self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
              } else {
                  let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: String(queueSize))
                  self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
              }
          }
      })
  }

  @objc(getTrackingIdentifier:)
  func getTrackingIdentifier(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {

      Analytics.getTrackingIdentifier(completion: { trackingIdentifier, error in

        if error == nil {
          let pluginResult: CDVPluginResult! = CDVPluginResult(
            status: CDVCommandStatus_OK, messageAs: trackingIdentifier)
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        } else {
          let pluginResult: CDVPluginResult! = CDVPluginResult(
            status: CDVCommandStatus_ERROR, messageAs: error?.localizedDescription)
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }

      })
    })
  }

  @objc(getVisitorIdentifier:)
  func getVisitorIdentifier(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {

      Analytics.getVisitorIdentifier(completion: { visitorIdentifier, error in

        if error == nil {
          let pluginResult: CDVPluginResult! = CDVPluginResult(
            status: CDVCommandStatus_OK, messageAs: visitorIdentifier)
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        } else {
          let pluginResult: CDVPluginResult! = CDVPluginResult(
            status: CDVCommandStatus_ERROR, messageAs: error?.localizedDescription)
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }

      })
    })
  }

  @objc(setVisitorIdentifier:)
  func setVisitorIdentifier(command: CDVInvokedUrlCommand) {
      self.commandDelegate.run(inBackground: {
          guard let vid = command.arguments[0] as? String else {
              let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Invalid visitor ID")
              self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
              return
          }
          Analytics.setVisitorIdentifier(visitorIdentifier: vid)
          let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      })
  }
}
