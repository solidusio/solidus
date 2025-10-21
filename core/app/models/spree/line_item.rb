# frozen_string_literal: true

module Spree
  # Variants placed in the Order at a particular price.
  #
  # `Spree::LineItem` is an ActiveRecord model which records which `Spree::Variant`
  # a customer has chosen to place in their order. It also acts as the permanent
  # record of the customer's order by recording relevant price, taxation, and inventory
  # concerns. Line items can also have adjustments placed on them as part of the
  # promotion system.
  #
  class LineItem < Spree::Base
    include Metadata

    belongs_to :order, class_name: "Spree::Order", inverse_of: :line_items, touch: true, optional: true
    belongs_to :variant, -> { with_discarded }, class_name: "Spree::Variant", inverse_of: :line_items, optional: true
    belongs_to :tax_category, class_name: "Spree::TaxCategory", optional: true

    has_one :product, through: :variant

    has_many :adjustments, as: :adjustable, inverse_of: :adjustable, dependent: :destroy, autosave: true
    has_many :inventory_units, inverse_of: :line_item

    before_validation :normalize_quantity
    after_initialize :set_required_attributes

    validates :variant, presence: true
    validates :quantity, numericality: {
      only_integer: true,
      greater_than: -1
    }
    validates :price, numericality: true
    validate :price_match_order_currency

    after_save :update_inventory

    before_destroy :update_inventory
    before_destroy :destroy_inventory_units

    delegate :name, :description, :sku, :should_track_inventory?, to: :variant
    delegate :tax_category, :tax_category_id, to: :variant, prefix: true
    delegate :currency, to: :order, allow_nil: true

    attr_accessor :target_shipment, :price_currency

    self.allowed_ransackable_associations = ['variant']
    self.allowed_ransackable_attributes = ['variant_id']

    # @return [BigDecimal] the amount of this line item, which is the line
    #   item's price multiplied by its quantity.
    def amount
      price * quantity
    end
    alias subtotal amount

    # @return [BigDecimal] the amount of this line item, taking into
    #   consideration all its adjustments.
    def total
      amount + adjustment_total
    end

    # @return [BigDecimal] the amount of this item, taking into consideration
    #   all non-tax adjustments.
    def total_before_tax
      amount + adjustments.reject(&:tax?).sum(&:amount)
    end

    # @return [BigDecimal] the amount of this line item before VAT tax
    # @note just like `amount`, this does not include any additional tax
    def total_excluding_vat
      total_before_tax - included_tax_total
    end

    extend Spree::DisplayMoney
    money_methods :amount, :price,
                  :included_tax_total, :additional_tax_total,
                  :total, :total_before_tax, :total_excluding_vat

    # @return [Spree::Money] the price of this line item
    alias money_price display_price
    alias single_display_amount display_price
    alias single_money display_price

    # @return [Spree::Money] the amount of this line item
    alias money display_amount

    # Sets price from a `Spree::Money` object
    #
    # @param [Spree::Money] money - the money object to obtain price from
    def money_price=(money)
      if !money
        self.price = nil
      else
        self.price_currency = money.currency.iso_code
        self.price = money.to_d
      end
    end

    # @return [Boolean] true when it is possible to supply the required
    #   quantity of stock of this line item's variant
    def sufficient_stock?
      Spree::Config.stock.quantifier_class.new(variant).can_supply? quantity
    end

    # @return [Boolean] true when it is not possible to supply the required
    #   quantity of stock of this line item's variant
    def insufficient_stock?
      !sufficient_stock?
    end

    # Sets options on the line item and updates the price.
    #
    # The options can be arbitrary attributes on the LineItem.
    #
    # @param options [Hash] options for this line item
    def options=(options = {})
      return unless options.present?

      assign_attributes options

      # When price is part of the options we are not going to fetch
      # it from the variant. Please note that this always allows to set
      # a price for this line item, even if there is no existing price
      # for the associated line item in the order currency.
      unless options.key?(:price) || options.key?('price')
        self.money_price = variant.price_for_options(pricing_options)&.money
      end
    end

    def pricing_options
      Spree::Config.pricing_options_class.from_line_item(self)
    end

    # @return [Spree::TaxCategory] the variant's tax category
    #
    # This returns the variant's tax category if the tax category ID on the line_item is nil. It looks
    # like an association, but really is an override.
    #
    def tax_category
      super || variant_tax_category
    end

    # @return [Integer] the variant's tax category ID
    #
    # This returns the variant's tax category ID if the tax category ID on the line_id is nil. It looks
    # like an association, but really is an override.
    #
    def tax_category_id
      super || variant_tax_category_id
    end

    private

    # Sets the quantity to zero if it is nil or less than zero.
    def normalize_quantity
      self.quantity = 0 if quantity.nil? || quantity < 0
    end

    # Sets tax category, price-related attributes from
    # its variant if they are nil and a variant is present.
    def set_required_attributes
      return if persisted?
      return unless variant
      self.tax_category ||= variant.tax_category
      set_pricing_attributes
    end

    # Set price, cost_price and currency.
    def set_pricing_attributes
      self.cost_price ||= variant.cost_price
      self.money_price = variant.price_for_options(pricing_options)&.money if price.nil?
      true
    end

    def update_inventory
      if (saved_changes? || target_shipment.present?) && order.has_checkout_step?("delivery")
        Spree::OrderInventory.new(order, self).verify(target_shipment)
      end
    end

    def destroy_inventory_units
      inventory_units.destroy_all
    end

    def price_match_order_currency
      return if price_currency.blank? || price_currency == currency

      errors.add(:price, :does_not_match_order_currency)
    end
  end
end
