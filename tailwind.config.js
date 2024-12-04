import defaultTheme from "tailwindcss/defaultTheme";

export default {
  content: [
    "./app/views/**/*.html.erb",
    "./app/helpers/**/*.rb",
    "./app/assets/stylesheets/**/*.css",
    "./app/javascript/**/*.js",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Inter var", ...defaultTheme.fontFamily.sans],
      },
      maxWidth: {
        ...defaultTheme.maxWidth,
        "7xl": "80rem", // 1280px
        "8xl": "90rem", // 1440px
        "9xl": "96rem", // 1536px
        full: "100%",
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/typography"),
    require("@tailwindcss/container-queries"),
  ],
};
