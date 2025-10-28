import AEPPlaces
import CoreLocation

@objc(ACPPlaces_Cordova) class ACPPlaces_Cordova: CDVPlugin {

  let POI: String! = "POI"
  let LATITUDE: String! = "Latitude"
  let LONGITUDE: String! = "Longitude"
  let LOWERCASE_LATITUDE: String! = "latitude"
  let LOWERCASE_LONGITUDE: String! = "longitude"
  let IDENTIFIER: String! = "Identifier"
  let CENTER: String! = "center"
  let RADIUS: String! = "radius"
  let REQUEST_ID: String! = "requestId"
  let CIRCULAR_REGION: String! = "circularRegion"
  let EMPTY_ARRAY_STRING: String! = "[]"

  @objc(clear:)
  func clear(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      Places.clear()
      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(extensionVersion:)
  func extensionVersion(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      var pluginResult: CDVPluginResult! = nil
      let extensionVersion: String! = Places.extensionVersion

      if extensionVersion != nil && extensionVersion.count > 0 {
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: extensionVersion)
      } else {
        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
      }

      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(getCurrentPointsOfInterest:)
  func getCurrentPointsOfInterest(command: CDVInvokedUrlCommand) {
      self.commandDelegate.run(inBackground: {
          Places.getCurrentPointsOfInterest { retrievedPois in
              let currentPoisString = self.generatePOIString(retrievedPois: retrievedPois)
              let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: currentPoisString)
              self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
          }
      })
  }

  @objc(getLastKnownLocation:)
  func getLastKnownLocation(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {

      Places.getLastKnownLocation { [self] (lastLocation) in

        do {
          let tempDict: NSMutableDictionary! = NSMutableDictionary()
          tempDict.setValue(lastLocation?.coordinate.latitude ?? 0, forKey: LATITUDE)
          tempDict.setValue(lastLocation?.coordinate.longitude ?? 0, forKey: LONGITUDE)
          let jsonData: Data! = try JSONSerialization.data(withJSONObject: tempDict!) as Data
          let pluginResult: CDVPluginResult! = CDVPluginResult(
            status: CDVCommandStatus_OK, messageAs: String(data: jsonData, encoding: .utf8))
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        } catch let error {
          print(error)
          let pluginResult: CDVPluginResult! = CDVPluginResult(
            status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription)
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
      }
    })
  }

  @objc(getNearbyPointsOfInterest:)
  func getNearbyPointsOfInterest(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let locationDict: NSDictionary! = command.arguments[0] as? NSDictionary
      let latitude: CLLocationDegrees =
        locationDict.value(forKey: self.LOWERCASE_LATITUDE) as? Double ?? 0
      let longitude: CLLocationDegrees =
        locationDict.value(forKey: self.LOWERCASE_LONGITUDE) as? Double ?? 0
      let currentLocation: CLLocation! = CLLocation(latitude: latitude, longitude: longitude)
      let limit: UInt = command.arguments[1] as? UInt ?? 0
      var currentPoisString: String! = self.EMPTY_ARRAY_STRING

      Places.getNearbyPointsOfInterest(
        forLocation: currentLocation, withLimit: limit,
        closure: { retrievedPois, responseCode in
          currentPoisString = self.generatePOIString(retrievedPois: retrievedPois)
        })

      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        let pluginResult: CDVPluginResult! = CDVPluginResult(
          status: CDVCommandStatus_OK, messageAs: currentPoisString)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      }
    })
  }

  @objc(processGeofence:)
  func processGeofence(command: CDVInvokedUrlCommand) {
      self.commandDelegate.run(inBackground: {
          guard let geofenceDict = command.arguments[0] as? [String: Any],
                let regionDict = geofenceDict[self.CIRCULAR_REGION] as? [String: Any],
                let latitude = regionDict[self.LOWERCASE_LATITUDE] as? Double,
                let longitude = regionDict[self.LOWERCASE_LONGITUDE] as? Double,
                let radius = regionDict[self.RADIUS] as? Double,
                let identifier = geofenceDict[self.REQUEST_ID] as? String,
                let eventTypeRaw = command.arguments[1] as? Int,
                let eventType = PlacesRegionEvent(rawValue: eventTypeRaw) else {
              let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Invalid geofence data")
              self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
              return
          }
          let center = CLLocationCoordinate2DMake(latitude, longitude)
          let region = CLCircularRegion(center: center, radius: radius, identifier: identifier)
          Places.processRegionEvent(eventType, forRegion: region)
          let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
      })
  }

  @objc(setAuthorizationStatus:)
  func setAuthorizationStatus(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let status: Int = command.arguments[0] as? Int ?? 0
      Places.setAuthorizationStatus(self.convertToCLAuthorizationStatus(status: status))
      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  /*
     * Helper functions
     */

  func generatePOIString(retrievedPois: [AnyObject]!) -> String! {
    let retrievedPoisArray: NSMutableArray! = NSMutableArray()
    if retrievedPois != nil && retrievedPois.count > 0 {

      retrievedPois.forEach({
        (anyCurrentPoi) in

        let tempDict: NSMutableDictionary! = NSMutableDictionary()
        let currentPoi = anyCurrentPoi as! PointOfInterest
        tempDict.setValue(currentPoi.name, forKey: self.POI)
        tempDict.setValue(currentPoi.latitude, forKey: self.LATITUDE)
        tempDict.setValue(currentPoi.longitude, forKey: self.LONGITUDE)
        tempDict.setValue(currentPoi.identifier, forKey: self.IDENTIFIER)
        retrievedPoisArray.add(tempDict as Any)
      })

      do {
        let jsonData: Data! = try JSONSerialization.data(withJSONObject: retrievedPoisArray as Any)
        return String(data: jsonData, encoding: .utf8)
      } catch let error {
        print(error)
      }
    }
    return EMPTY_ARRAY_STRING
  }

  func convertToCLAuthorizationStatus(status: Int) -> CLAuthorizationStatus {
    switch status {
    case 0:
      return CLAuthorizationStatus.denied
    case 1:
      return CLAuthorizationStatus.authorizedAlways
    case 2:
      return CLAuthorizationStatus.notDetermined
    case 3:
      return CLAuthorizationStatus.restricted
    default:
      return CLAuthorizationStatus.authorizedWhenInUse
    }
  }
}