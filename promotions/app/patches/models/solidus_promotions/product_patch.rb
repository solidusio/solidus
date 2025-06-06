# frozen_string_literal: true

module SolidusPromotions
  module ProductPatch
    extend ActiveSupport::Concern

    def self.prepended(base)
      base.delegate :discounted_price, :undiscounted_price, :price_discounts, to: :master
    end
    Spree::Product.prepend self
  end
end
