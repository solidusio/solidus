# This represents an inventory unit that has been canceled from an order after it has already been completed
# The reason specifies why it was canceled.
# This class should encapsulate logic related to canceling inventory after order complete
class Spree::UnitCancel < ActiveRecord::Base
  SHORT_SHIP = 'Short Ship'
  belongs_to :inventory_unit
  has_one :adjustment, as: :source, dependent: :destroy

  validates :inventory_unit, presence: true

  # Creates necessary cancel adjustments for the line item.
  def adjust!
    raise "Adjustment is already created" if adjustment

    amount = compute_amount(inventory_unit.line_item)

    create_adjustment!(
      adjustable: inventory_unit.line_item,
      amount: amount,
      order: inventory_unit.order,
      label: "#{Spree.t(:cancellation)} - #{reason}",
      eligible: true,
      state: 'closed',
    )
  end

  # This method is used by Adjustment#update to recalculate the cost.
  def compute_amount(line_item)
    raise "Adjustable does not match line item" unless line_item == inventory_unit.line_item
    -(line_item.total.to_d / line_item.inventory_units.not_canceled.reject(&:original_return_item ).size)
  end
end
