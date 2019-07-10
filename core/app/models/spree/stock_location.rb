# frozen_string_literal: true

module Spree
  # Records the name and addresses from which stock items are fulfilled in
  # cartons.
  #
  class StockLocation < Spree::Base
    class InvalidMovementError < StandardError; end

    acts_as_list

    has_many :shipments
    has_many :stock_items, dependent: :delete_all, inverse_of: :stock_location
    has_many :cartons, inverse_of: :stock_location
    has_many :stock_movements, through: :stock_items
    has_many :user_stock_locations, dependent: :delete_all
    has_many :users, through: :user_stock_locations

    belongs_to :state, class_name: 'Spree::State', optional: true
    belongs_to :country, class_name: 'Spree::Country', optional: true

    has_many :shipping_method_stock_locations, dependent: :destroy
    has_many :shipping_methods, through: :shipping_method_stock_locations

    validates_presence_of :name
    validates_uniqueness_of :code, allow_blank: true, case_sensitive: false

    scope :active, -> { where(active: true) }
    scope :order_default, -> { order(default: :desc, name: :asc) }

    after_create :create_stock_items, if: :propagate_all_variants?
    after_save :ensure_one_default

    self.whitelisted_ransackable_attributes = %w[name]

    def state_text
      state.try(:abbr) || state.try(:name) || state_name
    end

    # Wrapper for creating a new stock item respecting the backorderable config
    def propagate_variant(variant)
      stock_items.create!(variant: variant, backorderable: backorderable_default)
    end

    # Return either an existing stock item or create a new one. Useful in
    # scenarios where the user might not know whether there is already a stock
    # item for a given variant
    def set_up_stock_item(variant)
      stock_item(variant) || propagate_variant(variant)
    end

    # Returns an instance of StockItem for the variant id.
    #
    # @param variant_id [String] The id of a variant.
    #
    # @return [StockItem] Corresponding StockItem for the StockLocation's variant.
    def stock_item(variant_id)
      stock_items.where(variant_id: variant_id).order(:id).first
    end

    # Attempts to look up StockItem for the variant, and creates one if not found.
    # This method accepts an id or instance of the variant since it is used in
    # multiple ways. Other methods in this model attempt to pass a variant,
    # but controller actions can pass just the variant id as a parameter.
    #
    # @return [StockItem] Corresponding StockItem for the StockLocation's variant.
    def stock_item_or_create(variant)
      vid = if variant.is_a?(Variant)
        variant.id
      else
        variant
      end
      stock_item(vid) || stock_items.create(variant_id: vid)
    end

    def count_on_hand(variant)
      stock_item(variant).try(:count_on_hand)
    end

    def backorderable?(variant)
      stock_item(variant).try(:backorderable?)
    end

    def restock(variant, quantity, originator = nil)
      move(variant, quantity, originator)
    end

    def restock_backordered(variant, quantity, _originator = nil)
      item = stock_item_or_create(variant)
      item.update_columns(
        count_on_hand: item.count_on_hand + quantity,
        updated_at: Time.current
      )
    end

    def unstock(variant, quantity, originator = nil)
      move(variant, -quantity, originator)
    end

    def move(variant, quantity, originator = nil)
      if quantity < 1 && !stock_item(variant)
        raise InvalidMovementError.new(I18n.t('spree.negative_movement_absent_item'))
      end
      stock_item_or_create(variant).stock_movements.create!(quantity: quantity,
                                                            originator: originator)
    end

    def fill_status(variant, quantity)
      if item = stock_item(variant)
        item.fill_status(quantity)
      else
        [0, 0]
      end
    end

    private

    def create_stock_items
      Spree::Variant.find_each { |variant| propagate_variant(variant) }
    end

    def ensure_one_default
      if default
        Spree::StockLocation.where(default: true).where.not(id: id).each do |stock_location|
          stock_location.default = false
          stock_location.save!
        end
      end
    end
  end
end
