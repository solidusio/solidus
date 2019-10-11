# frozen_string_literal: true

module Solidus
  class ReturnItem < Solidus::Base
    module ExchangeVariantEligibility
      class SameProduct
        def self.eligible_variants(variant, stock_locations: nil)
          Solidus::Variant.where(product_id: variant.product_id, is_master: variant.is_master?).in_stock(stock_locations)
        end
      end
    end
  end
end
