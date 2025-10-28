import AEPAssurance

@objc(AEPAssurance_Cordova) class AEPAssurance_Cordova: CDVPlugin {

  @objc(extensionVersion:)
  func extensionVersion(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      var pluginResult: CDVPluginResult! = nil
      let extensionVersion: String! = Assurance.extensionVersion

      if extensionVersion != nil && extensionVersion.count > 0 {
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: extensionVersion)
      } else {
        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
      }

      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(startSession:)
  func startSession(command: CDVInvokedUrlCommand) {
      self.commandDelegate.run(inBackground: {
          guard let urlString = command.arguments[0] as? String,
                let url = URL(string: urlString) else {
              let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Invalid URL")
              self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
              return
          }
          Assurance.startSession(url: url)
          self.commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: command.callbackId)
      })
  }
}
