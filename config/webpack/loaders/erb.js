// source: https://www.npmjs.com/package/rails-erb-loader

module.exports = {
  test: /\.erb$/,
  enforce: 'pre',
  exclude: /node_modules/,
  use: [{
    loader: 'rails-erb-loader',
    options: {
      runner: './bin/rails runner'
    }
  }]
}
