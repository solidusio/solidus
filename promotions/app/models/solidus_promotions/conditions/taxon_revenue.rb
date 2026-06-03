# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    class TaxonRevenue < Condition
      include OrderLevelCondition
      include TaxonCondition

      preference :operator, :string, default: "gte"
      preference :amount, :decimal, default: 0
      preference :currency, :string, default: -> { Spree::Config.currency }

      OPERATORS = {"gte" => :>=, "gt" => :>, "lt" => :<, "lte" => :<=}.freeze

      def self.operator_options
        OPERATORS.map do |name, _method|
          [I18n.t(name, scope: [:solidus_promotions, :operators]), name]
        end
      end

      def order_eligible?(order, _options = {})
        matching = order.line_items.select do |line_item|
          taxon_ids_with_children.any? do |taxon_and_descendant_ids|
            (line_item.variant.product.classifications.map(&:taxon_id) & taxon_and_descendant_ids).any?
          end
        end
        matching.sum(&:discounted_amount).public_send(OPERATORS.fetch(preferred_operator), preferred_amount)
      end
    end
  end
end
