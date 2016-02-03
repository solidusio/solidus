module Spree
  class DefaultTaxZoneValidator < ActiveModel::Validator
    def validate(record)
      if record.included_in_price
        record.errors.add(:included_in_price, Spree.t(:included_price_validation)) unless Zone.default_tax
      end
    end
  end
end

module Spree
  class TaxRate < Spree::Base
    acts_as_paranoid

    # Need to deal with adjustments before calculator is destroyed.
    before_destroy :deals_with_adjustments_for_deleted_source

    include Spree::CalculatedAdjustments
    include Spree::AdjustmentSource

    belongs_to :zone, class_name: "Spree::Zone", inverse_of: :tax_rates
    belongs_to :tax_category, class_name: "Spree::TaxCategory", inverse_of: :tax_rates

    has_many :adjustments, as: :source

    validates :amount, presence: true, numericality: true
    validates :tax_category_id, presence: true
    validates_with DefaultTaxZoneValidator

    # Finds geographically matching tax rates for a tax zone.
    # We do not know if they are/aren't applicable until we attempt to apply these rates to
    # the items contained within the Order itself.
    # For instance, if a rate passes the criteria outlined in this method,
    # but then has a tax category that doesn't match against any of the line items
    # inside of the order, then that tax rate will not be applicable to anything.
    # For instance:
    #
    # Zones:
    #   - Spain (default tax zone)
    #   - France
    #
    # Tax rates: (note: amounts below do not actually reflect real VAT rates)
    #   21% inclusive - "Clothing" - Spain
    #   18% inclusive - "Clothing" - France
    #   10% inclusive - "Food" - Spain
    #   8% inclusive - "Food" - France
    #   5% inclusive - "Hotels" - Spain
    #   2% inclusive - "Hotels" - France
    #
    # Order has:
    #   Line Item #1 - Tax Category: Clothing
    #   Line Item #2 - Tax Category: Food
    #
    # Tax rates that should be selected:
    #
    #  21% inclusive - "Clothing" - Spain
    #  10% inclusive - "Food" - Spain
    #
    # If the order's address changes to one in France, then the tax will be recalculated:
    #
    #  18% inclusive - "Clothing" - France
    #  8% inclusive - "Food" - France
    #
    # Note here that the "Hotels" tax rates will not be used at all.
    # This is because there are no items which have the tax category of "Hotels".
    #
    # Under no circumstances should negative adjustments be applied for the Spanish tax rates.
    #
    # Those rates should never come into play at all and only the French rates should apply.
    scope :for_zone, ->(zone) { where(zone_id: Spree::Zone.with_shared_members(zone).pluck(:id)) }
    scope :included_in_price, -> { where(included_in_price: true) }

    # Create tax adjustments for some items that have the same tax zone.
    #
    # @deprecated Please use Spree::Tax::OrderAdjuster or Spree::Tax::ItemAdjuster instead.
    #
    # @param [Spree::Zone] order_tax_zone is the smalles applicable zone to the order's tax address
    # @param [Array<Spree::LineItem,Spree::Shipment>] items to be adjusted
    def self.adjust(order_tax_zone, items)
      ActiveSupport::Deprecation.warn("Please use Spree::Tax::OrderAdjuster or Spree::Tax::ItemAdjuster instead", caller)
      items.map do |item|
        Spree::Tax::ItemAdjuster.new(item, rates_for_order_zone: for_zone(order_tax_zone)).adjust!
      end
    end

    # Pre-tax amounts must be stored so that we can calculate
    # correct rate amounts in the future. For example:
    # https://github.com/spree/spree/issues/4318#issuecomment-34723428
    def self.store_pre_tax_amount(item, rates)
      pre_tax_amount = case item
                       when Spree::LineItem then item.discounted_amount
                       when Spree::Shipment then item.discounted_cost
        end

      included_rates = rates.select(&:included_in_price)
      if included_rates.any?
        pre_tax_amount /= (1 + included_rates.map(&:amount).sum)
      end

      item.update_column(:pre_tax_amount, pre_tax_amount.round(2))
    end

    # Creates necessary tax adjustments for the order.
    def adjust(order_tax_zone, item)
      amount = compute_amount(item)
      return if amount == 0

      included = included_in_price && default_zone_or_zone_match?(order_tax_zone)

      if amount < 0
        label = Spree.t(:refund) + ' ' + create_label
      end

      adjustments.create!({
        adjustable: item,
        amount: amount,
        order_id: item.order_id,
        label: label || create_label,
        included: included
      })
    end

    # This method is used by Adjustment#update to recalculate the cost.
    def compute_amount(item)
      if included_in_price && !default_zone_or_zone_match?(item.order.tax_zone)
        # In this case, it's a refund.
        calculator.compute(item) * - 1
      else
        calculator.compute(item)
      end
    end

    def default_zone_or_zone_match?(order_tax_zone)
      Zone.default_tax.try!(:contains?, order_tax_zone) || zone.contains?(order_tax_zone)
    end

    private

    def create_label
      label = ""
      label << (name.present? ? name : tax_category.name) + " "
      label << (show_rate_in_label? ? "#{amount * 100}%" : "")
      label << " (#{Spree.t(:included_in_price)})" if included_in_price?
      label
    end
  end
end
