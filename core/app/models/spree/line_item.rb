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
    class CurrencyMismatch < StandardError; end

    belongs_to :order, class_name: "Spree::Order", inverse_of: :line_items, touch: true, optional: true
    belongs_to :variant, -> { with_deleted }, class_name: "Spree::Variant", inverse_of: :line_items, optional: true
    belongs_to :tax_category, class_name: "Spree::TaxCategory", optional: true

    has_one :product, through: :variant

    has_many :adjustments, as: :adjustable, inverse_of: :adjustable, dependent: :destroy
    has_many :inventory_units, inverse_of: :line_item

    has_many :line_item_actions, dependent: :destroy
    has_many :actions, through: :line_item_actions

    before_validation :normalize_quantity
    before_validation :set_required_attributes

    validates :variant, presence: true
    validates :quantity, numericality: {
      only_integer: true,
      greater_than: -1
    }
    validates :price, numericality: true

    after_save :update_inventory

    before_destroy :update_inventory
    before_destroy :destroy_inventory_units

    delegate :name, :description, :sku, :should_track_inventory?, to: :variant
    delegate :currency, to: :order, allow_nil: true

    attr_accessor :target_shipment

    self.whitelisted_ransackable_associations = ['variant']
    self.whitelisted_ransackable_attributes = ['variant_id']

    # @return [BigDecimal] the amount of this line item, which is the line
    #   item's price multiplied by its quantity.
    def amount
      price * quantity
    end
    alias subtotal amount

    # @return [BigDecimal] the amount of this line item, taking into
    #   consideration line item promotions.
    def discounted_amount
      amount + promo_total
    end
    deprecate discounted_amount: :total_before_tax, deprecator: Spree::Deprecation

    # @return [BigDecimal] the amount of this line item, taking into
    #   consideration all its adjustments.
    def total
      amount + adjustment_total
    end
    alias final_amount total
    deprecate final_amount: :total, deprecator: Spree::Deprecation

    # @return [BigDecimal] the amount of this item, taking into consideration
    #   all non-tax adjustments.
    def total_before_tax
      amount + adjustments.select { |value| !value.tax? && value.eligible? }.sum(&:amount)
    end

    # @return [BigDecimal] the amount of this line item before VAT tax
    # @note just like `amount`, this does not include any additional tax
    def total_excluding_vat
      total_before_tax - included_tax_total
    end
    alias pre_tax_amount total_excluding_vat
    deprecate pre_tax_amount: :total_excluding_vat, deprecator: Spree::Deprecation

    extend Spree::DisplayMoney
    money_methods :amount, :discounted_amount, :price,
                  :included_tax_total, :additional_tax_total,
                  :total, :total_before_tax, :total_excluding_vat
    deprecate display_discounted_amount: :display_total_before_tax, deprecator: Spree::Deprecation
    alias display_final_amount display_total
    deprecate display_final_amount: :display_total, deprecator: Spree::Deprecation
    alias display_pre_tax_amount display_total_excluding_vat
    deprecate display_pre_tax_amount: :display_total_excluding_vat, deprecator: Spree::Deprecation
    alias discounted_money display_discounted_amount
    deprecate discounted_money: :display_total_before_tax, deprecator: Spree::Deprecation

    # @return [Spree::Money] the price of this line item
    alias money_price display_price
    alias single_display_amount display_price
    alias single_money display_price

    # @return [Spree::Money] the amount of this line item
    alias money display_amount
    alias display_total display_amount
    deprecate display_total: :display_amount, deprecator: Spree::Deprecation

    # Sets price from a `Spree::Money` object
    #
    # @param [Spree::Money] money - the money object to obtain price from
    def money_price=(money)
      if !money
        self.price = nil
      elsif money.currency.iso_code != currency
        raise CurrencyMismatch, "Line item price currency must match order currency!"
      else
        self.price = money.to_d
      end
    end

    # @return [Boolean] true when it is possible to supply the required
    #   quantity of stock of this line item's variant
    def sufficient_stock?
      Stock::Quantifier.new(variant).can_supply? quantity
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
        self.money_price = variant.price_for(pricing_options)
      end
    end

    def pricing_options
      Spree::Config.pricing_options_class.from_line_item(self)
    end

    def currency=(_currency)
      Spree::Deprecation.warn 'Spree::LineItem#currency= is deprecated ' \
        'and will take no effect.',
        caller
    end

    private

    # Sets the quantity to zero if it is nil or less than zero.
    def normalize_quantity
      self.quantity = 0 if quantity.nil? || quantity < 0
    end

    # Sets tax category, price-related attributes from
    # its variant if they are nil and a variant is present.
    def set_required_attributes
      return unless variant
      self.tax_category ||= variant.tax_category
      set_pricing_attributes
    end

    # Set price, cost_price and currency. This method used to be called #copy_price, but actually
    # did more than just setting the price, hence renamed to #set_pricing_attributes
    def set_pricing_attributes
      # If the legacy method #copy_price has been overridden, handle that gracefully
      return handle_copy_price_override if respond_to?(:copy_price)

      self.cost_price ||= variant.cost_price
      self.money_price = variant.price_for(pricing_options) if price.nil?
      true
    end

    def handle_copy_price_override
      copy_price
      Spree::Deprecation.warn 'You have overridden Spree::LineItem#copy_price. ' \
        'This method is now called Spree::LineItem#set_pricing_attributes. ' \
        'Please adjust your override.',
        caller
    end

    def update_inventory
      if (saved_changes? || target_shipment.present?) && order.has_checkout_step?("delivery")
        Spree::OrderInventory.new(order, self).verify(target_shipment)
      end
    end

    def destroy_inventory_units
      inventory_units.destroy_all
    end
  end
end
