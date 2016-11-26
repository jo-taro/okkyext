/* global exports */
"use strict";

exports.parents = function(selector) {
    return function(ob) {
        return function() {
            return ob.parents(selector);
        };
    };
};

exports.cssp = function(props) {
    return function(ob) {
        return function() {
            var new_props = {}
            for (var p in props) {
              new_props[p.replace('_','-')] = props[p];
            } 
            console.log(new_props);
            ob.css(new_props);
        };
    };
};