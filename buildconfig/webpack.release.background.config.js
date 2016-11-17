var path = require('path');
var webpack = require('webpack');

module.exports = {
  context: path.normalize(__dirname + '/..'),
  entry: {
    background: ['./support/background-entry.js']
  },

  output: {
    path: path.resolve('./release'),
    // filename: '[name]-[hash].min.js',
    filename: '[name].min.js',
    publicPath: '/release/'
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
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify('production')
    }),
    new webpack.optimize.UglifyJsPlugin(),
    new webpack.optimize.OccurrenceOrderPlugin(true),
    new webpack.LoaderOptionsPlugin({
      minimize: true,
      debug: false
    }),
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
