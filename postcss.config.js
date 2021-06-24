module.exports = {
  plugins: [
    require('@tailwindcss/postcss7-compat'),
    require('autoprefixer'),
    require('postcss-import'),
    require('postcss-flexbugs-fixes'),
    require('postcss-preset-env')({
      autoprefixer: {
        flexbox: 'no-2009'
      },
      stage: 3
    }),
    require("@fullhuman/postcss-purgecss")({
      content: [
        "./app/**/*.haml",
        "./app/javascript/**/*.js"
      ],
      defaultExtractor: content => content.match(/[^<>"{\.'`\s]*[^<>"{\.'`\s:]/g) || []
    })
  ]
}
