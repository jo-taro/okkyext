var path = require('path');
var webpack = require('webpack');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var CopyWebpackPlugin = require('copy-webpack-plugin');

var port = process.env.PORT || 3000;

module.exports = {
  context: path.normalize(__dirname + '/..'),
  entry: {
    options: ['webpack-hot-middleware/client?reload=true',
              './support/options-entry.js']
  },

  output: {
    path: path.resolve('./debug'),
    filename: '[name].js',
    publicPath: '/'
  },

  devtool: 'cheap-module-eval-source-map',
  devServer: {
    contentBase: path.resolve('./debug'),
    noInfo: false,
    inline: true,
    headers: { "Access-Control-Allow-Origin": "*" }
  },
  module: {
    loaders: [
      // { test: /\.js$/,
      //   loader: 'source-map-loader',
      //   exclude: /node_modules|bower_components/ 
      // },
      { test: /\.js$/,
        loader: 'babel-loader',
        exclude: /node_modules|bower_components/,
        query: {
          presets: ['es2015']
        }
      }, 
      {
        test: /\.purs$/,
        loader: 'purs-loader',
        exclude: /node_modules/,
        query: {
          psc: 'psa',
          pscArgs: {
            sourceMaps: false
          }
        }
      }
    ],
  },
  plugins: [
    new CopyWebpackPlugin([
      // { from: 'res' },    // for svg and css
    ]),
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify('development')
    }),
    new webpack.optimize.OccurrenceOrderPlugin(true),
    new webpack.LoaderOptionsPlugin({
      debug: true
    }),
    new webpack.SourceMapDevToolPlugin({
      filename: '[file].map',
      moduleFilenameTemplate: '[absolute-resource-path]',
      fallbackModuleFilenameTemplate: '[absolute-resource-path]'
    }),
    new HtmlWebpackPlugin({
      template: 'support/options-template.html',
      inject: 'body',
      filename: 'options.html'
    }),
    new webpack.HotModuleReplacementPlugin(),
    new webpack.NoErrorsPlugin(),
  ],
  resolveLoader: {
    modules: [
      path.join(__dirname, '/../', 'node_modules')
    ]
  }
  ,
  resolve: {
    modules: [
      'node_modules',
      'bower_components'
    ],
    extensions: ['.js', '.purs']
  },
};
