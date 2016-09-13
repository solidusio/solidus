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
    has_many :shipping_rate_taxes, class_name: "Spree::ShippingRateTax"

    validates :amount, presence: true, numericality: true
    validates :tax_category_id, presence: true

    # Finds all tax rates whose zones match a given address
    scope :for_address, ->(address) { joins(:zone).merge(Spree::Zone.for_address(address)) }
    scope :for_country,
          ->(country) { for_address(Spree::Tax::TaxLocation.new(country: country)) }

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
      Spree::Deprecation.warn("Please use Spree::Tax::OrderAdjuster or Spree::Tax::ItemAdjuster instead", caller)
      items.map do |item|
        Spree::Tax::ItemAdjuster.new(item, rates_for_order_zone: for_zone(order_tax_zone)).adjust!
      end
    end

    # Creates necessary tax adjustments for the order.
    def adjust(order_tax_zone, item)
      amount = compute_amount(item)
      return if amount == 0

      included = included_in_price && amount > 0

      item.adjustments.create!(
        source: self,
        amount: amount,
        order_id: item.order_id,
        label: adjustment_label(amount),
        included: included
      )
    end

    # This method is used by Adjustment#update to recalculate the cost.
    def compute_amount(item)
      calculator.compute(item)
    end

    private

    def adjustment_label(amount)
      Spree.t translation_key(amount),
              scope: "adjustment_labels.tax_rates",
              name: name.presence || tax_category.name,
              amount: amount_for_adjustment_label
    end

    def amount_for_adjustment_label
      ActiveSupport::NumberHelper::NumberToPercentageConverter.convert(
        amount * 100,
        locale: I18n.locale
      )
    end

    def translation_key(amount)
      key = included_in_price? ? "vat" : "sales_tax"
      key += "_refund" if amount < 0
      key += "_with_rate" if show_rate_in_label?
      key.to_sym
    end
  end
end
