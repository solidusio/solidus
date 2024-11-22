# frozen_string_literal: true

module Spree
  # Products represent an entity for sale in a store. Products can have
  # variations, called variants. Product properties include description,
  # permalink, availability, shipping category, etc. that do not change by
  # variant.
  class Product < Spree::Base
    extend FriendlyId
    friendly_id :slug_candidates, use: :history

    include Spree::SoftDeletable

    after_discard do
      variants_including_master.discard_all
      self.product_option_types = []
      self.product_properties = []
      self.classifications.destroy_all
    end

    has_many :product_option_types, dependent: :destroy, inverse_of: :product
    has_many :option_types, through: :product_option_types

    has_many :product_properties, dependent: :destroy, inverse_of: :product
    has_many :properties, through: :product_properties
    has_many :variant_property_rules
    has_many :variant_property_rule_values, through: :variant_property_rules, source: :values
    has_many :variant_property_rule_conditions, through: :variant_property_rules, source: :conditions

    has_many :classifications, dependent: :delete_all, inverse_of: :product
    has_many :taxons, through: :classifications, before_remove: :remove_taxon

    belongs_to :tax_category, class_name: 'Spree::TaxCategory', optional: true
    belongs_to :shipping_category, class_name: 'Spree::ShippingCategory', inverse_of: :products, optional: true

    has_one :master,
      -> { where(is_master: true).with_discarded },
      inverse_of: :product,
      class_name: 'Spree::Variant',
      autosave: true

    has_many :variants,
      -> { where(is_master: false).order(:position) },
      inverse_of: :product,
      class_name: 'Spree::Variant'

    has_many :variants_including_master,
      -> { order(:position) },
      inverse_of: :product,
      class_name: 'Spree::Variant',
      dependent: :destroy

    has_many :prices, -> { order(Spree::Variant.arel_table[:position].asc, Spree::Variant.arel_table[:id].asc, :currency) }, through: :variants_including_master

    has_many :stock_items, through: :variants_including_master

    has_many :line_items, through: :variants_including_master
    has_many :orders, through: :line_items

    has_many :option_values, -> { distinct }, through: :variants_including_master

    scope :sort_by_master_default_price_amount_asc, -> {
      with_default_price.order('spree_prices.amount ASC')
    }
    scope :sort_by_master_default_price_amount_desc, -> {
      with_default_price.order('spree_prices.amount DESC')
    }
    scope :with_default_price, -> {
      left_joins(master: :prices)
        .where(master: { spree_prices: Spree::Config.default_pricing_options.desired_attributes })
    }

    def find_or_build_master
      master || build_master
    end

    MASTER_ATTRIBUTES = [
      :cost_currency,
      :cost_price,
      :depth,
      :height,
      :price,
      :sku,
      :track_inventory,
      :weight,
      :width,
    ]
    MASTER_ATTRIBUTES.each do |attr|
      delegate :"#{attr}", :"#{attr}=", to: :find_or_build_master
    end

    delegate :amount_in,
             :display_amount,
             :display_price,
             :has_default_price?,
             :images,
             :price_for_options,
             :rebuild_vat_prices=,
             to: :find_or_build_master

    alias_method :master_images, :images

    has_many :variant_images, -> { order(:position) }, source: :images, through: :variants_including_master

    after_create :build_variants_from_option_values_hash, if: :option_values_hash

    after_destroy :punch_slug
    after_discard :punch_slug

    after_initialize :ensure_master

    after_save :run_touch_callbacks, if: :saved_changes?
    after_touch :touch_taxons

    before_validation :normalize_slug, on: :update
    before_validation :validate_master

    validates :meta_keywords, length: { maximum: 255 }
    validates :meta_title, length: { maximum: 255 }
    validates :name, presence: true
    validates :price, presence: true, if: proc { Spree::Config[:require_master_price] }
    validates :shipping_category_id, presence: true
    validates :slug, presence: true, uniqueness: { allow_blank: true, case_sensitive: true }

    attr_accessor :option_values_hash

    accepts_nested_attributes_for :variant_property_rules, allow_destroy: true
    accepts_nested_attributes_for :product_properties, allow_destroy: true, reject_if: lambda { |pp| pp[:property_name].blank? }

    alias :options :product_option_types

    self.allowed_ransackable_associations = %w[stores variants_including_master master variants option_values]
    self.allowed_ransackable_attributes = %w[name slug]
    self.allowed_ransackable_scopes = %i[available with_discarded with_all_variant_sku_cont with_kept_variant_sku_cont]

    # @return [Boolean] true if there are any variants
    def has_variants?
      variants.any?
    end

    # @return [Spree::TaxCategory] tax category for this product, or the default tax category
    def tax_category
      super || Spree::TaxCategory.find_by(is_default: true)
    end

    # Ensures option_types and product_option_types exist for keys in
    # option_values_hash.
    #
    # @return [Array] the option_values
    def ensure_option_types_exist_for_values_hash
      return if option_values_hash.nil?
      required_option_type_ids = option_values_hash.keys.map(&:to_i)
      self.option_type_ids |= required_option_type_ids
    end

    # Creates a new product with the same attributes, variants, etc.
    #
    # @return [Spree::Product] the duplicate
    def duplicate
      duplicator = ProductDuplicator.new(self)
      duplicator.duplicate
    end

    # Use for checking whether this product has been deleted. Provided for
    # overriding the logic for determining if a product is deleted.
    #
    # @return [Boolean] true if this product is deleted
    def deleted?
      !!deleted_at
    end

    # Determines if product is available. A product is available if it has not
    # been deleted, the available_on date is in the past
    # and the discontinue_on date is nil or in the future.
    #
    # @return [Boolean] true if this product is available
    def available?
      !deleted? && available_on&.past? && !discontinued?
    end

    # Determines if product is discontinued.
    #
    # A product is discontinued if the discontinue_on date
    # is not nil and in the past.
    #
    # @return [Boolean] true if this product is discontinued
    def discontinued?
      !!discontinue_on&.past?
    end

    # Poor man's full text search.
    #
    # Filters products to those which have any of the strings in +values+ in
    # any of the fields in +fields+.
    #
    # @param fields [Array{String,Symbol}] columns of the products table to search for values
    # @param values [Array{String}] strings to search through fields for
    # @return [ActiveRecord::Relation] scope with WHERE clause for search applied
    def self.like_any(fields, values)
      conditions = fields.product(values).map do |(field, value)|
        arel_table[field].matches("%#{value}%")
      end
      where conditions.inject(:or)
    end

    # @param pricing_options [Spree::Variant::PricingOptions] the pricing options to search
    #   for, default: the default pricing options
    # @return [Array<Spree::Variant>] all variants with at least one option value
    def variants_and_option_values_for(pricing_options = Spree::Config.default_pricing_options)
      variants.includes(:option_values).with_prices(pricing_options).select do |variant|
        variant.option_values.any?
      end
    end

    # Groups all of the option values that are associated to the product's variants, grouped by
    # option type.
    #
    # @param variant_scope [ActiveRecord_Associations_CollectionProxy] scope to filter the variants
    # used to determine the applied option_types
    # @return [Hash<Spree::OptionType, Array<Spree::OptionValue>>] all option types and option values
    # associated with the products variants grouped by option type
    def variant_option_values_by_option_type(variant_scope = nil)
      option_value_scope = Spree::OptionValuesVariant.joins(:variant)
        .where(spree_variants: { product_id: id })
      option_value_scope = option_value_scope.merge(variant_scope) if variant_scope
      option_value_ids = option_value_scope.distinct.pluck(:option_value_id)
      Spree::OptionValue.where(id: option_value_ids).
        includes(:option_type).
        order("#{Spree::OptionType.table_name}.position, #{Spree::OptionValue.table_name}.position").
        group_by(&:option_type)
    end

    # @return [Boolean] true if there are no option values
    def empty_option_values?
      options.empty? || !option_types.left_joins(:option_values).where('spree_option_values.id IS NULL').empty?
    end

    # @param property_name [String] the name of the property to find
    # @return [String] the value of the given property. nil if property is undefined on this product
    def property(property_name)
      return nil unless prop = properties.find_by(name: property_name)
      product_properties.find_by(property: prop).try(:value)
    end

    # Assigns the given value to the given property.
    #
    # @param property_name [String] the name of the property
    # @param property_value [String] the property value
    def set_property(property_name, property_value)
      ActiveRecord::Base.transaction do
        # Works around spree_i18n https://github.com/spree/spree/issues/301
        property = Spree::Property.create_with(presentation: property_name).find_or_create_by(name: property_name)
        product_property = Spree::ProductProperty.where(product: self, property:).first_or_initialize
        product_property.value = property_value
        product_property.save!
      end
    end

    # @return [Array] all advertised and not-rejected promotions
    def possible_promotions
      Spree::Config.promotions.advertiser_class.for_product(self)
    end

    # The number of on-hand stock items; Infinity if any variant does not track
    # inventory.
    #
    # @return [Fixnum, Infinity]
    def total_on_hand
      if any_variants_not_track_inventory?
        Float::INFINITY
      else
        stock_items.sum(:count_on_hand)
      end
    end

    # Finds the variant property rule that matches the provided option value ids.
    #
    # @param option_value_ids [Array<Integer>] list of option value ids
    # @return [Spree::VariantPropertyRule] the matching variant property rule
    def find_variant_property_rule(option_value_ids)
      variant_property_rules.find do |rule|
        rule.matches_option_value_ids?(option_value_ids)
      end
    end

    # The gallery for the product, which represents all the images
    # associated with it, including those on its variants
    #
    # @return [Spree::Gallery] the media for a variant
    def gallery
      @gallery ||= Spree::Config.product_gallery_class.new(self)
    end

    def brand
      Spree::Config.brand_selector_class.new(self).call
    end

    private

    def any_variants_not_track_inventory?
      if variants_including_master.loaded?
        variants_including_master.any? { |variant| !variant.should_track_inventory? }
      else
        !Spree::Config.track_inventory_levels || variants_including_master.where(track_inventory: false).exists?
      end
    end

    # Builds variants from a hash of option types & values
    def build_variants_from_option_values_hash
      ensure_option_types_exist_for_values_hash
      values = option_values_hash.values
      values = values.inject(values.shift) { |memo, value| memo.product(value).map(&:flatten) }

      values.each do |ids|
        variants.create(
          option_value_ids: ids,
          price: master.price
        )
      end
      save
    end

    def ensure_master
      return unless new_record?
      find_or_build_master
    end

    def normalize_slug
      self.slug = normalize_friendly_id(slug)
    end

    def punch_slug
      # punch slug with date prefix to allow reuse of original
      update_column :slug, "#{Time.current.to_i}_#{slug}" unless frozen?
    end

    # If the master is invalid, the Product object will be assigned its errors
    def validate_master
      unless master.valid?
        master.errors.each do |error|
          errors.add(error.attribute, error.message)
        end
      end
    end

    # Try building a slug based on the following fields in increasing order of specificity.
    def slug_candidates
      [
        :name,
        [:name, :sku]
      ]
    end

    def run_touch_callbacks
      run_callbacks(:touch)
    end

    # Iterate through this product's taxons and taxonomies and touch their timestamps in a batch
    def touch_taxons
      taxons_to_touch = taxons.flat_map(&:self_and_ancestors).uniq
      unless taxons_to_touch.empty?
        Spree::Taxon.where(id: taxons_to_touch.map(&:id)).update_all(updated_at: Time.current)

        taxonomy_ids_to_touch = taxons_to_touch.flat_map(&:taxonomy_id).uniq
        Spree::Taxonomy.where(id: taxonomy_ids_to_touch).update_all(updated_at: Time.current)
      end
    end

    def remove_taxon(taxon)
      removed_classifications = classifications.where(taxon:)
      removed_classifications.each(&:remove_from_list)
    end
  end
end

require_dependency 'spree/product/scopes'
