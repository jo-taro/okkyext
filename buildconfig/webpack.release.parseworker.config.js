var path = require('path');
var webpack = require('webpack');

module.exports = {
  context: path.normalize(__dirname + '/..'),
  entry: {
    parseworker : ['./support/parseworker-entry.js']
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
    new webpack.ProvidePlugin({
      jQuery: "jquery"
    }),
    // new webpack.optimize.DedupePlugin(),
    new webpack.optimize.UglifyJsPlugin({
          beautify: false, // Don't beautify output (enable for neater output)
          comments: false, // Eliminate comments
          compress: {
            warnings: false, // Compression specific options
            drop_console: true // Drop `console` statements
          },
          mangle: { // Mangling specific options
            // except: ['$'], // Don't mangle $
            screw_ie8 : true, // Don't care about IE8
            // keep_fnames: true // Don't mangle function names
          }
    }),
    new webpack.optimize.OccurrenceOrderPlugin(false),
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
