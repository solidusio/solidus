# frozen_string_literal: true

module Solidus
  class ProductPromotionRule < Solidus::Base
    belongs_to :product, optional: true
    belongs_to :promotion_rule, optional: true
  end
end
