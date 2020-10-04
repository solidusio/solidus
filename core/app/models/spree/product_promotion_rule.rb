# frozen_string_literal: true

module Spree
  class ProductPromotionRule < Spree::Base
    belongs_to :product, optional: true
    belongs_to :promotion_rule, optional: true
  end
end
