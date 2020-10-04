# frozen_string_literal: true

# This represents an inventory unit that has been canceled from an order after it has already been completed
# The reason specifies why it was canceled.
# This class should encapsulate logic related to canceling inventory after order complete
class Spree::UnitCancel < Spree::Base
  SHORT_SHIP = 'Short Ship'
  DEFAULT_REASON = 'Cancel'

  belongs_to :inventory_unit, optional: true
  has_one :adjustment, as: :source, dependent: :destroy

  validates :inventory_unit, presence: true

  # Creates necessary cancel adjustments for the line item.
  def adjust!
    raise "Adjustment is already created" if adjustment

    amount = compute_amount(inventory_unit.line_item)

    self.adjustment = inventory_unit.line_item.adjustments.create!(
      source: self,
      amount: amount,
      order: inventory_unit.order,
      label: "#{I18n.t('spree.cancellation')} - #{reason}",
      eligible: true,
      finalized: true
    )

    inventory_unit.line_item.order.recalculate
    adjustment
  end

  # This method is used by Adjustment#update to recalculate the cost.
  def compute_amount(line_item)
    raise "Adjustable does not match line item" unless line_item == inventory_unit.line_item

    -weighted_line_item_amount(line_item)
  end

  private

  def weighted_line_item_amount(line_item)
    quantity_of_line_item = quantity_of_line_item(line_item)
    raise ZeroDivisionError, "Line Item does not have any inventory units available to cancel" if quantity_of_line_item.zero?

    line_item.total_before_tax / quantity_of_line_item
  end

  def quantity_of_line_item(line_item)
    BigDecimal(line_item.inventory_units.not_canceled.reject(&:original_return_item).size)
  end
end
