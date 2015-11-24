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

    scope :by_zone, ->(zone) { where(zone_id: zone) }

    # Gets the array of TaxRates appropriate for the specified order
    scope :for_zone, -> (zone) do
      where(zone_id: Spree::Zone.with_shared_members(zone).pluck(:id))
    end

    scope :included_in_price, -> { where(included_in_price: true) }

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

    # Tax rates can *potentially* be applicable to an order.
    # We do not know if they are/aren't until we check their tax categories - if
    # they match any of the line item's, they are applicable.
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
    def self.adjust(order_tax_zone, items)
      # Early return to make sure nothing happens if there's no tax zone on
      # the order.
      return unless order_tax_zone

      # Destroy all tax adjustments using destroy_all to ensure adjustment destroy callback fires.
      Spree::Adjustment.where(adjustable: items).tax.destroy_all
      # TODO: Make sure items is always an AR relation and use `update_columns`
      # TODO: Also: The whole pre_tax_amount stuff is so unnecessary once prices are right.
      # I think the main thing to be done here is adapting the tests, which use arrays.
      items.each { |item| item.update_column(:pre_tax_amount, item.discounted_amount) }

      # Find tax rates matching the order's tax zone
      rates = for_zone(order_tax_zone)

      # Imagine with me this scenario:
      # You are living in Spain and you have a store which ships the US.
      # Spain is therefore your default tax rate.
      # When you ship to Spain, you want the Spanish rate to apply.
      # When you ship to the US, you want your Spanish rate to be refunded.
      # This little bit of code adds the default tax zone's VAT rates so #adjust
      # knows what to refund.
      #
      # For further discussion, see #4397 and #4327.
      if default_tax_zone && !default_tax_zone.contains?(order_tax_zone) && rates.included_in_price.empty?
        rates += for_zone(default_tax_zone)
      end

      # Get all tax categories for which we have tax rates
      tax_categories = rates.map(&:tax_category)
      # Identify which items have to have a tax rate applied
      # I think this could be done with an `items.join(:tax_category)` How?
      relevant_items = items.select do |item|
        tax_categories.include?(item.tax_category)
      end

      # For each item,
      relevant_items.each do |item|
        # Select the rates with the same tax category
        relevant_rates = rates.select do |rate|
          rate.tax_category == item.tax_category
        end
        # Store the pre_tax_amount on the item
        # (incredibly inelegant, this line should go)
        store_pre_tax_amount(item, relevant_rates)
        # Have all the relevant rates adjust the item.
        relevant_rates.each do |rate|
          rate.adjust(order_tax_zone, item)
        end
      end
    end

    # Creates necessary tax adjustments for the order.
    def adjust(order_tax_zone, item)
      amount = compute_amount(item)
      return if amount == 0

      included = included_in_price && default_zone_or_zone_match?(order_tax_zone)

      if amount < 0
        label = Spree.t(:refund) + ' ' + create_label
      end

      self.adjustments.create!({
        :adjustable => item,
        :amount => amount,
        :order_id => item.order_id,
        :label => label || create_label,
        :included => included
      })
    end

    # This method is used by Adjustment#update to recalculate the cost.
    def compute_amount(item)
      if included_in_price
        if default_zone_or_zone_match?(item.order.tax_zone)
          calculator.compute(item)
        else
          # In this case, it's a refund.
          calculator.compute(item) * - 1
        end
      else
        calculator.compute(item)
      end
    end

    def default_zone_or_zone_match?(order_tax_zone)
      default_tax = Zone.default_tax
      (default_tax && default_tax.contains?(order_tax_zone)) || order_tax_zone == self.zone
    end

    private

    def self.default_tax_zone
      @_default_tax_zone = Spree::Zone.default_tax
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
