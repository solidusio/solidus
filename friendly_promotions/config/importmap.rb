pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true

pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from SolidusFriendlyPromotions::Engine.root.join("app/javascript/solidus_friendly_promotions/controllers"), under: "solidus_friendly_promotions/controllers"

pin "solidus_friendly_promotions", to: "solidus_friendly_promotions.js", preload: true
