module.exports = {
  darkMode: 'class',
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*',
    './app/components/**/*'
  ],
  theme: {
    screens: {
      xs: '320px',
      sm: '576px',
      md: '768px',
      lg: '992px',
      xl: '1200px',
      '2xl': '1386px',
      '3xl': '1536px',
    },
    fontFamily: {
      sans: ['Inter Regular', 'system-ui', 'sans-serif'],
      'sans-md': ['"Inter Medium"', 'system-ui', 'sans-serif'],
      serif: ['Source Serif', 'system-ui', 'serif'],
      'serif-md': ['"Source Serif Medium"', 'system-ui', 'serif'],
    },
    fontSize: {
      h1: ['4rem', '120%'],
      h2: ['3.375rem', '125%'],
      'h2.5': ['3rem', '125%'],
      h3: ['2.5rem', '125%'],
      h4: ['2rem', '125%'],
      h5: ['1.75rem', '125%'],
      h6: ['1.5rem', '125%'],
      'body-lg': ['1.5rem', '150%'],
      'body-22': ['1.375rem', '150%'],
      'body-20': ['1.25rem', '140%'],
      'body-md': ['1.125rem', '140%'],
      body: ['1rem', '120%'],
      'body-15.5': ['0.968rem', '120%'],
      'body-sm': ['0.875rem', '120%'],
      'body-xs': '0.75rem',
      'body-2xs': '0.625rem',
      eyebrow: [
        '0.875rem',
        {
          lineHeight: '1',
          letterSpacing: '0.07em',
        },
      ],
      caption: ['0.75rem', '150%'],
    },
    extend: {
      aspectRatio: {
        auto: "auto",
        square: "1 / 1",
        "4/5": "4 / 5",
        "4/5_3": "4 / 5.3",
      },
      backgroundSize: {
        '85': '85%',
      },
      colors: {
        primary: '#EF3023',
        black: '#222222',
        'light-black': '#333333',
        sand: '#F5F3F0',
        pink: '#F6D7E2',
        seafoam: '#C1E0DE',
        plum: '#3A0E31',
        sky: '#CBDFF1',
        moss: '#2D3925',
        blue: '#2554B1',
        midnight: '#163449',
        orange: '#F68050',
        yellow: '#FDC071',
        forrest: '#096756',
        dune: '#E6BF9B',
        'solidus-red': '#EF3023',
        red: {
          100: '#F8D7D4',
          200: '#F1AFA9',
          300: '#EA877E',
          400: '#E35F53',
          500: '#DC3728',
          600: '#B02C20',
        },
        gray: {
          primary: '#C7CCC7',
          mid: '#D8DAD8',
          25: '#FAFAFA',
          50: '#E8E8E8',
          100: '#DDDDDD',
          200: '#CFCFCF',
          300: '#BBBBBB',
          400: '#A2A2A2',
          500: '#828282',
          600: '#616161',
          700: '#4B4B4B',
          800: '#333333',
        },
      },
      width: {
        '1_col-3': '32%',
        'collection-card': 'calc(33%-12px)' // assumes 3 cards shown with space-x-6 (24px) in between.
      },
      height: {
        '1_col-3': '32%',
      },
      borderRadius: {
        '2xl': '2rem'
      }
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography')
  ]
}
