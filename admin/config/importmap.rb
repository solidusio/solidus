# Remember to restart your application after editing this file.

# Stimulus & Turbo
pin "@hotwired/stimulus", to: "stimulus.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@hotwired/turbo-rails", to: "turbo.js"

pin "solidus_admin/application", preload: true
pin_all_from SolidusAdmin::Engine.root.join("app/javascript/solidus_admin/controllers"), under: "solidus_admin/controllers"
pin_all_from SolidusAdmin::Engine.root.join("app/components")
