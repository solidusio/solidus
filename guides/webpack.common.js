const webpack = require('webpack');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const Clean = require('clean-webpack-plugin');
const autoprefixer = require('autoprefixer');


module.exports = {
  //Entry points(js, scss files)
  entry: {
    "common": './source/assets/javascripts/common.js',
    "search": './source/assets/javascripts/search.js',
    "site": './source/assets/stylesheets/site.scss',
    "vendor": ["jquery", "bootstrap"],
  },
  output: {
    path: __dirname + '/.tmp/assets/javascripts',
    filename: '[name].js',
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: "babel-loader"
      },
      /*
      your other rules for JavaScript transpiling go in here
      */
      { // sass / scss loader for webpack
        test: /\.(sass|scss)$/,
        loader: ExtractTextPlugin.extract({
          use: [
            {
              loader: 'css-loader',
              options: {
                sourceMap: true
              }
            },
            {
              loader: 'postcss-loader',
              options: {
                plugins: [
                  autoprefixer({
                    // grid: true
                  })
                ],
                sourceMap: true
              }
            },
            {
              loader: 'sass-loader',
              options: {
                sourceMap: true
              }
            },
          ]
        })
      }
    ]
  },
  resolve: {
    modules: ['node_modules']
  },
  plugins: [
    new Clean(['.tmp/assets']),
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
      'window.jQuery': 'jquery',
      Popper: ['popper.js', 'default'],
      headroom: 'headroom.js'
    }),
    new ExtractTextPlugin({ // define where to save the file
      filename: '../stylesheets/site.css',
      allChunks: true,
    }),
    new webpack.optimize.CommonsChunkPlugin({
      name: "vendor",
      // filename: "vendor.js"
      // (Give the chunk a different name)

      minChunks: Infinity,
      // (with more entries, this ensures that no other module
      //  goes into the vendor chunk)
    }),
    new CopyWebpackPlugin([
      {from: __dirname + '/source/assets/javascripts/modernizr', to: __dirname + '/.tmp/assets/javascripts'},
      {from: __dirname + '/source/assets/images', to: __dirname + '/.tmp/assets/images'}
    ]),
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify('production')
    })
  ]
};
