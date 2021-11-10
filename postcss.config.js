module.exports = {
  plugins: [
    require("postcss-import"),
    require("autoprefixer"),
    require("tailwindcss"),
    require("postcss-preset-env")({
      autoprefixer: {
        flexbox: "no-2009",
      },
      stage: 3,
    }),

    require("postcss-flexbugs-fixes"),
  ],
};
