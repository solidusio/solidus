# Remember to restart your application after editing this file.

# Stimulus & Turbo
pin "@hotwired/stimulus", to: "stimulus.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@hotwired/turbo-rails", to: "turbo.js"

pin "stimulus-use", to: "https://ga.jspm.io/npm:stimulus-use@0.52.0/dist/index.js"
pin "sortablejs", to: "https://cdn.jsdelivr.net/npm/sortablejs@1.15.0/+esm"
pin "@rails/request.js", to: "https://cdn.jsdelivr.net/npm/@rails/request.js@0.0.9/+esm"

pin "solidus_admin/application", preload: true
pin "solidus_admin/utils"
pin "solidus_admin/tom-select", to: "solidus_admin/tom-select/tom-select.js"
pin "vendor/custom_elements", preload: true

pin_all_from SolidusAdmin::Engine.root.join("app/javascript/solidus_admin/controllers"), under: "solidus_admin/controllers"
pin_all_from SolidusAdmin::Engine.root.join("app/components")
pin_all_from SolidusAdmin::Engine.root.join("app/javascript/solidus_admin/web_components"), under: "solidus_admin/web_components"

pin "tom-select", to: "https://ga.jspm.io/npm:tom-select@2.4.3/dist/esm/tom-select.complete.js"
pin "@orchidjs/sifter", to: "https://ga.jspm.io/npm:@orchidjs/sifter@1.1.0/dist/esm/sifter.js"
pin "@orchidjs/unicode-variants", to: "https://ga.jspm.io/npm:@orchidjs/unicode-variants@1.1.2/dist/esm/index.js"
