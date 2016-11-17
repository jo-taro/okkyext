var path = require('path');
var CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = {
    context: path.normalize(__dirname + '/..'),
    entry : {},
    output: {
      // FIXME: how to just use copywebpack without filename?
      filename : 'manifest.json'
    },
    plugins: [
        new CopyWebpackPlugin([
            { from: 'resources', to: 'debug'},    // for svg and css
        ])
    ]
};