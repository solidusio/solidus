# frozen_string_literal: true

module Solidus
  # Relatively simple class used to apply a {Solidus::Tax::OrderTax} to a
  # {Solidus::Order}.
  #
  # This class will create or update adjustments on the taxed items and remove
  # any now inapplicable tax adjustments from the order.
  class OrderTaxation
    # Create a new order taxation.
    #
    # @param [Solidus::Order] order the order to apply taxes to
    # @return [Solidus::OrderTaxation] a {Solidus::OrderTaxation} object
    def initialize(order)
      @order = order
    end

    # Apply taxes to the order.
    #
    # This method will create or update adjustments on all line items and
    # shipments in the order to reflect the appropriate taxes passed in. It
    # will also remove any now inapplicable tax adjustments.
    #
    # @param [Solidus::Tax::OrderTax] taxes the taxes to apply to the order
    # @return [void]
    def apply(taxes)
      @order.line_items.each do |item|
        taxed_items = taxes.line_item_taxes.select { |i| i.item_id == item.id }
        update_adjustments(item, taxed_items)
      end

      @order.shipments.each do |item|
        taxed_items = taxes.shipment_taxes.select { |i| i.item_id == item.id }
        update_adjustments(item, taxed_items)
      end
    end

    private

    # Walk through the taxes for an item and update adjustments for it. Once
    # all of the taxes have been added as adjustments, remove any old tax
    # adjustments that weren't touched.
    #
    # @private
    # @param [#adjustments] item a {Solidus::LineItem} or {Solidus::Shipment}
    # @param [Array<Solidus::Tax::ItemTax>] taxed_items a list of calculated taxes for an item
    # @return [void]
    def update_adjustments(item, taxed_items)
      tax_adjustments = item.adjustments.select(&:tax?)

      active_adjustments = taxed_items.map do |tax_item|
        update_adjustment(item, tax_item)
      end

      # Remove any tax adjustments tied to rates which no longer match.
      unmatched_adjustments = tax_adjustments - active_adjustments
      item.adjustments.destroy(unmatched_adjustments)
    end

    # Update or create a new tax adjustment on an item.
    #
    # @private
    # @param [#adjustments] item a {Solidus::LineItem} or {Solidus::Shipment}
    # @param [Solidus::Tax::ItemTax] tax_item calculated taxes for an item
    # @return [Solidus::Adjustment] the created or updated tax adjustment
    def update_adjustment(item, tax_item)
      tax_adjustment = item.adjustments.detect do |adjustment|
        adjustment.source == tax_item.tax_rate
      end

      tax_adjustment ||= item.adjustments.new(
        source: tax_item.tax_rate,
        order_id: item.order_id,
        label: tax_item.label,
        included: tax_item.included_in_price
      )
      tax_adjustment.update!(amount: tax_item.amount)
      tax_adjustment
    end
  end
end
