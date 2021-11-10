const { webpackConfig, merge } = require("@rails/webpacker");
const webpack = require("webpack");

const baseConfig = {
  plugins: [
    new webpack.ProvidePlugin({
      $: "jquery",
      jQuery: "jquery",
      Popper: ["popper.js", "default"],
      toastr: "toastr/toastr",
      Rails: ["@rails/ujs"],
    })
  ],
  module: {
    rules: [
      require("./loaders/erb")
    ]
  }
};

module.exports = merge(webpackConfig, baseConfig);
