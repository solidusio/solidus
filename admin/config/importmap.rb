# Remember to restart your application after editing this file.

# Stimulus & Turbo
pin "@hotwired/stimulus", to: "stimulus.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@hotwired/turbo-rails", to: "turbo.js"

pin "stimulus-use", to: "https://ga.jspm.io/npm:stimulus-use@0.52.0/dist/index.js"

pin "tailwindcss", to: "https://cdn.tailwindcss.com/3.3.3?plugins=typography,aspect-ratio"
pin "@tailwindcss/aspect-ratio", to: "https://ga.jspm.io/npm:@tailwindcss/aspect-ratio@0.4.2/src/index.js"
pin "@tailwindcss/container-queries", to: "https://ga.jspm.io/npm:@tailwindcss/container-queries@0.1.1/dist/index.js"
pin "@tailwindcss/forms", to: "https://ga.jspm.io/npm:@tailwindcss/forms@0.5.6/src/index.js"
pin "@tailwindcss/typography", to: "https://ga.jspm.io/npm:@tailwindcss/typography@0.5.10/src/index.js"

pin "mini-svg-data-uri", to: "https://ga.jspm.io/npm:mini-svg-data-uri@1.4.4/index.js"
pin "picocolors", to: "https://ga.jspm.io/npm:picocolors@1.0.0/picocolors.browser.js"
pin "tailwindcss/colors", to: "https://ga.jspm.io/npm:tailwindcss@3.3.3/colors.js"
pin "tailwindcss/defaultTheme", to: "https://ga.jspm.io/npm:tailwindcss@3.3.3/defaultTheme.js"
pin "tailwindcss/plugin", to: "https://ga.jspm.io/npm:tailwindcss@3.3.3/plugin.js"

pin "solidus_admin/application", preload: true
pin "solidus_admin/utils"
pin_all_from SolidusAdmin::Engine.root.join("app/javascript/solidus_admin/controllers"), under: "solidus_admin/controllers"
pin_all_from SolidusAdmin::Engine.root.join("app/components")
