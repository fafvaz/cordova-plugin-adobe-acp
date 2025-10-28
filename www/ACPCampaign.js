/*
 Copyright 2020 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0
 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

var ACPCampaign = (function () {
  var exec = require('cordova/exec');
  var ACPCampaign = (typeof exports !== 'undefined' && exports) || {};
  var PLUGIN_NAME = 'ACPCampaign_Cordova';
  // ===========================================================================
  // public APIs
  // ===========================================================================

  // Gets the current Analytics extension version.
  ACPCampaign.extensionVersion = function (success, error) {
    var FUNCTION_NAME = 'extensionVersion';

    if (success && !isFunction(success)) {
      printNotAFunction('success', FUNCTION_NAME);
      return;
    }

    if (error && !isFunction(error)) {
      printNotAFunction('error', FUNCTION_NAME);
      return;
    }

    exec(success, error, PLUGIN_NAME, FUNCTION_NAME, []);
  };
 
  //Call setPushIdentifer to send the push identifier that is received from the APNS or FCM to the Adobe Identity service
  ACPCampaign.setPushIdentifier = function (DeviceToken, FiscalNumber, success, error) {
    var FUNCTION_NAME = 'setPushIdentifier';
    if (success && !isFunction(success)) {
      printNotAFunction('success', FUNCTION_NAME);
      return;
    }
    if (error && !isFunction(error)) {
      printNotAFunction('error', FUNCTION_NAME);
      return;
    }

  exec(success, error, PLUGIN_NAME, FUNCTION_NAME, [DeviceToken, FiscalNumber]);
  
  };

  ACPCampaign.loadAdobe = function (deviceToken, fiscalNumber, success, error) {

    var FUNCTION_NAME = 'loadAdobe';
    exec(success, error, PLUGIN_NAME, FUNCTION_NAME, [deviceToken, fiscalNumber]);
};

  return ACPCampaign;
})();



// ===========================================================================
// helper functions
// ===========================================================================
function isString(value) {
  return typeof value === 'string' || value instanceof String;
}

function printNotAString(paramName, functionName) {
  console.log("Ignoring call to '" + functionName + "'. The '" + paramName + "' parameter is required to be a String.");
}

function isFunction(value) {
  return typeof value === 'function';
}

function printNotAFunction(paramName, functionName) {
  console.log("Ignoring call to '" + functionName + "'. The '" + paramName + "' parameter is required to be a function.");
}

module.exports = ACPCampaign;
