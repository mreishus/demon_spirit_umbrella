const purgecss = require("@fullhuman/postcss-purgecss")({
  // Specify the paths to all of the template files in your project
  content: [
    "./js/**/*.html",
    "./js/**/*.jsx",
    "./js/**/*.js",
    "./js/**/*.tsx",
    "./js/**/*.ts",
    "../lib/demon_spirit_web/templates/**/*.eex",
    "../lib/demon_spirit_web/templates/**/*.leex",
    "./css/components/*.css"
    // etc.
  ],
  defaultExtractor: content => content.match(/[\w-/:]+(?<!:)/g) || []
});

//console.log({ z: process.env.npm_lifecycle_event === "deploy" });

module.exports = {
  plugins: [
    require("postcss-import"),
    require("tailwindcss"),
    require("autoprefixer"),
    ...(process.env.npm_lifecycle_event === "deploy" ? [purgecss] : [])
  ]
};
