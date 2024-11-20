# frozen_string_literal: true

module SolidusLegacyPromotions
  module SpreeProductDecorator
    def self.prepended(base)
      base.has_many :product_promotion_rules, dependent: :destroy
      base.has_many :promotion_rules, through: :product_promotion_rules

      base.after_discard do
        self.product_promotion_rules = []
      end
    end

    ::Spree::Product.prepend self
  end
end
