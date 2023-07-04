# frozen_string_literal: true

module SolidusFriendlyPromotions
  class ProductsRule < Spree::Base
    belongs_to :product, class_name: "Spree::Product"
    belongs_to :rule
  end
end
