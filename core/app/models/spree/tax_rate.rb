# frozen_string_literal: true

module Spree
  class TaxRate < Spree::Base
    include Spree::SoftDeletable

    # Need to deal with adjustments before calculator is destroyed.
    before_destroy :remove_adjustments_from_incomplete_orders
    before_discard :remove_adjustments_from_incomplete_orders

    include Spree::CalculatedAdjustments
    include Spree::AdjustmentSource

    enum :level, {
      item: 0,
      order: 1
    }, suffix: true

    belongs_to :zone, class_name: "Spree::Zone", inverse_of: :tax_rates, optional: true

    has_many :tax_rate_tax_categories,
      class_name: 'Spree::TaxRateTaxCategory',
      dependent: :destroy,
      inverse_of: :tax_rate
    has_many :tax_categories,
      through: :tax_rate_tax_categories,
      class_name: 'Spree::TaxCategory',
      inverse_of: :tax_rates

    has_many :adjustments, as: :source, dependent: :restrict_with_error
    has_many :shipping_rate_taxes, class_name: "Spree::ShippingRateTax", dependent: :restrict_with_error

    validates :amount, presence: true, numericality: true

    self.allowed_ransackable_associations = %w[tax_categories zone]

    # Finds all tax rates whose zones match a given address
    scope :for_address, ->(address) { joins(:zone).merge(Spree::Zone.for_address(address)) }
    scope :for_country,
          ->(country) { for_address(Spree::Tax::TaxLocation.new(country:)) }
    scope :active, -> do
      table = arel_table
      time = Time.current
      where(table[:starts_at].eq(nil).or(table[:starts_at].lt(time))).
        where(table[:expires_at].eq(nil).or(table[:expires_at].gt(time)))
    end

    # Finds geographically matching tax rates for a tax zone.
    # We do not know if they are/aren't applicable until we attempt to apply these rates to
    # the items contained within the Order itself.
    # For instance, if a rate passes the criteria outlined in this method,
    # but then has a tax category that doesn't match against any of the line items
    # inside of the order, then that tax rate will not be applicable to anything.
    # For instance:
    #
    # Zones:
    #   - Spain
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
    scope :for_zone, ->(zone) do
      if zone
        where(zone_id: Spree::Zone.with_shared_members(zone).pluck(:id))
      else
        none
      end
    end
    scope :included_in_price, -> { where(included_in_price: true) }

    # This method is used by Adjustment#update to recalculate the cost.
    def compute_amount(item)
      calculator.compute(item)
    end

    def active?
      (starts_at.nil? || starts_at < Time.current) &&
        (expires_at.nil? || expires_at > Time.current)
    end

    def adjustment_label(amount)
      I18n.t(
        translation_key(amount),
        scope: "spree.adjustment_labels.tax_rates",
        name: name.presence || tax_categories.map(&:name).join(", "),
        amount: amount_for_adjustment_label
      )
    end

    def display_amount
      amount_for_adjustment_label
    end

    private

    def amount_for_adjustment_label
      ActiveSupport::NumberHelper::NumberToPercentageConverter.convert(
        amount * 100,
        locale: I18n.locale
      )
    end

    def translation_key(_amount)
      return "flat_fee" if calculator.is_a?(Spree::Calculator::FlatFee)

      key = included_in_price? ? "vat" : "sales_tax"
      key += "_with_rate" if show_rate_in_label?
      key.to_sym
    end
  end
end
