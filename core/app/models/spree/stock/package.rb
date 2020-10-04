# frozen_string_literal: true

module Spree
  module Stock
    class Package
      attr_reader :stock_location, :contents
      attr_accessor :shipment

      # @param stock_location [Spree::StockLocation] the stock location this package originates from
      # @param contents [Array<Spree::Stock::ContentItem>] the contents of this package
      def initialize(stock_location, contents = [])
        @stock_location = stock_location
        @contents = contents
      end

      # Adds an inventory unit to this package.
      #
      # @param inventory_unit [Spree::InventoryUnit] an inventory unit to be
      #   added to this package
      # @param state [:on_hand, :backordered] the state of the item to be
      #   added to this package
      def add(inventory_unit, state = :on_hand)
        contents << ContentItem.new(inventory_unit, state) unless find_item(inventory_unit)
      end

      # Adds multiple inventory units to this package.
      #
      # @param inventory_units [Array<Spree::InventoryUnit>] a collection of
      #   inventory units to be added to this package
      # @param state [:on_hand, :backordered] the state of the items to be
      #   added to this package
      def add_multiple(inventory_units, state = :on_hand)
        inventory_units.each { |inventory_unit| add(inventory_unit, state) }
      end

      # Removes a given inventory unit from this package.
      #
      # @param inventory_unit [Spree::InventoryUnit] the inventory unit to be
      #   removed from this package
      def remove(inventory_unit)
        item = find_item(inventory_unit)
        @contents -= [item] if item
      end

      # @return [Spree::Order] the order associated with this package
      def order
        # Fix regression that removed package.order.
        # Find it dynamically through an inventory_unit.
        contents.detect { |item| !!item.try(:line_item).try(:order) }.try(:line_item).try(:order)
      end

      # @return [Float] the summed weight of the contents of this package
      def weight
        contents.sum(&:weight)
      end

      # @return [Array<Spree::Stock::ContentItem>] the content items in this
      #   package which are on hand
      def on_hand
        contents.select(&:on_hand?)
      end

      # @return [Array<Spree::Stock::ContentItem>] the content items in this
      #   package which are backordered
      def backordered
        contents.select(&:backordered?)
      end

      # Find a content item in this package by inventory unit and optionally
      # state.
      #
      # @param inventory_unit [Spree::InventoryUnit] the desired inventory
      #   unit
      # @param state [:backordered, :on_hand, nil] the state of the desired
      #   content item, or nil for any state
      def find_item(inventory_unit, state = nil)
        contents.detect do |item|
          item.inventory_unit == inventory_unit &&
            (!state || item.state.to_s == state.to_s)
        end
      end

      # @param state [:backordered, :on_hand, nil] the state of the content
      #   items of which we want the quantity, or nil for the full quantity
      # @return [Fixnum] the number of inventory units in the package,
      #   counting only those in the given state if it was specified
      def quantity(state = nil)
        matched_contents = state.nil? ? contents : contents.select { |content| content.state.to_s == state.to_s }
        matched_contents.sum(&:quantity)
      end

      # @return [Boolean] true if there are no inventory units in this
      #   package
      def empty?
        quantity == 0
      end

      # @return [String] the currency of the order this package belongs to
      def currency
        order.currency
      end

      # @return [Array<Spree::ShippingCategory>] the shipping categories of the
      #   variants in this package
      def shipping_categories
        Spree::ShippingCategory.where(id: shipping_category_ids)
      end

      # @return [ActiveRecord::Relation] the [Spree::ShippingMethod]s available
      #   for this pacakge based on the stock location and shipping categories.
      def shipping_methods
        Spree::ShippingMethod.
          with_all_shipping_category_ids(shipping_category_ids).
          available_in_stock_location(stock_location)
      end

      # @return [Spree::Shipment] a new shipment containing this package's
      #   inventory units, with the appropriate shipping rates and associated
      #   with the correct stock location
      def to_shipment
        # At this point we should only have one content item per inventory unit
        # across the entire set of inventory units to be shipped, which has
        # been taken care of by the Prioritizer
        contents.each { |content_item| content_item.inventory_unit.state = content_item.state.to_s }

        Spree::Shipment.new(
          order: order,
          stock_location: stock_location,
          inventory_units: contents.map(&:inventory_unit)
        )
      end

      private

      # @return [Array<Fixnum>] the unique ids of all shipping categories of
      #   variants in this package
      def shipping_category_ids
        contents.map { |item| item.variant.shipping_category_id }.compact.uniq
      end
    end
  end
end
