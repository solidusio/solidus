module Spree
  class LineItem < Spree::Base
    belongs_to :order, class_name: "Spree::Order", inverse_of: :line_items, touch: true
    belongs_to :variant, -> { with_deleted }, class_name: "Spree::Variant", inverse_of: :line_items
    belongs_to :tax_category, class_name: "Spree::TaxCategory"

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
    validate :ensure_proper_currency

    after_create :update_tax_charge

    after_save :update_inventory

    before_destroy :update_inventory
    before_destroy :destroy_inventory_units

    delegate :name, :description, :sku, :should_track_inventory?, to: :variant
    # @note This will return the product even if it has been deleted.
    # @return [Spree::Product, nil] the product associated with this line
    #   item, if there is one
    delegate :product, to: :variant

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

    # @return [BigDecimal] the amount of this line item, taking into
    #   consideration all its adjustments.
    def final_amount
      amount + adjustment_total
    end
    alias total final_amount

    # @return [BigDecimal] the amount of this line item before included tax
    # @note just like `amount`, this does not include any additional tax
    def pre_tax_amount
      discounted_amount - included_tax_total
    end

    extend Spree::DisplayMoney
    money_methods :amount, :discounted_amount, :final_amount, :pre_tax_amount, :price,
                  :included_tax_total, :additional_tax_total
    alias discounted_money display_discounted_amount

    # @return [Spree::Money] the price of this line item
    alias money_price display_price
    alias single_display_amount display_price
    alias single_money display_price

    # @return [Spree::Money] the amount of this line item
    alias money display_amount
    alias display_total display_amount

    # Sets price and currency from a `Spree::Money` object
    #
    # @param [Spree::Money] money - the money object to obtain price and currency from
    def money_price=(money)
      self.price = money.to_d
      self.currency = money.currency.iso_code
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

      # There's no need to call a pricer if we'll set the price directly.
      unless options.key?(:price) || options.key?('price')
        self.money_price = variant.price_for(pricing_options)
      end
    end

    def pricing_options
      Spree::Config.pricing_options_class.from_line_item(self)
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

      self.currency ||= order.currency
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
      if (changed? || target_shipment.present?) && order.has_checkout_step?("delivery")
        Spree::OrderInventory.new(order, self).verify(target_shipment)
      end
    end

    def destroy_inventory_units
      inventory_units.destroy_all
    end

    def update_tax_charge
      Spree::Tax::ItemAdjuster.new(self).adjust!
    end

    def ensure_proper_currency
      if currency != order.currency
        Spree::Deprecation.warn "The line items currency is different from it's order currency. " \
                                "This behavior is not supported anymore and will be deleted soon.",
                                caller
        errors.add(:currency, :must_match_order_currency)
      end
    end
  end
end
