const { environment } = require("@rails/webpacker");
const erb = require("./loaders/erb");
const webpack = require("webpack");

environment.loaders.prepend("erb", erb);

environment.plugins.prepend(
  "Provide",
  new webpack.ProvidePlugin({
    $: "jquery",
    jQuery: "jquery",
    Popper: ["popper.js", "default"],
    toastr: "toastr/toastr",
    Rails: ["@rails/ujs"],
  })
);

// Get the actual sass-loader config
const sassLoader = environment.loaders.get('sass')
const sassLoaderConfig = sassLoader.use.find(function(element) {
  return element.loader == 'sass-loader'
})

// Use Dart-implementation of Sass (default is node-sass)
const options = sassLoaderConfig.options
options.implementation = require('sass')

function hotfixPostcssLoaderConfig(subloader) {
  const subloaderName = subloader.loader;
  if (subloaderName === "postcss-loader") {
    subloader.options.postcssOptions = subloader.options.config;
    delete subloader.options.config;
  }
}

environment.loaders.keys().forEach((loaderName) => {
  const loader = environment.loaders.get(loaderName);
  loader.use.forEach(hotfixPostcssLoaderConfig);
});

module.exports = environment;
