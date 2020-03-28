# frozen_string_literal: true

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
    acts_as_list scope: :product

    include Spree::SoftDeletable

    after_discard do
      stock_items.discard_all
      images.destroy_all
      prices.discard_all
      currently_valid_prices.discard_all
    end

    attr_writer :rebuild_vat_prices
    include Spree::DefaultPrice

    belongs_to :product, -> { with_discarded }, touch: true, class_name: 'Spree::Product', inverse_of: :variants, optional: false
    belongs_to :tax_category, class_name: 'Spree::TaxCategory', optional: true

    delegate :name, :description, :slug, :available_on, :shipping_category_id,
             :meta_description, :meta_keywords, :shipping_category,
             to: :product
    delegate :tax_category, to: :product, prefix: true
    delegate :tax_rates, to: :tax_category

    has_many :inventory_units, inverse_of: :variant
    has_many :line_items, inverse_of: :variant
    has_many :orders, through: :line_items

    has_many :stock_items, dependent: :destroy, inverse_of: :variant
    has_many :stock_locations, through: :stock_items
    has_many :stock_movements, through: :stock_items

    has_many :option_values_variants
    has_many :option_values, through: :option_values_variants

    has_many :images, -> { order(:position) }, as: :viewable, dependent: :destroy, class_name: "Spree::Image"

    has_many :prices,
      class_name: 'Spree::Price',
      dependent: :destroy,
      inverse_of: :variant,
      autosave: true

    has_many :currently_valid_prices,
      -> { currently_valid },
      class_name: 'Spree::Price',
      dependent: :destroy,
      inverse_of: :variant,
      autosave: true

    before_validation :set_cost_currency
    before_validation :set_price, if: -> { product && product.master }
    before_validation :build_vat_prices, if: -> { rebuild_vat_prices? || new_record? && product }

    validates :product, presence: true
    validate :check_price

    validates :cost_price, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
    validates :price,      numericality: { greater_than_or_equal_to: 0, allow_nil: true }
    validates_uniqueness_of :sku, allow_blank: true, case_sensitive: true, if: :enforce_unique_sku?

    after_create :create_stock_items
    after_create :set_position
    after_create :set_master_out_of_stock, unless: :is_master?

    after_save :clear_in_stock_cache
    after_touch :clear_in_stock_cache

    after_real_destroy :destroy_option_values_variants

    # Returns variants that are in stock. When stock locations are provided as
    # a parameter, the scope is limited to variants that are in stock in the
    # provided stock locations.
    #
    # If you want to also include backorderable variants see {Spree::Variant.suppliable}
    #
    # @param stock_locations [Array<Spree::StockLocation>] the stock locations to check
    # @return [ActiveRecord::Relation]
    def self.in_stock(stock_locations = nil)
      return all unless Spree::Config.track_inventory_levels
      in_stock_variants = joins(:stock_items).where(Spree::StockItem.arel_table[:count_on_hand].gt(0).or(arel_table[:track_inventory].eq(false)))
      if stock_locations.present?
        in_stock_variants = in_stock_variants.where(spree_stock_items: { stock_location_id: stock_locations.map(&:id) })
      end
      in_stock_variants
    end

    # Returns a scope of Variants which are suppliable. This includes:
    # * in_stock variants
    # * backorderable variants
    # * variants which do not track stock
    #
    # @return [ActiveRecord::Relation]
    def self.suppliable
      return all unless Spree::Config.track_inventory_levels
      arel_conditions = [
        arel_table[:track_inventory].eq(false),
        Spree::StockItem.arel_table[:count_on_hand].gt(0),
        Spree::StockItem.arel_table[:backorderable].eq(true)
      ]
      joins(:stock_items).where(arel_conditions.inject(:or)).distinct
    end

    self.whitelisted_ransackable_associations = %w[option_values product prices default_price]
    self.whitelisted_ransackable_attributes = %w[weight sku]

    # Returns variants that are not deleted and have a price in the given
    # currency.
    #
    # @deprecated Please use the .with_prices scope instead
    # @param currency [String] the currency to filter by; defaults to Spree's default
    # @return [ActiveRecord::Relation]
    def self.active(currency = nil)
      Spree::Deprecation.warn("`Variant.active(currency)` is deprecated. Please use `Variant.with_prices(pricing_options)` instead.", caller)
      joins(:prices).where(deleted_at: nil).where('spree_prices.currency' => currency || Spree::Config[:currency]).where('spree_prices.amount IS NOT NULL')
    end

    # Returns variants that have a price for the given pricing options
    # If you have modified the pricing options class, you might want to modify this scope too.
    #
    # @param pricing_options A Pricing Options object as defined on the price selector class
    # @return [ActiveRecord::Relation]
    def self.with_prices(pricing_options = Spree::Config.default_pricing_options)
      where(
        Spree::Price.
          where(Spree::Variant.arel_table[:id].eq(Spree::Price.arel_table[:variant_id])).
          # This next clause should just be `where(pricing_options.search_arguments)`, but ActiveRecord
          # generates invalid SQL, so the SQL here is written manually.
          where(
            "spree_prices.currency = ? AND (spree_prices.country_iso IS NULL OR spree_prices.country_iso = ?)",
            pricing_options.search_arguments[:currency],
            pricing_options.search_arguments[:country_iso].compact
          ).
          arel.exists
      )
    end

    # @return [Spree::TaxCategory] the variant's tax category
    #
    # This returns the product's tax category if the tax category ID on the variant is nil. It looks
    # like an association, but really is an override.
    #
    def tax_category
      super || product_tax_category
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
      values = option_values.includes(:option_type).sort_by do |option_value|
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
      return if is_master

      option_type = Spree::OptionType.where(name: opt_name).first_or_initialize do |option|
        option.presentation = opt_name
        option.save!
      end

      current_value = option_values.detect { |option| option.option_type.name == opt_name }

      if current_value
        return if current_value.name == opt_value
        option_values.delete(current_value)
      else
        # then we have to check to make sure that the product has the option type
        unless product.option_types.include? option_type
          product.option_types << option_type
        end
      end

      option_value = Spree::OptionValue.where(option_type_id: option_type.id, name: opt_value).first_or_initialize do |option|
        option.presentation = opt_value
        option.save!
      end

      option_values << option_value
      save
    end

    # Fetches the option value for the given option name.
    #
    # @param opt_name [String] the name of the option whose value you want
    # @return [String] the option value
    def option_value(opt_name)
      option_values.detect { |option| option.option_type.name == opt_name }.try(:presentation)
    end

    # Returns an instance of the globally configured variant price selector class for this variant.
    # It's cached so we don't create too many objects.
    #
    # @return [Spree::Variant::PriceSelector] The default price selector class
    def price_selector
      @price_selector ||= Spree::Config.variant_price_selector_class.new(self)
    end

    # Chooses an appropriate price for the given pricing options
    #
    # @see Spree::Variant::PriceSelector#price_for
    delegate :price_for, to: :price_selector

    # Returns the difference in price from the master variant
    def price_difference_from_master(pricing_options = Spree::Config.default_pricing_options)
      master_price = product.master.price_for(pricing_options)
      variant_price = price_for(pricing_options)
      return unless master_price && variant_price
      variant_price - master_price
    end

    def price_same_as_master?(pricing_options = Spree::Config.default_pricing_options)
      diff = price_difference_from_master(pricing_options)
      diff && diff.zero?
    end

    # Converts the variant's price to the given currency.
    #
    # @deprecated Please use #price_for(pricing_options) instead
    # @param currency [String] the desired currency
    # @return [Spree::Price] the price in the desired currency
    def price_in(currency)
      prices.currently_valid.find_by(currency: currency)
    end
    deprecate price_in: :price_for, deprecator: Spree::Deprecation

    # Fetches the price amount in the specified currency.
    #
    # @deprecated Please use #price_for instead and use a money object rathern than a BigDecimal.
    # @param currency (see #price)
    # @return [Float] the amount in the specified currency.
    def amount_in(currency)
      price_in(currency).try(:amount)
    end
    deprecate amount_in: :price_for, deprecator: Spree::Deprecation

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
    def can_supply?(quantity = 1)
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
      track_inventory? && Spree::Config.track_inventory_levels
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
      Spree::Deprecation.warn('Spree::Variant#display_image is DEPRECATED. Choose an image from Spree::Variant#gallery instead')
      images.first || (fallback && product.variant_images.first) || Spree::Image.new
    end

    # Determines the variant's property values by verifying which of the product's
    # variant property rules apply to itself.
    #
    # @return [Array<Spree::VariantPropertyRuleValue>] variant_properties
    def variant_properties
      product.variant_property_rules.flat_map do |rule|
        rule.values if rule.applies_to_variant?(self)
      end.compact
    end

    # The gallery for the variant, which represents all the images
    # associated with it
    #
    # @return [Spree::Gallery] the media for a variant
    def gallery
      @gallery ||= Spree::Config.variant_gallery_class.new(self)
    end

    private

    def rebuild_vat_prices?
      @rebuild_vat_prices != "0" && @rebuild_vat_prices
    end

    def set_master_out_of_stock
      if product.master && product.master.in_stock?
        product.master.stock_items.update_all(backorderable: false)
        product.master.stock_items.each(&:reduce_count_on_hand_to_zero)
      end
    end

    # Ensures a new variant takes the product master price when price is not supplied
    def set_price
      self.price = product.master.price if price.nil? && Spree::Config[:require_master_price] && !is_master?
    end

    def check_price
      if price.nil? && Spree::Config[:require_master_price] && is_master?
        errors.add :price, 'Must supply price for variant or master.price for product.'
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

    def build_vat_prices
      Spree::Config.variant_vat_prices_generator_class.new(self).run
    end

    def set_position
      update_column(:position, product.variants.maximum(:position).to_i + 1)
    end

    def in_stock_cache_key
      "variant-#{id}-in_stock"
    end

    def clear_in_stock_cache
      Rails.cache.delete(in_stock_cache_key)
    end

    def destroy_option_values_variants
      option_values_variants.destroy_all
    end

    def enforce_unique_sku?
      !deleted_at
    end
  end
end

require_dependency 'spree/variant/scopes'
