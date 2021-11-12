module.exports = {
  darkMode: "media",
  // jit mode, this is still in preview but speeds up build
  // not compatible with semantic versioning yet
  mode: "jit",
  purge: {
    content: ["app/**/*.html.haml", "app/javascript/**/*.js"],
    preserveHtmlElements: false,
    options: {
      defaultExtractor: (content) => content.match(/[^%#=<>"{\.'`\s]*[^%#=<>"{}\.'`\s:]/g) || [],
    },
  },
  theme: {
    extend: {
      colors: {
        board: "#fe7215",
      },
    },
    screens: {
      // these breakpoints are copied from Yeti
      // the xs breakpoint doesn't make much sense
      //xs: '0',
      sm: "576px",
      md: "768px",
      lg: "992px",
      xl: "1200px",
    },
  },
  variants: {
    display: ["dark"],
  },
  plugins: [],
};
