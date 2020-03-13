# frozen_string_literal: true

module Spree
  # Tracks the state of line items' fulfillment.
  #
  class InventoryUnit < Spree::Base
    PRE_SHIPMENT_STATES = %w(backordered on_hand)
    POST_SHIPMENT_STATES = %w(returned)
    CANCELABLE_STATES = ['on_hand', 'backordered', 'shipped']

    belongs_to :variant, -> { with_discarded }, class_name: "Spree::Variant", inverse_of: :inventory_units, optional: true
    belongs_to :shipment, class_name: "Spree::Shipment", touch: true, inverse_of: :inventory_units, optional: true
    belongs_to :carton, class_name: "Spree::Carton", inverse_of: :inventory_units, optional: true
    belongs_to :line_item, class_name: "Spree::LineItem", inverse_of: :inventory_units, optional: true

    has_many :return_items, inverse_of: :inventory_unit, dependent: :destroy
    has_one :original_return_item, class_name: "Spree::ReturnItem", foreign_key: :exchange_inventory_unit_id, dependent: :destroy
    has_one :unit_cancel, class_name: "Spree::UnitCancel"
    has_one :order, through: :shipment

    delegate :order_id, to: :shipment

    def order=(_)
      raise "The order association has been removed from InventoryUnit. The order is now determined from the shipment."
    end

    validates_presence_of :shipment, :line_item, :variant

    before_destroy :ensure_can_destroy

    scope :pending, -> { where pending: true }
    scope :backordered, -> { where state: 'backordered' }
    scope :on_hand, -> { where state: 'on_hand' }
    scope :pre_shipment, -> { where(state: PRE_SHIPMENT_STATES) }
    scope :shipped, -> { where state: 'shipped' }
    scope :post_shipment, -> { where(state: POST_SHIPMENT_STATES) }
    scope :returned, -> { where state: 'returned' }
    scope :canceled, -> { where(state: 'canceled') }
    scope :not_canceled, -> { where.not(state: 'canceled') }
    scope :cancelable, -> { where(state: Spree::InventoryUnit::CANCELABLE_STATES, pending: false) }
    scope :backordered_per_variant, ->(stock_item) do
      includes(:shipment, :order)
        .where("spree_shipments.state != 'canceled'").references(:shipment)
        .where(variant_id: stock_item.variant_id)
        .where('spree_orders.completed_at is not null')
        .backordered.order(Spree::Order.arel_table[:completed_at].asc)
    end

    # @method backordered_for_stock_item(stock_item)
    # @param stock_item [Spree::StockItem] the stock item of the desired
    #   inventory units
    # @return [ActiveRecord::Relation<Spree::InventoryUnit>] backordered
    #   inventory units for the given stock item
    scope :backordered_for_stock_item, ->(stock_item) do
      backordered_per_variant(stock_item)
        .where(spree_shipments: { stock_location_id: stock_item.stock_location_id })
    end

    scope :shippable, -> { on_hand }

    include ::Spree::Config.state_machines.inventory_unit

    # Updates the given inventory units to not be pending.
    #
    # @deprecated do not use this, use
    #   Spree::Stock::InventoryUnitsFinalizer.new(inventory_units).run!
    # @param inventory_units [<Spree::InventoryUnit>] the inventory to be
    #   finalized
    def self.finalize_units!(inventory_units)
      Spree::Deprecation.warn(
        "inventory_units.finalize_units!(inventory_units) is deprecated. Please
        use Spree::Stock::InventoryUnitsFinalizer.new(inventory_units).run!",
        caller
      )

      inventory_units.map do |iu|
        iu.update_columns(
          pending: false,
          updated_at: Time.current
        )
      end
    end

    # @return [Spree::StockItem] the first stock item from this shipment's
    #   stock location that is associated with this inventory unit's variant
    def find_stock_item
      Spree::StockItem.where(stock_location_id: shipment.stock_location_id,
        variant_id: variant_id).first
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

    def allow_ship?
      on_hand?
    end

    private

    def fulfill_order
      reload
      order.fulfill!
    end

    def percentage_of_line_item
      1 / BigDecimal(line_item.quantity)
    end

    def current_return_item
      return_items.not_cancelled.first
    end

    def ensure_can_destroy
      if !backordered? && !on_hand?
        errors.add(:state, :cannot_destroy, state: state)
        throw :abort
      end

      if shipment.shipped? || shipment.canceled?
        errors.add(:base, :cannot_destroy_shipment_state, state: shipment.state)
        throw :abort
      end
    end
  end
end
