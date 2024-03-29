module.exports = {
  content: [
    "./js/**/*.html",
    "./js/**/*.jsx",
    "./js/**/*.js",
    "./js/**/*.tsx",
    "./js/**/*.ts",
    "../lib/demon_spirit_web/templates/**/*.eex",
    "../lib/demon_spirit_web/templates/**/*.leex",
    "../lib/demon_spirit_web/templates/**/*.heex",
    "../lib/demon_spirit_web/views/**/*.ex",
    "./css/components/*.css",
    // etc.
  ],
  theme: {
    extend: {
      colors: {
        "black-80": "rgba(0,0,0,0.8)",
        "black-70": "rgba(0,0,0,0.7)",
        "black-60": "rgba(0,0,0,0.6)",
        "black-50": "rgba(0,0,0,0.5)",
        "black-40": "rgba(0,0,0,0.4)",
        "blue-400-50": "rgba(99,179,237,0.5)",
      },
      spacing: {
        72: "18rem",
        96: "24rem",
        112: "28rem",
        128: "32rem",
      },
      zIndex: {
        2000: 2000,
        10000: 10000,
      },
    },
  },
};
