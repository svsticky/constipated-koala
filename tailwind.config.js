module.exports = {
  purge: {
    mode: 'production',
    content: ['./src/**/*.html'],
  },
  future: {
    removeDeprecatedGapUtilities: true,
  },
  theme: {
    extend: {},
  },
  variants: {},
  plugins: [],
}
