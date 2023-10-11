# frozen_string_literal: true

module SolidusFriendlyPromotions
  module TestingSupport
    def self.factories_path
      ::SolidusFriendlyPromotions::Engine.root.join("lib", "solidus_friendly_promotions", "testing_support", "factories")
    end
  end
end
