/* global exports */
"use strict";

exports["sendMessage"] = function (cmd) {
    return function(cb) {
        return function() {
          chrome.runtime.sendMessage(cmd, function(d) { 
            cb(d)();
        });
        };
    };
};

exports["addListener"]= function(cb) {
    return function() {
      chrome.runtime.onMessage.addListener( function(r,s,resp){ 
        cb(r)(s)( function(d) { return function() { 
          resp(d);
        };})();
      });
    };
};

exports["responseCallback"]= function(d) {
    return function(cb) {
        return function() {
          cb(d);
    };
  };
};

