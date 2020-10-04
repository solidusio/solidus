# frozen_string_literal: true

module Spree
  class StockItem < Spree::Base
    include Spree::SoftDeletable

    belongs_to :stock_location, class_name: 'Spree::StockLocation', inverse_of: :stock_items, optional: true
    belongs_to :variant, -> { with_discarded }, class_name: 'Spree::Variant', inverse_of: :stock_items, optional: true
    has_many :stock_movements, inverse_of: :stock_item

    validates :stock_location, :variant, presence: true
    validates :variant_id, uniqueness: { scope: [:stock_location_id, :deleted_at] }, allow_blank: true, unless: :deleted_at
    validates :count_on_hand, numericality: { greater_than_or_equal_to: 0 }, unless: :backorderable?

    delegate :weight, :should_track_inventory?, to: :variant

    # @return [String] the name of this stock item's variant
    delegate :name, to: :variant, prefix: true

    after_save :conditional_variant_touch, if: :saved_changes?
    after_touch { variant.touch }

    self.whitelisted_ransackable_attributes = ['count_on_hand', 'stock_location_id']

    # @return [Array<Spree::InventoryUnit>] the backordered inventory units
    #   associated with this stock item
    def backordered_inventory_units
      Spree::InventoryUnit.backordered_for_stock_item(self)
    end

    # Adjusts the count on hand by a given value.
    #
    # @note This will cause backorders to be processed.
    # @param value [Fixnum] the amount to change the count on hand by, positive
    #   or negative values are valid
    def adjust_count_on_hand(value)
      with_lock do
        self.count_on_hand = count_on_hand + value
        process_backorders(count_on_hand - count_on_hand_was)

        save!
      end
    end

    # Sets this stock item's count on hand.
    #
    # @note This will cause backorders to be processed.
    # @param value [Fixnum] the desired count on hand
    def set_count_on_hand(value)
      self.count_on_hand = value
      process_backorders(count_on_hand - count_on_hand_was)

      save!
    end

    # @return [Boolean] true if this stock item's count on hand is not zero
    def in_stock?
      count_on_hand > 0
    end

    # @return [Boolean] true if this stock item can be included in a shipment
    def available?
      in_stock? || backorderable?
    end

    # Sets the count on hand to zero if it not already zero.
    #
    # @note This processes backorders if the count on hand is not zero.
    def reduce_count_on_hand_to_zero
      set_count_on_hand(0) if count_on_hand > 0
    end

    def fill_status(quantity)
      if count_on_hand >= quantity
        on_hand = quantity
        backordered = 0
      else
        on_hand = count_on_hand
        on_hand = 0 if on_hand < 0
        backordered = backorderable? ? (quantity - on_hand) : 0
      end

      [on_hand, backordered]
    end

    private

    def count_on_hand=(value)
      write_attribute(:count_on_hand, value)
    end

    # Process backorders based on amount of stock received
    # If stock was -20 and is now -15 (increase of 5 units), then we should process 5 inventory orders.
    # If stock was -20 but then was -25 (decrease of 5 units), do nothing.
    def process_backorders(number)
      if number > 0
        backordered_inventory_units.first(number).each(&:fill_backorder)
      end
    end

    def conditional_variant_touch
      variant.touch if inventory_cache_threshold.nil? || should_touch_variant?
    end

    def should_touch_variant?
      # the variant_id changes from nil when a new stock location is added
      inventory_cache_threshold &&
        (saved_change_to_count_on_hand&.any? { |cache| cache < inventory_cache_threshold }) ||
        saved_change_to_variant_id?
    end

    def inventory_cache_threshold
      # only warn if store is setting binary_inventory_cache (default = false)
      @cache_threshold ||= if Spree::Config.binary_inventory_cache
        Spree::Deprecation.warn "Spree::Config.binary_inventory_cache=true is DEPRECATED. Instead use Spree::Config.inventory_cache_threshold=1"
        1
      else
        Spree::Config.inventory_cache_threshold
      end
    end
  end
end
