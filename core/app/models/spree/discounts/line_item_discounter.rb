# frozen_string_literal: true

module Spree
  module Discounts
    class LineItemDiscounter
      attr_reader :promotions

      def initialize(promotions:)
        @promotions = promotions
      end

      def call(line_item)
        discounts = promotions.select do |promotion|
          promotion.eligible_rules(line_item)
        end.flat_map do |promotion|
          promotion.actions.select do |action|
            action.can_discount? Spree::LineItem
          end.map do |action|
            action.discount(line_item)
          end
        end

        chosen_discounts = Spree::Config.discount_chooser_class.new(line_item).call(discounts)
        line_item.discounts = chosen_discounts
      end
    end
  end
end
