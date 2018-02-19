# frozen_string_literal: true

module Spree
  class ProductPromotionRule < Spree::Base
    belongs_to :product
    belongs_to :promotion_rule
  end
end
