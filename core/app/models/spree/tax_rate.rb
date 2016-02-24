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

    # Finds all tax rates whose zones match a given address
    scope :for_address, ->(address) { joins(:zone).merge(Spree::Zone.for_address(address)) }
    scope :included_in_price, -> { where(included_in_price: true) }

    # Create tax adjustments for some items that have the same tax zone.
    #
    # @deprecated Please use Spree::Tax::OrderAdjuster or Spree::Tax::ItemAdjuster instead.
    #
    # @param [Spree::Zone] _order_tax_zone will not be used
    # @param [Array<Spree::LineItem,Spree::Shipment>] items to be adjusted
    def self.adjust(_order_tax_zone, items)
      ActiveSupport::Deprecation.warn("Please use Spree::Tax::OrderAdjuster or Spree::Tax::ItemAdjuster instead", caller)
      items.map do |item|
        Spree::Tax::ItemAdjuster.new(
          item,
          order_rates: for_address(items.first.order.tax_address),
          default_vat_rates: included_in_price.for_address(Spree::Config.default_tax_location)
        ).adjust!
      end
    end

    # Pre-tax amounts must be stored so that we can calculate
    # correct rate amounts in the future. For example:
    # https://github.com/spree/spree/issues/4318#issuecomment-34723428
    def self.store_pre_tax_amount(item, rates)
      sum_of_included_rates = rates.select(&:included_in_price).map(&:amount).sum
      pre_tax_amount = item.discounted_amount / (1 + sum_of_included_rates)

      item.update_column(:pre_tax_amount, pre_tax_amount)
    end

    def applicable_for?(item)
      tax_category == item.tax_category
    end

    # Creates necessary tax adjustments for the order.
    def adjust(_order_tax_zone, item)
      amount = compute_amount(item)
      return if amount == 0

      included = included_in_price && !refund?(item.order.tax_address)

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
      if included_in_price && refund?(item.order.tax_address)
        # In this case, it's a refund.
        calculator.compute(item) * - 1
      else
        calculator.compute(item)
      end
    end

    private

    def refund?(address)
      !(
        self.class.for_address(address).include?(self) &&
        self.class.for_address(Spree::Config.default_tax_location).include?(self)
      )
    end

    def create_label
      label = ""
      label << (name.present? ? name : tax_category.name) + " "
      label << (show_rate_in_label? ? "#{amount * 100}%" : "")
      label << " (#{Spree.t(:included_in_price)})" if included_in_price?
      label
    end
  end
end
