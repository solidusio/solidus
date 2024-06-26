# frozen_string_literal: true

pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true

pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from SolidusPromotions::Engine.root.join("app/javascript/solidus_promotions/controllers"),
  under: "solidus_promotions/controllers"
pin_all_from SolidusPromotions::Engine.root.join("app/javascript/solidus_promotions/jquery"),
  under: "solidus_promotions/jquery"
pin_all_from SolidusPromotions::Engine.root.join("app/javascript/solidus_promotions/web_components"),
  under: "solidus_promotions/web_components"

pin "solidus_promotions", to: "solidus_promotions.js", preload: true
