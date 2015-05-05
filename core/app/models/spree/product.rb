module Spree
  # Products represent an entity for sale in a store. Products can have
  # variations, called variants. Product properties include description,
  # permalink, availability, shipping category, etc. that do not change by
  # variant.
  class Product < Spree::Base
    extend FriendlyId
    friendly_id :slug_candidates, use: :history

    acts_as_paranoid

    has_many :product_option_types, dependent: :destroy, inverse_of: :product
    has_many :option_types, through: :product_option_types
    has_many :product_properties, dependent: :destroy, inverse_of: :product
    has_many :properties, through: :product_properties

    has_many :classifications, dependent: :delete_all, inverse_of: :product
    has_many :taxons, through: :classifications
    has_and_belongs_to_many :promotion_rules, join_table: :spree_products_promotion_rules

    belongs_to :tax_category, class_name: 'Spree::TaxCategory'
    belongs_to :shipping_category, class_name: 'Spree::ShippingCategory', inverse_of: :products

    has_one :master,
      -> { where is_master: true },
      inverse_of: :product,
      class_name: 'Spree::Variant'

    has_many :variants,
      -> { where(is_master: false).order("#{::Spree::Variant.quoted_table_name}.position ASC") },
      inverse_of: :product,
      class_name: 'Spree::Variant'

    has_many :variants_including_master,
      -> { order("#{::Spree::Variant.quoted_table_name}.position ASC") },
      inverse_of: :product,
      class_name: 'Spree::Variant',
      dependent: :destroy

    has_many :prices, -> { order('spree_variants.position, spree_variants.id, currency') }, through: :variants

    has_many :stock_items, through: :variants_including_master

    has_many :line_items, through: :variants_including_master
    has_many :orders, through: :line_items

    delegate_belongs_to :master, :sku, :price, :currency, :display_amount, :display_price, :weight, :height, :width, :depth, :is_master, :has_default_price?, :cost_currency, :price_in, :amount_in

    delegate_belongs_to :master, :cost_price

    delegate :images, to: :master, prefix: true
    alias_method :images, :master_images

    has_many :variant_images, -> { order(:position) }, source: :images, through: :variants_including_master

    after_create :set_master_variant_defaults
    after_create :add_associations_from_prototype
    after_create :build_variants_from_option_values_hash, if: :option_values_hash

    after_destroy :punch_slug

    after_initialize :ensure_master

    after_save :save_master
    after_save :run_touch_callbacks, if: :anything_changed?
    after_save :reset_nested_changes
    after_touch :touch_taxons

    before_validation :normalize_slug, on: :update
    before_validation :validate_master

    validates :meta_keywords, length: { maximum: 255 }
    validates :meta_title, length: { maximum: 255 }
    validates :name, presence: true
    validates :price, presence: true, if: proc { Spree::Config[:require_master_price] }
    validates :shipping_category_id, presence: true
    validates :slug, length: { minimum: 3 }, uniqueness: { allow_blank: true }

    attr_accessor :option_values_hash

    accepts_nested_attributes_for :product_properties, allow_destroy: true, reject_if: lambda { |pp| pp[:property_name].blank? }

    alias :options :product_option_types

    # @return [Boolean] true if there are any variants
    def has_variants?
      variants.any?
    end

    # @return [Spree::TaxCategory] tax category for this product, or the default tax category
    def tax_category
      if self[:tax_category_id].nil?
        TaxCategory.where(is_default: true).first
      else
        TaxCategory.find(self[:tax_category_id])
      end
    end

    # Overrides the prototype_id setter in order to ensure it is cast to an
    # integer.
    #
    # @param value [#to_i] the intended new value
    # @!attribute [rw] prototype_id
    #   @return [Fixnum]
    attr_reader :prototype_id
    def prototype_id=(value)
      @prototype_id = value.to_i
    end

    # Ensures option_types and product_option_types exist for keys in
    # option_values_hash.
    #
    # @return [Array] the option_values
    def ensure_option_types_exist_for_values_hash
      return if option_values_hash.nil?
      option_values_hash.keys.map(&:to_i).each do |id|
        self.option_type_ids << id unless option_type_ids.include?(id)
        product_option_types.create(option_type_id: id) unless product_option_types.pluck(:option_type_id).include?(id)
      end
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

    # Determines if product is available. A product is not available if they are
    # deleted or have a nil or future available_on date.
    #
    # @return [Boolean] true if this product is available
    def available?
      !(available_on.nil? || available_on.future?) && !deleted?
    end

    # Groups variants by the specified option type.
    #
    # @param opt_type [String] the name of the option type to group by
    # @return [Hash] option_type as keys, array of variants as values.
    def categorise_variants_from_option(opt_type)
      return {} unless option_types.include?(opt_type)
      variants.active.group_by { |v| v.option_values.detect { |o| o.option_type == opt_type} }
    end

    def self.like_any(fields, values)
      where fields.map { |field|
        values.map { |value|
          arel_table[field].matches("%#{value}%")
        }.inject(:or)
      }.inject(:or)
    end

    # @param current_currency [String] currency to filter variants by; defaults to Spree's default
    # @return [Array<Spree::Variant>] all variants with at least one option value
    def variants_and_option_values(current_currency = nil)
      variants.includes(:option_values).active(current_currency).select do |variant|
        variant.option_values.any?
      end
    end

    # @return [Boolean] true if there are no option values
    def empty_option_values?
      options.empty? || options.any? do |opt|
        opt.option_type.option_values.empty?
      end
    end

    # Gets the value of the given property. Returns nil if the property does
    # not exist.
    #
    # @param property_name [String] the name of the property to find
    # @return [String]
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
        # Works around spree_i18n #301
        property = if Property.exists?(name: property_name)
          Property.where(name: property_name).first
        else
          Property.create(name: property_name, presentation: property_name)
        end
        product_property = ProductProperty.where(product: self, property: property).first_or_initialize
        product_property.value = property_value
        product_property.save!
      end
    end

    # @return [Array] all advertised and not-rejected promotions
    def possible_promotions
      promotion_ids = promotion_rules.map(&:promotion_id).uniq
      Spree::Promotion.advertised.where(id: promotion_ids).reject(&:expired?)
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

    # Override so if the master variant is deleted, we can still find it.
    #
    # @return [Spree::Variant] the master variant
    def master
      super || variants_including_master.with_deleted.where(is_master: true).first
    end

    private

    def add_associations_from_prototype
      if prototype_id && prototype = Spree::Prototype.find_by(id: prototype_id)
        prototype.properties.each do |property|
          product_properties.create(property: property)
        end
        self.option_types = prototype.option_types
        self.taxons = prototype.taxons
      end
    end

    def any_variants_not_track_inventory?
      if variants_including_master.loaded?
        variants_including_master.any? { |v| !v.should_track_inventory? }
      else
        !Spree::Config.track_inventory_levels || variants_including_master.where(track_inventory: false).any?
      end
    end

    # Builds variants from a hash of option types & values
    def build_variants_from_option_values_hash
      ensure_option_types_exist_for_values_hash
      values = option_values_hash.values
      values = values.inject(values.shift) { |memo, value| memo.product(value).map(&:flatten) }

      values.each do |ids|
        variant = variants.create(
          option_value_ids: ids,
          price: master.price
        )
      end
      save
    end

    def ensure_master
      return unless new_record?
      self.master ||= build_master
    end

    def normalize_slug
      self.slug = normalize_friendly_id(slug)
    end

    def punch_slug
      update_column :slug, "#{Time.now.to_i}_#{slug}" # punch slug with date prefix to allow reuse of original
    end

    def anything_changed?
      changed? || @nested_changes
    end

    def reset_nested_changes
      @nested_changes = false
    end

    # there's a weird quirk with the delegate stuff that does not automatically save the delegate object
    # when saving so we force a save using a hook
    # Fix for issue #5306
    def save_master
      if master && (master.changed? || master.new_record? || (master.default_price && (master.default_price.changed? || master.default_price.new_record?)))
        master.save!
        @nested_changes = true
      end
    end

    # If the master cannot be saved, the Product object will get its errors
    # and will be destroyed
    def validate_master
      # We call master.default_price here to ensure price is initialized.
      # Required to avoid Variant#check_price validation failing on create.
      unless master.default_price && master.valid?
        master.errors.each do |att, error|
          self.errors.add(att, error)
        end
      end
    end

    # ensures the master variant is flagged as such
    def set_master_variant_defaults
      master.is_master = true
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

    # Iterate through this products taxons and taxonomies and touch their timestamps in a batch
    def touch_taxons
      taxons_to_touch = taxons.map(&:self_and_ancestors).flatten.uniq
      Spree::Taxon.where(id: taxons_to_touch.map(&:id)).update_all(updated_at: Time.current)

      taxonomy_ids_to_touch = taxons_to_touch.map(&:taxonomy_id).flatten.uniq
      Spree::Taxonomy.where(id: taxonomy_ids_to_touch).update_all(updated_at: Time.current)
    end

  end
end

require_dependency 'spree/product/scopes'
