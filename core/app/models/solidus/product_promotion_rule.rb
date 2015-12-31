module Spree
  class ProductPromotionRule < Solidus::Base
    belongs_to :product
    belongs_to :promotion_rule
  end
end
