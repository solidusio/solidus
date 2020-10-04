const merge = require('webpack-merge');
const common = require('./webpack.common.js');
const MinifyPlugin = require('babel-minify-webpack-plugin');

module.exports = merge(common, {
  plugins: [
    new MinifyPlugin()
  ]
});