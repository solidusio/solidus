# frozen_string_literal: true

module SolidusLegacyPromotions
  module Spree
    module ProductDecorator
      def self.prepended(base)
        base.has_many :product_promotion_rules, dependent: :destroy
        base.has_many :promotion_rules, through: :product_promotion_rules

        base.after_discard do
          self.product_promotion_rules = []
        end
      end

      # @return [Array] all advertised and not-rejected promotions
      def possible_promotions
        promotion_ids = promotion_rules.map(&:promotion_id).uniq
        ::Spree::Promotion.advertised.where(id: promotion_ids).reject(&:inactive?)
      end

      ::Spree::Product.prepend self
    end
  end
end
