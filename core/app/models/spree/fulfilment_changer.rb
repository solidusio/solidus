# frozen_string_literal: true

module Spree
  # Service class to change fulfilment of inventory units of a particular variant
  # to another shipment. The other shipment would typically have a different
  # shipping method, stock location or delivery date, such that we actually change
  # the planned fulfilment for the items in question.
  #
  # Can be used to merge shipments by moving all items to another shipment, because
  # this class will delete any empty original shipment.
  #
  # @attr [Spree::Shipment] current_shipment The shipment we transfer units from
  # @attr [Spree::Shipment] desired_shipment The shipment we want to move units onto
  # @attr [Spree::StockLocation] current_stock_location The stock location of the current shipment
  # @attr [Spree::StockLocation] desired_stock_location The stock location of the desired shipment
  # @attr [Spree::Variant] variant We only move units that represent this variant
  # @attr [Integer] quantity How many units we want to move
  #
  class FulfilmentChanger
    include ActiveModel::Validations

    attr_accessor :current_shipment, :desired_shipment
    attr_reader :variant, :quantity, :current_stock_location, :desired_stock_location, :track_inventory

    def initialize(current_shipment:, desired_shipment:, variant:, quantity:, track_inventory:)
      @current_shipment = current_shipment
      @desired_shipment = desired_shipment
      @current_stock_location = current_shipment.stock_location
      @desired_stock_location = desired_shipment.stock_location
      @variant = variant
      @quantity = quantity
      @track_inventory = track_inventory
    end

    validates :quantity, numericality: {greater_than: 0}
    validate :current_shipment_not_already_shipped
    validate :desired_shipment_different_from_current
    validates :desired_stock_location, presence: true
    validate :enough_stock_at_desired_location, if: :handle_stock_counts?

    # Performs the change of fulfilment
    # @return [true, false] Whether the requested fulfilment change was successful
    def run!
      # Validations here are intended to catch all necessary prerequisites.
      # We return early so all checks have happened already.
      return false if invalid?

      desired_shipment.save! if desired_shipment.new_record?

      if track_inventory
        run_tracking_inventory
      else
        run_without_tracking_inventory
      end

      # We modified the inventory units at the database level for speed reasons.
      # The downside of that is that we need to reload the associations.
      current_shipment.inventory_units.reload
      desired_shipment.inventory_units.reload

      # If the current shipment now has no inventory units left, we won't need it any longer.
      if current_shipment.inventory_units.length.zero?
        current_shipment.destroy!
      else
        # The current shipment has changed, so we need to make sure that shipping rates
        # have the correct amount.
        current_shipment.refresh_rates
      end

      # The desired shipment has also change, so we need to make sure shipping rates
      # are up-to-date, too.
      desired_shipment.refresh_rates

      # In order to reflect the changes in the order totals
      desired_shipment.order.reload
      desired_shipment.order.recalculate

      true
    end

    private

    # When moving things from one stock location to another, we need to restock items
    # from the current location and unstock them at the desired location.
    # Also, when we want to track inventory changes, we need to make sure that we have
    # enough stock at the desired location to fulfil the order. Based on how many items
    # we can take from the desired location, we could end up with some items being backordered.
    def run_tracking_inventory
      # Retrieve how many on hand items we can take from desired stock location
      available_quantity = get_available_quantity
      new_on_hand_quantity = [available_quantity, quantity].min
      backordered_quantity = get_backordered_quantity(available_quantity, new_on_hand_quantity)

      # Determine how many backordered and on_hand items we'll need to move. We
      # don't want to move more than what's being asked. And we can't move a
      # negative amount, which is why we need to perform our min/max logic here.
      backordered_quantity_to_move = [backordered_quantity, quantity].min
      on_hand_quantity_to_move = [quantity - backordered_quantity_to_move, 0].max

      ActiveRecord::Base.transaction do
        if handle_stock_counts?
          # We only run this query if we need it.
          current_on_hand_quantity = [current_shipment.inventory_units.pre_shipment.size, quantity].min
          unstock_quantity = desired_shipment.stock_location.backorderable?(variant) ? quantity : new_on_hand_quantity

          # Restock things we will not fulfil from the current shipment anymore
          current_stock_location.restock(variant, current_on_hand_quantity, current_shipment)
          # Unstock what we will fulfil with the new shipment
          desired_stock_location.unstock(variant, unstock_quantity, desired_shipment)
        end

        # These two statements are the heart of this class. We change the number
        # of inventory units requested from one shipment to the other.
        # We order by state, because `'backordered' < 'on_hand'`.
        # We start to move the new actual backordered quantity, so the remaining
        # quantity can be set to on_hand state.
        current_shipment
          .inventory_units
          .where(variant:)
          .order(state: :asc)
          .limit(backordered_quantity_to_move)
          .update_all(shipment_id: desired_shipment.id, state: :backordered)

        current_shipment
          .inventory_units
          .where(variant:)
          .order(state: :asc)
          .limit(on_hand_quantity_to_move)
          .update_all(shipment_id: desired_shipment.id, state: :on_hand)
      end
    end

    # When we don't track inventory, we can just move the inventory units from one shipment
    # to the other.
    def run_without_tracking_inventory
      ActiveRecord::Base.transaction do
        current_shipment
          .inventory_units
          .where(variant:)
          .order(state: :asc)
          .limit(quantity)
          .update_all(shipment_id: desired_shipment.id)
      end
    end

    # We don't need to handle stock counts for incomplete orders. Also, if
    # the new shipment and the desired shipment will ship from the same stock location,
    # unstocking and restocking will not be necessary.
    def handle_stock_counts?
      current_shipment.order.completed? && current_stock_location != desired_stock_location
    end

    def get_available_quantity
      if current_stock_location != desired_stock_location
        desired_location_quantifier.positive_stock
      else
        sl_availability = current_location_quantifier.positive_stock
        shipment_availability = current_shipment.inventory_units.where(variant: variant).on_hand.count
        sl_availability + shipment_availability
      end
    end

    def get_backordered_quantity(available_quantity, new_on_hand_quantity)
      if current_stock_location != desired_stock_location
        quantity - new_on_hand_quantity
      else
        shipment_quantity = current_shipment.inventory_units.where(variant: variant).size
        shipment_quantity - available_quantity
      end
    end

    def current_shipment_not_already_shipped
      if current_shipment.shipped?
        errors.add(:current_shipment, :has_already_been_shipped)
      end
    end

    def enough_stock_at_desired_location
      unless desired_location_quantifier.can_supply?(quantity)
        errors.add(:desired_shipment, :not_enough_stock_at_desired_location)
      end
    end

    def desired_location_quantifier
      @desired_location_quantifier ||= Spree::Stock::Quantifier.new(variant, desired_stock_location)
    end

    def current_location_quantifier
      @current_location_quantifier ||= Spree::Stock::Quantifier.new(variant, current_stock_location)
    end

    def desired_shipment_different_from_current
      if desired_shipment.id == current_shipment.id
        errors.add(:desired_shipment, :can_not_transfer_within_same_shipment)
      end
    end
  end
end
