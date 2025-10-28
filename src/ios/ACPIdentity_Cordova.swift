import AEPCore
import AEPIdentity

let stateStrings = ["UNKNOWN", "AUTHENTICATED", "LOGGED_OUT"]
let INVALID_AUTH_STATE = 3

@objc(ACPIdentity_Cordova) class ACPIdentity_Cordova: CDVPlugin {

  @objc(extensionVersion:)
  func extensionVersion(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      var pluginResult: CDVPluginResult! = nil

      let version: String! = Identity.extensionVersion

      pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: version)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(appendVisitorInfoForUrl:)
  func appendVisitorInfoForUrl(command: CDVInvokedUrlCommand) {
      self.commandDelegate.run(inBackground: {
          guard let urlString = command.arguments[0] as? String,
                let url = URL(string: urlString) else {
              let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Invalid URL")
              self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
              return
          }
          Identity.appendTo(url: url) { urlWithVisitorData, error in
              let pluginResult = error == nil ?
                  CDVPluginResult(status: CDVCommandStatus_OK, messageAs: urlWithVisitorData?.absoluteString) :
                  CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error?.localizedDescription)
              self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
          }
      })
  }

  @objc(getExperienceCloudId:)
  func getExperienceCloudId(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      Identity.getExperienceCloudId(completion: { (experienceCloudId: String?, error) in
        if error == nil {
          let pluginResult: CDVPluginResult! = CDVPluginResult(
            status: CDVCommandStatus_OK, messageAs: experienceCloudId)
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        } else {
          let pluginResult: CDVPluginResult! = CDVPluginResult(
            status: CDVCommandStatus_ERROR, messageAs: error?.localizedDescription)
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }

      })
    })
  }

  @objc(getIdentifiers:)
  func getIdentifiers(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {

      Identity.getIdentifiers(completion: { (visitorIDs: [Identifiable]?, error) in
        var visitorIdsString: String! = ""
        if visitorIDs == nil {
          visitorIdsString = "nil"
        } else if visitorIDs?.count == 0 {
          visitorIdsString = "[]"
        } else {

          visitorIDs?.forEach({ (visitorId) in
            visitorIdsString = visitorIdsString.appendingFormat(
              "[Id: %@, Type: %@, Origin: %@, Authentication: %@] ", visitorId.identifier ?? "",
              visitorId.type ?? "", visitorId.origin ?? "",
              stateStrings[Int(visitorId.authenticationState.rawValue)])
          })
        }
        let pluginResult: CDVPluginResult! = CDVPluginResult(
          status: CDVCommandStatus_OK, messageAs: visitorIdsString)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      })
    })
  }

  @objc(getUrlVariables:)
  func getUrlVariables(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      Identity.getUrlVariables(completion: { (urlVariables: String?, error) in
        let pluginResult: CDVPluginResult! = CDVPluginResult(
          status: CDVCommandStatus_OK, messageAs: urlVariables)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      })
    })
  }

  @objc(syncIdentifier:)
  func syncIdentifier(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let idType: String! = command.arguments[0] as? String
      let idValue: String! = command.arguments[1] as? String
      let state: Int = self.getAuthenticationStateValue(
        authState: command.arguments[2] as? NSNumber)

      Identity.syncIdentifier(
        identifierType: idType, identifier: idValue,
        authenticationState: self.getAuthenticationStateEnumValue(authState: state as NSNumber))
      let pluginResult: CDVPluginResult! = CDVPluginResult(
        status: CDVCommandStatus_OK,
        messageAs: String(
          format: "Visitor ID synced: Id: %@, Type: %@, Authentication: %@", idType, idValue,
          stateStrings[state]))
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(syncIdentifiers:)
  func syncIdentifiers(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      var pluginResult: CDVPluginResult! = nil
      let identifiers: NSDictionary! = command.arguments[0] as? NSDictionary
      let state: Int = command.arguments[1] as? Int ?? 0

      if state < 3 {
        Identity.syncIdentifiers(
          identifiers: identifiers as? [String: String],
          authenticationState: self.getAuthenticationStateEnumValue(authState: state as NSNumber))
        pluginResult = CDVPluginResult(
          status: CDVCommandStatus_OK,
          messageAs: String(
            format: "Visitor IDs synced: %@, Authentication: %@", identifiers, stateStrings[state]))
      } else {
        Identity.syncIdentifiers(identifiers: identifiers as? [String: String])
        pluginResult = CDVPluginResult(
          status: CDVCommandStatus_OK,
          messageAs: String(format: "Visitor IDs synced: %@", identifiers))
      }

      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  /*
     * Helper functions
     */

  func getAuthenticationStateValue(authState: NSNumber!) -> Int {
    var authStateInt: Int = 3  // use 3 as the auth state values range from 0-2
    if authState != nil {
      switch authState.intValue {
      case 0:
        authStateInt = Int(MobileVisitorAuthenticationState.unknown.rawValue)
        break
      case 1:
        authStateInt = Int(MobileVisitorAuthenticationState.authenticated.rawValue)
        break
      case 2:
        authStateInt = Int(MobileVisitorAuthenticationState.loggedOut.rawValue)
        break
      default:
        authStateInt = INVALID_AUTH_STATE
        break
      }
    }
    return authStateInt
  }

  func getAuthenticationStateEnumValue(authState: NSNumber!) -> MobileVisitorAuthenticationState {
    var state = MobileVisitorAuthenticationState.unknown
    if authState != nil {
      switch authState.intValue {
      case 0:
        state = MobileVisitorAuthenticationState.unknown
        break
      case 1:
        state = MobileVisitorAuthenticationState.authenticated
        break
      case 2:
        state = MobileVisitorAuthenticationState.loggedOut
        break
      default:
        state = MobileVisitorAuthenticationState.unknown
        break
      }
    }
    return state
  }
}
