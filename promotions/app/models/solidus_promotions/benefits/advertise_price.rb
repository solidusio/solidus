# frozen_string_literal: true

module SolidusPromotions
  module Benefits
    class AdvertisePrice < Benefit
      def self.applicable_conditions
        Condition.applicable_to([Spree::Order, Spree::Price])
      end

      def discount_price(price, ...)
        discount = find_discount(price) || build_discount
        discount.amount = compute_amount(price, ...)
        discount.label = adjustment_label(price)
        discount
      end

      private

      def find_discount(price)
        price.discounts.detect { |discount| discount.source == self }
      end

      def build_discount
        SolidusPromotions::ItemDiscount.new(source: self)
      end
    end
  end
end
