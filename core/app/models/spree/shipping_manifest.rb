# frozen_string_literal: true

class Spree::ShippingManifest
  ManifestItem = Struct.new(:line_item, :variant, :quantity, :states)

  attr_reader :inventory_units, :order

  # @param inventory_units [Enumerable<Spree::InventoryUnit>]
  # @param order [Spree::Order, nil] the order the units belong to. When
  #   given and its line items are already loaded, the manifest reuses those
  #   +Spree::LineItem+ instances rather than letting each inventory unit
  #   load its own copy.
  def initialize(inventory_units:, order: nil)
    @inventory_units = inventory_units
    @order = order
  end

  def for_order(order)
    self.class.new(
      inventory_units: inventory_units.select { |unit| unit.order_id == order.id },
      order: order
    )
  end

  def items
    # Grouping by the ID means that we don't have to call out to the association accessor
    # This makes the grouping by faster because it results in less SQL cache hits.
    inventory_units.group_by(&:variant_id).flat_map do |_variant_id, variant_units|
      variant_units.group_by(&:line_item_id).map do |line_item_id, line_item_units|
        states = {}
        line_item_units.group_by(&:state).each { |state, iu| states[state] = iu.count }

        first_unit = line_item_units.first

        ManifestItem.new(
          line_item_for(line_item_id, first_unit),
          first_unit.variant,
          line_item_units.length,
          states
        )
      end
    end
  end

  private

  # Prefer the instance the order already holds in memory. Rails has no identity
  # map, so +unit.line_item+ returns a second instance of the same row: it does
  # not reflect adjustments that have been recalculated on the order's own line
  # items but not yet persisted, and it costs a query per line item on top.
  def line_item_for(line_item_id, unit)
    order_line_items.fetch(line_item_id) { unit.line_item }
  end

  # Empty unless the order's line items are already loaded. This is an
  # optimization for callers that have them, never a reason to run a query.
  def order_line_items
    @order_line_items ||=
      if order&.association(:line_items)&.loaded?
        order.line_items.index_by(&:id)
      else
        {}
      end
  end
end
