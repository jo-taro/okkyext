var path = require('path');
var webpack = require('webpack');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = {
  context: path.normalize(__dirname + '/..'),
  entry: {
    options : ['./support/options-entry-production.js']
  },
  output: {
    path: path.resolve('./release'),
    filename: '[name].min.js',
    publicPath: '/'
  },
  module: {
    loaders: [
      {
        test: /\.purs$/,
        loader: 'purs-loader',
        exclude: /node_modules/,
        query: {
          psc: 'psa',
          bundle: true,
          warnings: false
        }
      }
    ],
  },
  plugins: [
    new webpack.optimize.UglifyJsPlugin(),
    new webpack.optimize.OccurrenceOrderPlugin(),
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify('production')
    }),
    new webpack.optimize.OccurrenceOrderPlugin(true),
    new webpack.LoaderOptionsPlugin({
      minimize: true,
      debug: false
    }),
    new HtmlWebpackPlugin({
      template: 'support/options-template.html',
      inject: 'body',
      filename: 'options.html'
    }),
    new CopyWebpackPlugin([
      { from: 'resources', to: './'},    // for svg and css
      { from: 'manifest/manifest-release.json', to:'./manifest.json' },
    ]),
  ],
  resolveLoader: {
    modules: [
      path.join(__dirname, '/../', 'node_modules')
    ]
  },
  resolve: {
    modules: [
      'node_modules',
      'bower_components'
    ],
    extensions: ['.js', '.purs']
  }
};
