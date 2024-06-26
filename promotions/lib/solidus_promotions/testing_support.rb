# frozen_string_literal: true

module SolidusPromotions
  module TestingSupport
    def self.factories_path
      ::SolidusPromotions::Engine.root.join("lib", "solidus_promotions", "testing_support", "factories")
    end
  end
end
