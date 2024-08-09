# frozen_string_literal: true

pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true

pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from SolidusPromotions::Engine.root.join("app/javascript/backend/solidus_promotions/controllers"),
  under: "backend/solidus_promotions/controllers"
pin_all_from SolidusPromotions::Engine.root.join("app/javascript/backend/solidus_promotions/jquery"),
  under: "backend/solidus_promotions/jquery"
pin_all_from SolidusPromotions::Engine.root.join("app/javascript/backend/solidus_promotions/web_components"),
  under: "backend/solidus_promotions/web_components"

pin "backend/solidus_promotions", to: "backend/solidus_promotions.js", preload: true
