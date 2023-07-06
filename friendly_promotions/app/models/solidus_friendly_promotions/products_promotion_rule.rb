# frozen_string_literal: true

module SolidusFriendlyPromotions
  class ProductsPromotionRule < Spree::Base
    belongs_to :product, class_name: "Spree::Product"
    belongs_to :promotion_rule
  end
end