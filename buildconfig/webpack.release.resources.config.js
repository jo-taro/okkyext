var path = require('path');
var CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = {
    context: path.normalize(__dirname + '/..'),
    entry : {},
    output: {
      filename : 'manifest.json'  
    },
    plugins: [
        new CopyWebpackPlugin([
            { from: 'resources', to: 'release'},    // for svg and css
        ])
    ]
};