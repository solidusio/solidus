# frozen_string_literal: true

class Spree::ShippingManifest
  ManifestItem = Struct.new(:line_item, :variant, :quantity, :states)

  def initialize(inventory_units:)
    @inventory_units = inventory_units.to_a
  end

  def for_order(order)
    Spree::ShippingManifest.new(
      inventory_units: @inventory_units.select { |iu| iu.order_id == order.id }
    )
  end

  def items
    # Grouping by the ID means that we don't have to call out to the association accessor
    # This makes the grouping by faster because it results in less SQL cache hits.
    @inventory_units.group_by(&:variant_id).map do |_variant_id, variant_units|
      variant_units.group_by(&:line_item_id).map do |_line_item_id, units|
        states = {}
        units.group_by(&:state).each { |state, iu| states[state] = iu.count }

        first_unit = units.first

        ManifestItem.new(first_unit.line_item, first_unit.variant, units.length, states)
      end
    end.flatten
  end
end
