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

var ACPTarget = (function () {
  var exec = require('cordova/exec');
  var ACPTarget = (typeof exports !== 'undefined' && exports) || {};
  var PLUGIN_NAME = 'ACPTarget_Cordova';
  // ===========================================================================
  // public APIs
  // ===========================================================================

  ACPTarget.clearPrefetchCache = function (success, error) {
    var FUNCTION_NAME = 'clearPrefetchCache';

    if (success && !isFunction(success)) {
      printNotAFunction('success', FUNCTION_NAME);
      return;
    }

    if (error && !isFunction(error)) {
      printNotAFunction('error', FUNCTION_NAME);
      return;
    }

    exec(success, error, 'ACPTarget_Cordova', FUNCTION_NAME, []);
  };

  ACPTarget.extensionVersion = function (success, fail) {
    var FUNCTION_NAME = 'extensionVersion';

    if (success && !acpIsFunction(success)) {
      printNotAFunction('success', FUNCTION_NAME);
      return;
    }

    if (fail && !acpIsFunction(fail)) {
      printNotAFunction('fail', FUNCTION_NAME);
      return;
    }

    return exec(success, fail, PLUGIN_NAME, FUNCTION_NAME, []);
  };

  ACPTarget.getThirdPartyId = function (success, fail) {
    var FUNCTION_NAME = 'getThirdPartyId';

    if (success && !acpIsFunction(success)) {
      printNotAFunction('success', FUNCTION_NAME);
      return;
    }

    if (fail && !acpIsFunction(fail)) {
      printNotAFunction('fail', FUNCTION_NAME);
      return;
    }

    return exec(success, fail, PLUGIN_NAME, FUNCTION_NAME, []);
  };

  ACPTarget.getTntId = function (success, fail) {
    var FUNCTION_NAME = 'getTntId';

    if (success && !acpIsFunction(success)) {
      printNotAFunction('success', FUNCTION_NAME);
      return;
    }

    if (fail && !acpIsFunction(fail)) {
      printNotAFunction('fail', FUNCTION_NAME);
      return;
    }

    return exec(success, fail, PLUGIN_NAME, FUNCTION_NAME, []);
  };

  ACPTarget.resetExperience = function (success, fail) {
    var FUNCTION_NAME = 'resetExperience';

    if (success && !acpIsFunction(success)) {
      printNotAFunction('success', FUNCTION_NAME);
      return;
    }

    if (fail && !acpIsFunction(fail)) {
      printNotAFunction('fail', FUNCTION_NAME);
      return;
    }

    return exec(success, fail, PLUGIN_NAME, FUNCTION_NAME, []);
  };

  ACPTarget.setPreviewRestartDeepLink = function (deepLink, success, fail) {
    var FUNCTION_NAME = 'setPreviewRestartDeepLink';

    if (!isString(deepLink)) {
      printNotAString('deepLink', FUNCTION_NAME);
      return;
    }

    if (success && !acpIsFunction(success)) {
      printNotAFunction('success', FUNCTION_NAME);
      return;
    }

    if (fail && !acpIsFunction(fail)) {
      printNotAFunction('fail', FUNCTION_NAME);
      return;
    }

    return exec(success, fail, PLUGIN_NAME, FUNCTION_NAME, [deepLink]);
  };

  ACPTarget.setThirdPartyId = function (thirdPartyId, success, fail) {
    var FUNCTION_NAME = 'setThirdPartyId';

    if (!isString(thirdPartyId)) {
      printNotAString('thirdPartyId', FUNCTION_NAME);
      return;
    }

    if (success && !acpIsFunction(success)) {
      printNotAFunction('success', FUNCTION_NAME);
      return;
    }

    if (fail && !acpIsFunction(fail)) {
      printNotAFunction('fail', FUNCTION_NAME);
      return;
    }

    return exec(success, fail, PLUGIN_NAME, FUNCTION_NAME, [thirdPartyId]);
  };

  ACPTarget.retrieveLocationContent = function (requestParameters, locationParameters, success, fail) {
    var FUNCTION_NAME = 'retrieveLocationContent';

    if (!isObject(requestParameters)) {
      printNotAnObject('requestParameters', FUNCTION_NAME);
      return;
    }

    if (!isObject(locationParameters)) {
      printNotAnObject('locationParameters', FUNCTION_NAME);
      return;
    }

    if (success && !acpIsFunction(success)) {
      printNotAFunction('success', FUNCTION_NAME);
      return;
    }

    if (fail && !acpIsFunction(fail)) {
      printNotAFunction('fail', FUNCTION_NAME);
      return;
    }

    return exec(success, fail, PLUGIN_NAME, FUNCTION_NAME, [requestParameters, locationParameters]);
  };

  ACPTarget.locationClicked = function (mboxName, parameters, success, fail) {
    var FUNCTION_NAME = 'locationClicked';

    if (!isString(mboxName)) {
      printNotAString('mboxName', FUNCTION_NAME);
      return;
    }

    if (!isObject(parameters)) {
      printNotAnObject('parameters', FUNCTION_NAME);
      return;
    }

    if (success && !acpIsFunction(success)) {
      printNotAFunction('success', FUNCTION_NAME);
      return;
    }

    if (fail && !acpIsFunction(fail)) {
      printNotAFunction('fail', FUNCTION_NAME);
      return;
    }

    return exec(success, fail, PLUGIN_NAME, FUNCTION_NAME, [mboxName, parameters]);
  };

  ACPTarget.locationsDisplayed = function (mboxNameList, targetParameters, success, fail) {
    var FUNCTION_NAME = 'locationsDisplayed';

    if (!isArray(mboxNameList)) {
      printNotAnObject('mboxNameList', FUNCTION_NAME);
      return;
    }

    if (!isObject(targetParameters)) {
      printNotAnObject('targetParameters', FUNCTION_NAME);
      return;
    }

    if (success && !acpIsFunction(success)) {
      printNotAFunction('success', FUNCTION_NAME);
      return;
    }

    if (fail && !acpIsFunction(fail)) {
      printNotAFunction('fail', FUNCTION_NAME);
      return;
    }

    return exec(success, fail, PLUGIN_NAME, FUNCTION_NAME, [mboxNameList, targetParameters]);
  };

  ACPTarget.prefetchContent = function (prefetchMboxesList, targetParameters, success, fail) {
    var FUNCTION_NAME = 'prefetchContent';

    if (!isObject(prefetchMboxesList)) {
      printNotAnObject('requestParameters', FUNCTION_NAME);
      return;
    }

    if (!isObject(targetParameters)) {
      printNotAnObject('locationParameters', FUNCTION_NAME);
      return;
    }

    if (success && !acpIsFunction(success)) {
      printNotAFunction('success', FUNCTION_NAME);
      return;
    }

    if (fail && !acpIsFunction(fail)) {
      printNotAFunction('fail', FUNCTION_NAME);
      return;
    }

    return exec(success, fail, PLUGIN_NAME, FUNCTION_NAME, [prefetchMboxesList, targetParameters]);
  };

  return ACPTarget;
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

function isNumber(value) {
  return typeof value === 'number' && isFinite(value);
}

function printNotANumber(paramName, functionName) {
  if (functionName == 'syncIdentifiers') {
    console.log("Ignoring call to '" + functionName + "'. The '" + paramName + "' parameter is required to be a Number or Null.");
  } else {
    console.log("Ignoring call to '" + functionName + "'. The '" + paramName + "' parameter is required to be a Number.");
  }
}

function isObject(value) {
  return value && typeof value === 'object' && value.constructor === Object;
}

function isArray(value) {
  return value && typeof value === 'object' && value.constructor === Array;
}

function printNotAnObject(paramName, functionName) {
  console.log("Ignoring call to '" + functionName + "'. The '" + paramName + "' parameter is required to be an Object.");
}

function isFunction(value) {
  return typeof value === 'function';
}

function printNotAFunction(paramName, functionName) {
  console.log("Ignoring call to '" + functionName + "'. The '" + paramName + "' parameter is required to be a function.");
}

module.exports = ACPTarget;
