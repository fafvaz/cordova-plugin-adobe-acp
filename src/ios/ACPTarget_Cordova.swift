import AEPTarget

@objc(ACPTarget_Cordova) class ACPTarget_Cordova: CDVPlugin {

  @objc(clearPrefetchCache:)
  func clearPrefetchCache(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      Target.clearPrefetchCache()
      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(extensionVersion:)
  func extensionVersion(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      var pluginResult: CDVPluginResult! = nil
      let extensionVersion: String! = Target.extensionVersion

      if extensionVersion != nil && extensionVersion.count > 0 {
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: extensionVersion)
      } else {
        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
      }

      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(getThirdPartyId:)
  func getThirdPartyId(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      Target.getThirdPartyId({ (thirdPartyId: String?, error) in
        if error == nil {
          let pluginResult: CDVPluginResult! = CDVPluginResult(
            status: CDVCommandStatus_OK, messageAs: thirdPartyId)
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        } else {
          let pluginResult: CDVPluginResult! = CDVPluginResult(
            status: CDVCommandStatus_ERROR, messageAs: error?.localizedDescription)
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
      })
    })
  }

  @objc(getTntId:)
  func getTntId(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      Target.getTntId({ (tntId: String?, error) in

        if error == nil {
          let pluginResult: CDVPluginResult! = CDVPluginResult(
            status: CDVCommandStatus_OK, messageAs: tntId)
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        } else {
          let pluginResult: CDVPluginResult! = CDVPluginResult(
            status: CDVCommandStatus_ERROR, messageAs: error?.localizedDescription)
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }

      })
    })
  }

  @objc(resetExperience:)
  func resetExperience(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      Target.resetExperience()
      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(setThirdPartyId:)
  func setThirdPartyId(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let thirdPartyId: String! = command.arguments[0] as? String

      Target.setThirdPartyId(thirdPartyId)

      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(setPreviewRestartDeepLink:)
  func setPreviewRestartDeepLink(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {

      guard let deepLink = URL(string: command.arguments[0] as! String) else {
        self.commandDelegate.send(
          CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: "Unable setPreviewRestartDeepLink. Input was malformed"),
          callbackId: command.callbackId)
        return
      }

      Target.setPreviewRestartDeepLink(deepLink)

      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(retrieveLocationContent:)
func retrieveLocationContent(command: CDVInvokedUrlCommand) {
    self.commandDelegate.run(inBackground: {
        guard let locationRequests = command.arguments[0] as? [String: [String: Any]] else {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Invalid location requests")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }
        var requestArray: [TargetRequest] = []
        for (_, requestDict) in locationRequests {
            guard let mboxName = requestDict["mboxName"] as? String else { continue }
            let mboxParam = requestDict["mboxParameter"] as? [String: String]
            let profileParam = requestDict["profileParameter"] as? [String: String]
            var orderParameters: TargetOrder?
            if let orderParam = requestDict["orderParameter"] as? [String: Any],
               let orderId = orderParam["orderId"] as? String,
               let orderTotal = orderParam["orderTotal"] as? Double,
               let purchasedIds = orderParam["orderPurchasedIds"] as? [String] {
                orderParameters = TargetOrder(id: orderId, total: orderTotal, purchasedProductIds: purchasedIds)
            }
            var productParameter: TargetProduct?
            if let productParam = requestDict["productParameter"] as? [String: Any],
               let id = productParam["id"] as? String,
               let categoryId = productParam["categoryId"] as? String {
                productParameter = TargetProduct(productId: id, categoryId: categoryId)
            }
            let targetParameters = TargetParameters(
                parameters: mboxParam,
                profileParameters: profileParam,
                order: orderParameters,
                product: productParameter)
            let requestObject = TargetRequest(mboxName: mboxName, defaultContent: "defaultContent", targetParameters: targetParameters, contentCallback: nil)
            requestArray.append(requestObject)
        }
        guard let requestLoc = command.arguments[1] as? [String: Any] else {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Invalid request location")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }
        let mboxLocParam = requestLoc["mboxParameter"] as? [String: String]
        let profileLocParam = requestLoc["profileParameter"] as? [String: String]
        var orderLocParameters: TargetOrder?
        if let orderLocParam = requestLoc["orderParameter"] as? [String: Any],
           let orderId = orderLocParam["orderId"] as? String,
           let orderTotal = orderLocParam["orderTotal"] as? Double,
           let purchasedIds = orderLocParam["orderPurchasedIds"] as? [String] {
            orderLocParameters = TargetOrder(id: orderId, total: orderTotal, purchasedProductIds: purchasedIds)
        }
        var productLocParameter: TargetProduct?
        if let productLocParam = requestLoc["productParameter"] as? [String: Any],
           let id = productLocParam["id"] as? String,
           let categoryId = productLocParam["categoryId"] as? String {
            productLocParameter = TargetProduct(productId: id, categoryId: categoryId)
        }
        let targetLocParameters = TargetParameters(
            parameters: mboxLocParam,
            profileParameters: profileLocParam,
            order: orderLocParameters,
            product: productLocParameter)
        Target.retrieveLocationContent(requestArray, with: targetLocParameters)
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
}

  @objc(locationClicked:)
  func locationClicked(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {

      let mboxName: String! = command.arguments[0] as? String
      let request: NSDictionary! = command.arguments[1] as? NSDictionary
      var profileParam: NSDictionary!
      var mboxParam: NSDictionary!
      var orderParam: NSDictionary!
      var productParam: NSDictionary!
      var orderParameters: TargetOrder! = nil
      var targetParameters: TargetParameters! = nil
      var productParameter: TargetProduct! = nil

      if request.object(forKey: "mboxParameter") != nil {
        mboxParam = request.object(forKey: "mboxParameter") as? NSDictionary
      }
      if request.object(forKey: "profileParameter") != nil {
        profileParam = request.object(forKey: "profileParameter") as? NSDictionary
      }

      if request.object(forKey: "orderParameter") != nil {
        orderParam = request.object(forKey: "orderParameter") as? NSDictionary
        if orderParam.object(forKey: "orderId") != nil {
          let orderId: String! = orderParam.object(forKey: "orderId") as? String
          let orderTotal: Double! = orderParam.object(forKey: "orderTotal") as? Double
          let orderPurchasedIds: [String]! =
            orderParam.object(forKey: "orderPurchasedIds") as? [String]
          orderParameters = TargetOrder(
            id: orderId, total: orderTotal, purchasedProductIds: orderPurchasedIds)
        }
      }

      if request.object(forKey: "productParameter") != nil {
        productParam = request.object(forKey: "productParameter") as? NSDictionary
        if productParam.object(forKey: "id") != nil {
          let id: String! = productParam.object(forKey: "id") as? String
          let categoryIdValue: String! = productParam.object(forKey: "categoryId") as? String
          productParameter = TargetProduct(productId: id, categoryId: categoryIdValue)
        }
      }

      targetParameters = TargetParameters(
        parameters: mboxParam as? [String: String],
        profileParameters: profileParam as? [String: String],
        order: orderParameters, product: productParameter)

      Target.clickedLocation(mboxName, targetParameters: targetParameters)

      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(locationsDisplayed:)
  func locationsDisplayed(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {
      let mboxLists: [String]! = command.arguments[0] as? [String]
      let request: NSDictionary! = command.arguments[1] as? NSDictionary
      var profileParam: NSDictionary!
      var mboxParam: NSDictionary!
      var orderParam: NSDictionary!
      var productParam: NSDictionary!
      var orderParameters: TargetOrder! = nil
      var targetParameters: TargetParameters! = nil
      var productParameter: TargetProduct! = nil

      if request.object(forKey: "mboxParameter") != nil {
        mboxParam = request.object(forKey: "mboxParameter") as? NSDictionary
      }
      if request.object(forKey: "profileParameter") != nil {
        profileParam = request.object(forKey: "profileParameter") as? NSDictionary
      }

      if request.object(forKey: "orderParameter") != nil {
        orderParam = request.object(forKey: "orderParameter") as? NSDictionary
        if orderParam.object(forKey: "orderId") != nil {
          let orderId: String! = orderParam.object(forKey: "orderId") as? String
          let orderTotal: Double! = orderParam.object(forKey: "orderTotal") as? Double
          let orderPurchasedIds: [String]! =
            orderParam.object(forKey: "orderPurchasedIds") as? [String]
          orderParameters = TargetOrder(
            id: orderId, total: orderTotal, purchasedProductIds: orderPurchasedIds)
        }
      }

      if request.object(forKey: "productParameter") != nil {
        productParam = request.object(forKey: "productParameter") as? NSDictionary
        if productParam.object(forKey: "id") != nil {
          let id: String! = productParam.object(forKey: "id") as? String
          let categoryIdValue: String! = productParam.object(forKey: "categoryId") as? String
          productParameter = TargetProduct(productId: id, categoryId: categoryIdValue)
        }
      }

      targetParameters = TargetParameters(
        parameters: mboxParam as? [String: String],
        profileParameters: profileParam as? [String: String],
        order: orderParameters, product: productParameter)

      Target.displayedLocations(mboxLists, targetParameters: targetParameters)

      let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    })
  }

  @objc(prefetchContent:)
  func prefetchContent(command: CDVInvokedUrlCommand!) {
    self.commandDelegate.run(inBackground: {

      let locationRequests: NSDictionary! = command.arguments[0] as? NSDictionary
      let requestArray: NSMutableArray! = NSMutableArray.init()
      var profileParam: NSDictionary!
      var mboxParam: NSDictionary!
      var orderParam: NSDictionary!
      var productParam: NSDictionary!
      var profileLocParam: NSDictionary!
      var mboxLocParam: NSDictionary!
      var orderLocParam: NSDictionary!
      var productLocParam: NSDictionary!
      var orderParameters: TargetOrder! = nil
      var targetParameters: TargetParameters! = nil
      var productParameter: TargetProduct! = nil
      var orderLocParameters: TargetOrder! = nil
      var targetLocParameters: TargetParameters! = nil
      var productLocParameter: TargetProduct! = nil

      locationRequests.forEach { (key: Any, valueObj: Any) in
        let request: NSDictionary! = valueObj as? NSDictionary
        let mboxName: String! = request.object(forKey: "mboxName") as? String

        if request.object(forKey: "mboxParameter") != nil {
          mboxParam = request.object(forKey: "mboxParameter") as? NSDictionary
        }
        if request.object(forKey: "profileParameter") != nil {
          profileParam = request.object(forKey: "profileParameter") as? NSDictionary
        }

        if request.object(forKey: "orderParameter") != nil {
          orderParam = request.object(forKey: "orderParameter") as? NSDictionary
          if orderParam.object(forKey: "orderId") != nil {
            let orderId: String! = orderParam.object(forKey: "orderId") as? String
            let orderTotal: Double! = orderParam.object(forKey: "orderTotal") as? Double
            let orderPurchasedIds: [String]! =
              orderParam.object(forKey: "orderPurchasedIds") as? [String]
            orderParameters = TargetOrder(
              id: orderId, total: orderTotal, purchasedProductIds: orderPurchasedIds)
          }
        }

        if request.object(forKey: "productParameter") != nil {
          productParam = request.object(forKey: "productParameter") as? NSDictionary
          if productParam.object(forKey: "id") != nil {
            let id: String! = productParam.object(forKey: "id") as? String
            let categoryIdValue: String! = productParam.object(forKey: "categoryId") as? String
            productParameter = TargetProduct(productId: id, categoryId: categoryIdValue)
          }
        }

        targetParameters = TargetParameters(
          parameters: mboxParam as? [String: String],
          profileParameters: profileParam as? [String: String],
          order: orderParameters, product: productParameter)

        let requestObject: TargetPrefetch! = TargetPrefetch(
          name: mboxName,
          targetParameters: targetParameters)

        requestArray.add(requestObject as Any)

      }

      let requestLoc: NSDictionary! = command.arguments[1] as? NSDictionary

      if requestLoc.object(forKey: "mboxParameter") != nil {
        mboxLocParam = requestLoc.object(forKey: "mboxParameter") as? NSDictionary
      }
      if requestLoc.object(forKey: "profileParameter") != nil {
        profileLocParam = requestLoc.object(forKey: "profileParameter") as? NSDictionary
      }

      if requestLoc.object(forKey: "orderParameter") != nil {
        orderLocParam = requestLoc.object(forKey: "orderParameter") as? NSDictionary
        if orderLocParam.object(forKey: "orderId") != nil {
          let orderId: String! = orderLocParam.object(forKey: "orderId") as? String
          let orderTotal: Double! = orderLocParam.object(forKey: "orderTotal") as? Double
          let orderPurchasedIds: [String]! =
            orderLocParam.object(forKey: "orderPurchasedIds") as? [String]
          orderLocParameters = TargetOrder(
            id: orderId, total: orderTotal, purchasedProductIds: orderPurchasedIds)
        }
      }

      if requestLoc.object(forKey: "productParameter") != nil {
        productLocParam = requestLoc.object(forKey: "productParameter") as? NSDictionary
        if productLocParam.object(forKey: "id") != nil {
          let id: String! = productLocParam.object(forKey: "id") as? String
          let categoryIdValue: String! = productLocParam.object(forKey: "categoryId") as? String
          productLocParameter = TargetProduct(productId: id, categoryId: categoryIdValue)
        }
      }

      targetLocParameters = TargetParameters(
        parameters: mboxLocParam as? [String: String],
        profileParameters: profileLocParam as? [String: String],
        order: orderLocParameters, product: productLocParameter)

      Target.prefetchContent(
        requestArray as! [TargetPrefetch], with: targetLocParameters,
        { (error) in
          let pluginResult: CDVPluginResult! = CDVPluginResult(status: CDVCommandStatus_OK)
          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        })

    })
  }
}
