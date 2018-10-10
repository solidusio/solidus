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
    attr_reader :variant, :quantity, :current_stock_location, :desired_stock_location

    def initialize(current_shipment:, desired_shipment:, variant:, quantity:)
      @current_shipment = current_shipment
      @desired_shipment = desired_shipment
      @current_stock_location = current_shipment.stock_location
      @desired_stock_location = desired_shipment.stock_location
      @variant = variant
      @quantity = quantity
    end

    validates :quantity, numericality: { greater_than: 0 }
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

      # Retrieve how many on hand items we can take from desired stock location
      available_quantity = [desired_shipment.stock_location.count_on_hand(variant), default_on_hand_quantity].max

      new_on_hand_quantity = [available_quantity, quantity].min
      unstock_quantity = desired_shipment.stock_location.backorderable?(variant) ? quantity : new_on_hand_quantity

      ActiveRecord::Base.transaction do
        if handle_stock_counts?
          # We only run this query if we need it.
          current_on_hand_quantity = [current_shipment.inventory_units.pre_shipment.size, quantity].min

          # Restock things we will not fulfil from the current shipment anymore
          current_stock_location.restock(variant, current_on_hand_quantity, current_shipment)
          # Unstock what we will fulfil with the new shipment
          desired_stock_location.unstock(variant, unstock_quantity, desired_shipment)
        end

        # These two statements are the heart of this class. We change the number
        # of inventory units requested from one shipment to the other.
        # We order by state, because `'backordered' < 'on_hand'`.
        current_shipment.
          inventory_units.
          where(variant: variant).
          order(state: :asc).
          limit(new_on_hand_quantity).
          update_all(shipment_id: desired_shipment.id, state: :on_hand)

        current_shipment.
          inventory_units.
          where(variant: variant).
          order(state: :asc).
          limit(quantity - new_on_hand_quantity).
          update_all(shipment_id: desired_shipment.id, state: :backordered)
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

    # We don't need to handle stock counts for incomplete orders. Also, if
    # the new shipment and the desired shipment will ship from the same stock location,
    # unstocking and restocking will not be necessary.
    def handle_stock_counts?
      current_shipment.order.completed? && current_stock_location != desired_stock_location
    end

    def default_on_hand_quantity
      if current_stock_location != desired_stock_location
        0
      else
        current_shipment.inventory_units.where(variant: variant).on_hand.count
      end
    end

    def current_shipment_not_already_shipped
      if current_shipment.shipped?
        errors.add(:current_shipment, :has_already_been_shipped)
      end
    end

    def enough_stock_at_desired_location
      unless Spree::Stock::Quantifier.new(variant, desired_stock_location).can_supply?(quantity)
        errors.add(:desired_shipment, :not_enough_stock_at_desired_location)
      end
    end

    def desired_shipment_different_from_current
      if desired_shipment.id == current_shipment.id
        errors.add(:desired_shipment, :can_not_transfer_within_same_shipment)
      end
    end
  end
end
