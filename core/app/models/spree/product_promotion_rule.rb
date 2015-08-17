module Spree
  class ProductPromotionRule < Spree::Base
    self.table_name = 'spree_products_promotion_rules'

    belongs_to :product
    belongs_to :promotion_rule
  end
end
