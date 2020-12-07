
module.exports = {
  purge: [
    './src/**/*.haml',
    './src/javascript/**/*.js'
  ],
  theme: {
    extend: {},
    colors: {
      // this colors are copied from Yeti
      transparent: 'transparent',
      blue: '#008cba',
      indigo: '#6610f2',
      purple: '#6f42c1',
      pink: '#e83e8c',
      red: '#F04124',
      orange: '#fd7e14',
      yellow: '#E99002',
      green: '#43ac6a',
      teal: '#20c997',
      cyan: '#5bc0de',
      white: '#fff',
      gray: '#888',
      'gray-dark': '#333',
      primary: '#008cba',
      secondary: '#eee',
      success: '#43ac6a',
      info: '#5bc0d',
      warning: '#E99002',
      danger: '#F04124',
      light: '#eee',
      dark: '#222',
    },
    screens: {
      // this breakpoints are copied from Yeti
      // the xs breakpoint doesn't make much sense
      //xs: '0',
      sm: '576px',
      md: '768px',
      lg: '992px',
      xl: '1200px',
    }
  },
  variants: {},
  plugins: [],
}
