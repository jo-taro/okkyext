/* global exports */
"use strict";

exports.parents = function(selector) {
    return function(ob) {
        return function() {
            return ob.parents(selector);
        };
    };
};
