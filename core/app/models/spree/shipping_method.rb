module Spree
  class ShippingMethod < Spree::Base
    acts_as_paranoid
    include Spree::CalculatedAdjustments
    DISPLAY = [:both, :front_end, :back_end]

    has_many :shipping_method_categories, dependent: :destroy
    has_many :shipping_categories, through: :shipping_method_categories
    has_many :shipping_rates, inverse_of: :shipping_method
    has_many :shipments, through: :shipping_rates
    has_many :cartons, inverse_of: :shipping_method

    has_many :shipping_method_zones
    has_many :zones, through: :shipping_method_zones

    belongs_to :tax_category, -> { with_deleted }, class_name: 'Spree::TaxCategory'
    has_many :shipping_method_stock_locations, class_name: Spree::ShippingMethodStockLocation
    has_many :shipping_method_stock_locations, dependent: :destroy, class_name: "Spree::ShippingMethodStockLocation"
    has_many :stock_locations, through: :shipping_method_stock_locations

    validates :name, presence: true

    validate :at_least_one_shipping_category

    def self.with_all_shipping_category_ids(shipping_category_ids)
      # Some extra care is needed with the having clause to ensure we are
      # counting distinct records of the join table. Otherwise a join could
      # cause this to return incorrect results.
      join_table = ShippingMethodCategory.arel_table
      having = join_table[:id].count(true).eq(shipping_category_ids.count)
      joins(:shipping_method_categories).
        where(spree_shipping_method_categories: {shipping_category_id: shipping_category_ids}).
        group('spree_shipping_methods.id').
        having(having)
    end

    def self.available_in_stock_location(stock_location)
      smsl_table = ShippingMethodStockLocation.arel_table

      # We are searching for either a matching entry in the stock location join
      # table or available_to_all being true.
      # We need to use an outer join otherwise a shipping method with no
      # associated stock locations will be filtered out of the results. In
      # rails 5 this will be easy using .left_join and .or, but for now we must
      # use arel to achieve this.
      arel_join =
        arel_table.join(smsl_table, Arel::Nodes::OuterJoin).
        on(arel_table[:id].eq(smsl_table[:shipping_method_id])).
        join_sources
      arel_condition =
        arel_table[:available_to_all].eq(true).or(smsl_table[:stock_location_id].eq(stock_location.id))

      joins(arel_join).where(arel_condition).uniq
    end

    def include?(address)
      return false unless address
      zones.any? do |zone|
        zone.include?(address)
      end
    end

    def build_tracking_url(tracking)
      return if tracking.blank? || tracking_url.blank?
      tracking_url.gsub(/:tracking/, ERB::Util.url_encode(tracking)) # :url_encode exists in 1.8.7 through 2.1.0
    end

    def self.calculators
      spree_calculators.send(model_name_without_spree_namespace).select{ |c| c < Spree::ShippingCalculator }
    end

    # Some shipping methods are only meant to be set via backend
    def frontend?
      display_on != "back_end"
    end

    private

    def compute_amount(calculable)
      calculator.compute(calculable)
    end

    def at_least_one_shipping_category
      if shipping_categories.empty?
        errors[:base] << "You need to select at least one shipping category"
      end
    end
  end
end
