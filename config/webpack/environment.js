const { environment } = require('@rails/webpacker')
const erb = require('./loaders/erb')
const webpack = require('webpack')

environment.loaders.prepend('erb', erb)

environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    Popper: ['popper.js', 'default'],
    toastr: 'toastr/toastr',
    Rails: ['@rails/ujs']
  })
)
module.exports = environment
