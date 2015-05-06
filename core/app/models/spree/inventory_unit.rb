module Spree
  class InventoryUnit < Spree::Base
    PRE_SHIPMENT_STATES = %w(backordered on_hand)
    POST_SHIPMENT_STATES = %w(returned)
    CANCELABLE_STATES = ['on_hand', 'backordered']

    belongs_to :variant, class_name: "Spree::Variant", inverse_of: :inventory_units
    belongs_to :order, class_name: "Spree::Order", inverse_of: :inventory_units
    belongs_to :shipment, class_name: "Spree::Shipment", touch: true, inverse_of: :inventory_units
    belongs_to :return_authorization, class_name: "Spree::ReturnAuthorization", inverse_of: :inventory_units
    belongs_to :carton, class_name: "Spree::Carton", inverse_of: :inventory_units
    belongs_to :line_item, class_name: "Spree::LineItem", inverse_of: :inventory_units

    has_many :return_items, inverse_of: :inventory_unit, dependent: :destroy
    has_one :original_return_item, class_name: "Spree::ReturnItem", foreign_key: :exchange_inventory_unit_id, dependent: :destroy

    scope :backordered, -> { where state: 'backordered' }
    scope :on_hand, -> { where state: 'on_hand' }
    scope :pre_shipment, -> { where(state: PRE_SHIPMENT_STATES) }
    scope :shipped, -> { where state: 'shipped' }
    scope :post_shipment, -> { where(state: POST_SHIPMENT_STATES) }
    scope :returned, -> { where state: 'returned' }
    scope :canceled, -> { where(state: 'canceled') }
    scope :not_canceled, -> { where.not(state: 'canceled') }
    scope :cancelable, -> { where(state: Spree::InventoryUnit::CANCELABLE_STATES) }
    scope :backordered_per_variant, ->(stock_item) do
      includes(:shipment, :order)
        .where("spree_shipments.state != 'canceled'").references(:shipment)
        .where(variant_id: stock_item.variant_id)
        .where('spree_orders.completed_at is not null')
        .backordered.order("spree_orders.completed_at ASC")
    end
    scope :shippable, -> { on_hand }

    # state machine (see http://github.com/pluginaweek/state_machine/tree/master for details)
    state_machine initial: :on_hand do
      event :fill_backorder do
        transition to: :on_hand, from: :backordered
      end
      after_transition on: :fill_backorder, do: :fulfill_order

      event :ship do
        transition to: :shipped, if: :allow_ship?
      end

      event :return do
        transition to: :returned, from: :shipped
      end

      event :cancel do
        transition to: :canceled, from: CANCELABLE_STATES.map(&:to_sym)
      end
    end

    # @param stock_item [Spree::StockItem] the stock item of the desired
    #   inventory units
    # @return [Array<Spree::InventoryUnit>] an array of backordered inventory
    #   units for the given stock item
    def self.backordered_for_stock_item(stock_item)
      # This was refactored from a simpler query because the previous
      # implementation led to issues once users tried to modify the objects
      # returned. That's due to ActiveRecord `joins(shipment: :stock_location)`
      # only returning readonly objects
      backordered_per_variant(stock_item).select do |unit|
        unit.shipment.stock_location == stock_item.stock_location
      end
    end

    # Updates the given inventory units to not be pending.
    #
    # @param inventory_units [<Spree::InventoryUnit>] the inventory to be
    #   finalized
    def self.finalize_units!(inventory_units)
      inventory_units.map do |iu|
        iu.update_columns(
          pending: false,
          updated_at: Time.now,
        )
      end
    end

    # @return [Spree::StockItem] the first stock item from this shipment's
    #   stock location that is associated with this inventory unit's variant
    def find_stock_item
      Spree::StockItem.where(stock_location_id: shipment.stock_location_id,
        variant_id: variant_id).first
    end

    # @note This returns the variant regardless of whether it was soft
    #   deleted.
    # @return [Spree::Variant] this inventory unit's variant.
    def variant
      Spree::Variant.unscoped { super }
    end

    # @return [Spree::ReturnItem] a valid return item for this inventory unit
    #   if one exists, or a new one if one does not
    def current_or_new_return_item
      Spree::ReturnItem.from_inventory_unit(self)
    end

    # @return [BigDecimal] the portion of the additional tax on the line item
    #   this inventory unit belongs to that is associated with this individual
    #   inventory unit
    def additional_tax_total
      line_item.additional_tax_total * percentage_of_line_item
    end

    # @return [BigDecimal] the portion of the included tax on the line item
    #   this inventory unit belongs to that is associated with this
    #   individual inventory unit
    def included_tax_total
      line_item.included_tax_total * percentage_of_line_item
    end

    # @return [Boolean] true if this inventory unit has any return items
    #   which have requested exchanges
    def exchange_requested?
      return_items.not_expired.any?(&:exchange_requested?)
    end

    private

      def allow_ship?
        self.on_hand?
      end

      def fulfill_order
        self.reload
        order.fulfill!
      end

      def percentage_of_line_item
        1 / BigDecimal.new(line_item.quantity)
      end

      def current_return_item
        return_items.not_cancelled.first
      end
  end
end
