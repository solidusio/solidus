module Spree
  # == Master Variant
  #
  # Every product has one master variant, which stores master price and SKU,
  # size and weight, etc. The master variant does not have option values
  # associated with it. Contains on_hand inventory levels only when there are
  # no variants for the product.
  #
  # == Variants
  #
  # All variants can access the product properties directly (via reverse
  # delegation). Inventory units are tied to Variant.  The master variant can
  # have inventory units, but not option values. All other variants have
  # option values and may have inventory units. Sum of on_hand each variant's
  # inventory level determine "on_hand" level for the product.
  class Variant < Spree::Base
    acts_as_paranoid

    include Spree::DefaultPrice

    belongs_to :product, touch: true, class_name: 'Spree::Product', inverse_of: :variants
    belongs_to :tax_category, class_name: 'Spree::TaxCategory'

    delegate :name, :description, :slug, :available_on, :shipping_category_id,
             :meta_description, :meta_keywords, :shipping_category,
             to: :product

    has_many :inventory_units, inverse_of: :variant
    has_many :line_items, inverse_of: :variant
    has_many :orders, through: :line_items

    has_many :stock_items, dependent: :destroy, inverse_of: :variant
    has_many :stock_locations, through: :stock_items
    has_many :stock_movements, through: :stock_items

    has_many :option_values_variants, dependent: :destroy
    has_many :option_values, through: :option_values_variants

    has_many :images, -> { order(:position) }, as: :viewable, dependent: :destroy, class_name: "Spree::Image"

    has_many :prices,
      class_name: 'Spree::Price',
      dependent: :destroy,
      inverse_of: :variant

    before_validation :set_cost_currency

    validate :check_price

    validates :cost_price, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
    validates :price,      numericality: { greater_than_or_equal_to: 0, allow_nil: true }
    validates_uniqueness_of :sku, allow_blank: true, conditions: -> { where(deleted_at: nil) }

    after_create :create_stock_items
    after_create :set_position
    after_create :set_master_out_of_stock, unless: :is_master?

    after_touch :clear_in_stock_cache

    # Returns variants that are in stock. When stock locations are provided as
    # a parameter, the scope is limited to variants that are in stock in the
    # provided stock locations.
    #
    # @param stock_locations [Array<Spree::StockLocation>] the stock locations to check
    # @return [ActiveRecord::Relation]
    def self.in_stock(stock_locations = nil)
      in_stock_variants = joins(:stock_items).where(Spree::StockItem.arel_table[:count_on_hand].gt(0).or(arel_table[:track_inventory].eq(false)))
      if stock_locations.present?
        in_stock_variants = in_stock_variants.where(spree_stock_items: { stock_location_id: stock_locations.map(&:id) })
      end
      in_stock_variants
    end

    self.whitelisted_ransackable_associations = %w[option_values product prices default_price]
    self.whitelisted_ransackable_attributes = %w[weight sku]

    # Returns variants that are not deleted and have a price in the given
    # currency.
    #
    # @param currency [String] the currency to filter by; defaults to Spree's default
    # @return [ActiveRecord::Relation]
    def self.active(currency = nil)
      joins(:prices).where(deleted_at: nil).where('spree_prices.currency' => currency || Spree::Config[:currency]).where('spree_prices.amount IS NOT NULL')
    end

    # @return [Spree::TaxCategory] the variant's tax category
    def tax_category
      if self[:tax_category_id].nil?
        product.tax_category
      else
        TaxCategory.find(self[:tax_category_id])
      end
    end

    # Sets the cost_price for the variant.
    #
    # @param price [Any] the price to set
    # @return [Bignum]
    def cost_price=(price)
      self[:cost_price] = Spree::LocalizedNumber.parse(price) if price.present?
    end

    # Sets the weight for the variant.
    #
    # @param weight [Any] the weight to set
    # @return [Bignum]
    def weight=(weight)
      self[:weight] = Spree::LocalizedNumber.parse(weight) if weight.present?
    end

    # Counts the number of units currently on backorder for this variant.
    #
    # @return [Fixnum]
    def on_backorder
      inventory_units.with_state('backordered').size
    end

    # @return [Boolean] true if this variant can be backordered
    def is_backorderable?
      Spree::Stock::Quantifier.new(self).backorderable?
    end

    # Creates a sentence out of the variant's (sorted) option values.
    #
    # @return [String] a sentence-ified string of option values.
    def options_text
      values = self.option_values.includes(:option_type).sort_by do |option_value|
        option_value.option_type.position
      end

      values.to_a.map! do |ov|
        "#{ov.option_type.presentation}: #{ov.presentation}"
      end

      values.to_sentence({ words_connector: ", ", two_words_connector: ", " })
    end

    # Determines the name of an Exchange variant.
    #
    # @return [String] the master variant name, if it is a master; or a comma-separated list of all option values.
    def exchange_name
      is_master? ? name : options_text
    end

    # Generates a verbose name for the variant, appending 'Master' if it is a
    # master variant, otherwise a list of its option values.
    #
    # @return [String] the generated name
    def descriptive_name
      is_master? ? name + ' - Master' : name + ' - ' + options_text
    end

    # Returns whether this variant has been deleted. Provided as a method of
    # overriding the logic for determining if a variant is deleted.
    #
    # @return [Boolean] true if this variant has been deleted
    def deleted?
      !!deleted_at
    end

    # Override ActiveRecord finder to function even if the product has been
    # deleted.
    #
    # @return [Spree::Product]
    def product
      Spree::Product.unscoped { super }
    end

    # Assign given options hash to option values.
    #
    # @param options [Array] array of hashes with a name and value.
    def options=(options = {})
      options.each do |option|
        set_option_value(option[:name], option[:value])
      end
    end

    # Sets an option type and value for the given name and value.
    #
    # @param opt_name [String] the name of the option
    # @param opt_value [String] the value to set to the option
    def set_option_value(opt_name, opt_value)
      # no option values on master
      return if self.is_master

      option_type = Spree::OptionType.where(name: opt_name).first_or_initialize do |o|
        o.presentation = opt_name
        o.save!
      end

      current_value = self.option_values.detect { |o| o.option_type.name == opt_name }

      unless current_value.nil?
        return if current_value.name == opt_value
        self.option_values.delete(current_value)
      else
        # then we have to check to make sure that the product has the option type
        unless self.product.option_types.include? option_type
          self.product.option_types << option_type
        end
      end

      option_value = Spree::OptionValue.where(option_type_id: option_type.id, name: opt_value).first_or_initialize do |o|
        o.presentation = opt_value
        o.save!
      end

      self.option_values << option_value
      self.save
    end

    # Fetches the option value for the given option name.
    #
    # @param opt_name [String] the name of the option whose value you want
    # @return [String] the option value
    def option_value(opt_name)
      self.option_values.detect { |o| o.option_type.name == opt_name }.try(:presentation)
    end

    # Converts the variant's price to the given currency.
    #
    # @param currency [String] the desired currency
    # @return [Spree::Price] the price in the desired currency
    def price_in(currency)
      prices.detect{ |price| price.currency == currency && price.is_default } || Spree::Price.new(variant_id: self.id, currency: currency)
    end

    # Fetches the price amount in the specified currency.
    #
    # @param currency (see #price)
    # @return [Float] the amount in the specified currency.
    def amount_in(currency)
      price_in(currency).try(:amount)
    end

    # Calculates the sum of the specified price modifiers in the specified
    # currency.
    #
    # @param currency [String] (see #price)
    # @param options (see #price_modifier_amount)
    # @return (see #price_modifier_amount)
    def price_modifier_amount_in(currency, options = {})
      return 0 unless options.present?

      options.keys.map { |key|
        m = "#{key}_price_modifier_amount_in".to_sym
        if self.respond_to? m
          self.send(m, currency, options[key])
        else
          0
        end
      }.sum
    end

    # Calculates the sum of the specified price modifiers.
    #
    # @param options [Hash] for specifying keys, eg: `{keys: ['key_1', 'key_2']}`
    # @return [Fixnum] the sum
    def price_modifier_amount(options = {})
      return 0 unless options.present?

      options.keys.map { |key|
        m = "#{options[key]}_price_modifier_amount".to_sym
        if self.respond_to? m
          self.send(m, options[key])
        else
          0
        end
      }.sum
    end

    # Generates a friendly name and sku string.
    #
    # @return [String]
    def name_and_sku
      "#{name} - #{sku}"
    end

    # Generates a string of the SKU and a list of all the option values.
    #
    # @return [String]
    def sku_and_options_text
      "#{sku} #{options_text}".strip
    end

    # @return [Boolean] true if there is stock on-hand for the variant.
    def in_stock?
      Rails.cache.fetch(in_stock_cache_key) do
        total_on_hand > 0
      end
    end

    # @param quantity [Fixnum] how many are desired
    # @return [Boolean] true if the desired quantity can be supplied
    def can_supply?(quantity=1)
      Spree::Stock::Quantifier.new(self).can_supply?(quantity)
    end

    # Fetches the on-hand quantity of the variant.
    #
    # @return [Fixnum] the number currently on-hand
    def total_on_hand
      Spree::Stock::Quantifier.new(self).total_on_hand
    end

    # Shortcut method to determine if inventory tracking is enabled for this
    # variant. This considers both variant tracking flag and site-wide inventory
    # tracking settings.
    #
    # @return [Boolean] true if inventory tracking is enabled
    def should_track_inventory?
      self.track_inventory? && Spree::Config.track_inventory_levels
    end

    # Image that can be used for the variant.
    #
    # Will first search for images on the variant. If it doesn't find any,
    # it'll fallback to any variant image (unless +fallback+ is +false+) or to
    # a new {Spree::Image}.
    # @param fallback [Boolean] whether or not we should fallback to an image
    #   not from this variant
    # @return [Spree::Image] the image to display
    def display_image(fallback: true)
      images.first || (fallback && product.variant_images.first) || Spree::Image.new
    end

    # Determines the variant's property values by verifying which of the product's
    # variant property rules apply to itself.
    #
    # @return [Array<Spree::VariantPropertyRuleValue>] variant_properties
    def variant_properties
      self.product.variant_property_rules.map do |rule|
        rule.values if rule.applies_to_variant?(self)
      end.flatten.compact
    end

    private

      def set_master_out_of_stock
        if product.master && product.master.in_stock?
          product.master.stock_items.update_all(:backorderable => false)
          product.master.stock_items.each { |item| item.reduce_count_on_hand_to_zero }
        end
      end

      # Ensures a new variant takes the product master price when price is not supplied
      def check_price
        if price.nil? && Spree::Config[:require_master_price]
          raise 'No master variant found to infer price' unless (product && product.master)
          raise 'Must supply price for variant or master.price for product.' if self == product.master
          self.price = product.master.price
        end
        if currency.nil?
          self.currency = Spree::Config[:currency]
        end
      end

      def set_cost_currency
        self.cost_currency = Spree::Config[:currency] if cost_currency.blank?
      end

      def create_stock_items
        StockLocation.where(propagate_all_variants: true).each do |stock_location|
          stock_location.propagate_variant(self)
        end
      end

      def set_position
        self.update_column(:position, product.variants.maximum(:position).to_i + 1)
      end

      def in_stock_cache_key
        "variant-#{id}-in_stock"
      end

      def clear_in_stock_cache
        Rails.cache.delete(in_stock_cache_key)
      end
  end
end

require_dependency 'spree/variant/scopes'
