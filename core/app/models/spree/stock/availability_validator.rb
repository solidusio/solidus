# frozen_string_literal: true

module Spree
  module Stock
    class AvailabilityValidator < ActiveModel::Validator
      def validate(line_item)
        if is_valid?(line_item)
          true
        else
          variant = line_item.variant
          display_name = variant.name.to_s
          display_name += %{ (#{variant.options_text})} unless variant.options_text.blank?

          line_item.errors.add(:quantity, I18n.t(
            "spree.selected_quantity_not_available",
            item: display_name.inspect
          ))
          false
        end
      end

      private

      def is_valid?(line_item)
        if line_item.inventory_units.empty?
          Spree::Config.stock.quantifier_class.new(line_item.variant).can_supply?(line_item.quantity)
        else
          quantity_by_variant_and_stock_location = line_item.inventory_units.pending.joins(:shipment)
            .group(:variant_id, :stock_location_id).count
          variant_ids = quantity_by_variant_and_stock_location.keys.map(&:first)
          variants = Spree::Variant.with_discarded.where(id: variant_ids).index_by(&:id)

          quantity_by_variant_and_stock_location.all? do |(variant_id, stock_location_id), quantity|
            Spree::Config.stock.quantifier_class.new(variants.fetch(variant_id), stock_location_id).can_supply?(quantity)
          end
        end
      end
    end
  end
end
