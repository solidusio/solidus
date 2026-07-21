# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    class TaxonRevenue < Condition
      include OrderLevelCondition
      include TaxonCondition

      preference :operator, :string, default: "gte"
      preference :amount, :decimal, default: 0
      preference :currency, :string, default: -> { Spree::Config.currency }
      preference :match_policy, :string, default: "include"

      OPERATORS = {"gte" => :>=, "gt" => :>, "lt" => :<, "lte" => :<=}.freeze
      MATCH_POLICIES = ["include", "exclude"].freeze

      validates :preferred_match_policy, inclusion: {in: MATCH_POLICIES}

      def self.operator_options
        OPERATORS.map do |name, _method|
          [I18n.t(name, scope: [:solidus_promotions, :operators]), name]
        end
      end

      def self.match_policy_options
        MATCH_POLICIES.map do |name|
          [I18n.t(name, scope: %i[solidus_promotions conditions taxon_revenue match_policies]), name]
        end
      end

      def order_eligible?(order, _options = {})
        matching = order.line_items.select { |line_item| taxon_match?(line_item) }

        matching.sum(&:discounted_amount).public_send(OPERATORS.fetch(preferred_operator), preferred_amount)
      end

      private

      def taxon_match?(line_item)
        line_item_taxon_ids = line_item.variant.product.classifications.map(&:taxon_id)

        in_selected_taxons = taxon_ids_with_children.any? do |taxon_and_descendant_ids|
          (line_item_taxon_ids & taxon_and_descendant_ids).any?
        end

        (preferred_match_policy == "exclude") ? !in_selected_taxons : in_selected_taxons
      end
    end
  end
end
