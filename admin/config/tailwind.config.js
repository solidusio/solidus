const defaultTheme = require('tailwindcss/defaultTheme')
const plugin = require('tailwindcss/plugin')
const adminRoot = __dirname.replace(/\/config$/, '')

module.exports = {
  content: [
    `${adminRoot}/{app/helpers,app/views,app/components,app/assets/javascripts,spec/components/previews}/**/*`,
  ],
  theme: {
    extend: {
      aria: {
        current: 'current="true"',
      },
      fontFamily: {
        sans: ["Inter var", ...defaultTheme.fontFamily.sans],
      },
      colors: {
        transparent: "transparent",
        current: "currentColor",

        // Primary palette
        "solidus-red": "#ef3023",
        black: "#222222",
        graphite: "#c7ccc7",
        "graphite-light": "#d8dad8",
        sand: "#f5f3f0",
        white: "#ffffff",

        // Secondary palette
        yellow: "#fdc071",
        orange: "#f68050",
        blue: "#2554b1",
        moss: "#2d3925",
        forest: "#096756",
        midnight: "#163449",
        pink: "#f6d7e2",
        plum: "#3a0e31",
        sky: "#cbdff1",
        seafoam: "#c1e0de",
        dune: "#e6bf9b",
        "full-black": "#000000",

        // Extra colors (not part of the original palette)
        "papaya-whip": "#f9e3d9",
        sazerac: "#fcf0dd",

        // UI Red
        red: {
          100: "#f8d6d3",
          200: "#f1ada7",
          300: "#ea8980",
          400: "#e36054",
          500: "#dc3728",
          600: "#b12c20",
          700: "#862219",
          800: "#561610",
          900: "#2b0b08",
        },

        // Grayscale
        gray: {
          15: "#fafafa",
          25: "#f5f5f5",
          50: "#f0f0f0",
          100: "#dedede",
          200: "#cfcfcf",
          300: "#bababa",
          400: "#a3a3a3",
          500: "#737373",
          600: "#616161",
          700: "#4a4a4a",
          800: "#333333",
        },
      },
      borderRadius: {
        sm: "4px",
      },
      backgroundImage: {
        "arrow-right-up-line": "url('solidus_admin/arrow_right_up_line.svg')",
        "arrow-down-s-fill-gray-700": "url('solidus_admin/arrow_down_s_fill_gray_700.svg')",
        "arrow-down-s-fill-red-400": "url('solidus_admin/arrow_down_s_fill_red_400.svg')",
      },
      boxShadow: {
        sm: "0px 1px 2px 0px rgba(0, 0, 0, 0.04)",
        base: "0px 4px 8px 0px rgba(0, 0, 0, 0.08), 0px 2px 4px -1px rgba(0, 0, 0, 0.04)",
      },
      height: {
        "5.5": "1.375rem",
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms")({ strategy: "class" }),
    require("@tailwindcss/aspect-ratio"),
    require("@tailwindcss/typography"),
    require("@tailwindcss/container-queries"),
    plugin(({ addVariant, addBase, addComponents, theme }) => {
      // Support the "hidden" attribute
      addVariant("hidden", "&([hidden])")
      addVariant("visible", "&:not([hidden])")

      // Support the "search-cancel" pseudo-element
      addVariant("search-cancel", "&::-webkit-search-cancel-button")

      // Reset the <summary> marker
      addBase({
        "summary::-webkit-details-marker": { display: "none" },
        "summary::marker": { display: "none" },
        summary: { listStyle: "none" },
      })

      // Add a text style for links
      addComponents({
        ".body-link": {
          color: theme("colors.blue"),
          "&:hover": {
            textDecoration: "underline",
          },
        },
      })
    }),
  ],
}
