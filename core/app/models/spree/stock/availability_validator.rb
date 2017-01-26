module Spree
  module Stock
    class AvailabilityValidator < ActiveModel::Validator
      def validate(line_item)
        quantity_by_stock_location_id = line_item.inventory_units.pending.joins(:shipment).group(:stock_location_id).count

        if quantity_by_stock_location_id.blank?
          ensure_in_stock(line_item, line_item.quantity)
        else
          quantity_by_stock_location_id.each do |stock_location_id, quantity|
            ensure_in_stock(line_item, quantity, stock_location_id)
          end
        end

        line_item.errors[:quantity].empty?
      end

      private

      def ensure_in_stock(line_item, quantity, stock_location = nil)
        quantifier = Stock::Quantifier.new(line_item.variant, stock_location)
        unless quantifier.can_supply?(quantity)
          variant = line_item.variant
          display_name = variant.name.to_s
          display_name += %{ (#{variant.options_text})} unless variant.options_text.blank?

          line_item.errors[:quantity] << Spree.t(
            :selected_quantity_not_available,
            item: display_name.inspect
          )
        end
      end
    end
  end
end
