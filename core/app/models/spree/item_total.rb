# frozen_string_literal: true

class Spree::ItemTotal
  def initialize(item)
    @item = item
  end

  def recalculate!
    tax_adjustments = item.adjustments.select do |adjustment|
      adjustment.tax? && !adjustment.marked_for_destruction?
    end

    # Included tax adjustments are those which are included in the price.
    # These ones should not affect the eventual total price.
    #
    # Additional tax adjustments are the opposite, affecting the final total.
    item.included_tax_total = tax_adjustments.select(&:included?).sum(&:amount)
    item.additional_tax_total = tax_adjustments.reject(&:included?).sum(&:amount)

    item.adjustment_total = item.adjustments.reject { |adjustment|
      adjustment.marked_for_destruction? || adjustment.included?
    }.sum(&:amount)
  end

  private

  attr_reader :item
end
