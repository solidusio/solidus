# frozen_string_literal: true

# This class represents all of the actions one can take to modify an Order after it is complete
class Spree::OrderCancellations
  extend ActiveModel::Translation

  # If you need to message a third party service when an item is canceled then
  # set short_ship_tax_notifier to an object that responds to:
  #     #call(unit_cancels)
  class_attribute :short_ship_tax_notifier

  # allows sending an email when inventory is cancelled
  class_attribute :send_cancellation_mailer
  self.send_cancellation_mailer = true

  def initialize(order)
    @order = order
  end

  # Marks inventory units short shipped. Adjusts the order based on the value of the inventory.
  # Sends an email to the customer about what inventory has been short shipped.
  #
  # @api public
  #
  # @param [Array<InventoryUnit>] inventory_units the inventory units to be short shipped
  # @param [Spree.user_class] whodunnit (deprecated) the system or person that is short shipping the inventory unit
  # @param [Spree.user_class] created_by the system or person that is short shipping the inventory unit
  #
  # @return [Array<UnitCancel>] the units that have been canceled due to short shipping
  def short_ship(inventory_units, whodunnit: nil, created_by: nil)
    if whodunnit
      created_by ||= whodunnit
      Spree::Deprecation.warn("Calling #short_ship on #{self} with whodunnit is deprecated, use created_by instead")
    end

    if inventory_units.map(&:order_id).uniq != [@order.id]
      raise ArgumentError, "Not all inventory units belong to this order"
    end

    unit_cancels = []

    Spree::OrderMutex.with_lock!(@order) do
      Spree::InventoryUnit.transaction do
        inventory_units.each do |iu|
          unit_cancels << short_ship_unit(iu, created_by: created_by)
        end

        update_shipped_shipments(inventory_units)
        Spree::Config.order_mailer_class.inventory_cancellation_email(@order, inventory_units.to_a).deliver_later if Spree::OrderCancellations.send_cancellation_mailer
      end

      @order.recalculate

      if short_ship_tax_notifier
        short_ship_tax_notifier.call(unit_cancels)
      end
    end

    unit_cancels
  end

  # Marks inventory unit canceled. Optionally allows specifying the reason why and who is performing the action.
  #
  # @api public
  #
  # @param [InventoryUnit] inventory_unit the inventory unit to be canceled
  # @param [String] reason the reason that you are canceling the inventory unit
  # @param [Spree.user_class] whodunnit (deprecated) the system or person that is canceling the inventory unit
  # @param [Spree.user_class] created_by the system or person that is canceling the inventory unit
  #
  # @return [UnitCancel] the unit that has been canceled
  def cancel_unit(inventory_unit, reason: Spree::UnitCancel::DEFAULT_REASON, whodunnit: nil, created_by: nil)
    if whodunnit
      created_by ||= whodunnit
      Spree::Deprecation.warn("Calling #cancel_unit on #{self} with whodunnit is deprecated, use created_by instead")
    end

    unit_cancel = nil

    Spree::OrderMutex.with_lock!(@order) do
      unit_cancel = Spree::UnitCancel.create!(
        inventory_unit: inventory_unit,
        reason: reason,
        created_by: created_by
      )

      inventory_unit.cancel!
    end

    unit_cancel
  end

  # Reimburses inventory units due to cancellation.
  #
  # @api public
  # @param [Array<InventoryUnit>] inventory_units the inventory units to be reimbursed
  # @param [Spree.user_class] created_by the user that is performing this action
  # @return [Reimbursement] the reimbursement for inventory being canceled
  def reimburse_units(inventory_units, created_by: nil)
    unless created_by
      Spree::Deprecation.warn("Calling #reimburse_units on #{self} without created_by is deprecated")
    end
    reimbursement = nil

    Spree::OrderMutex.with_lock!(@order) do
      return_items = inventory_units.map(&:current_or_new_return_item)
      reimbursement = Spree::Reimbursement.new(order: @order, return_items: return_items)
      reimbursement.return_all(created_by: created_by)
    end

    reimbursement
  end

  private

  def short_ship_unit(inventory_unit, whodunnit: nil, created_by: nil)
    if whodunnit
      created_by ||= whodunnit
      Spree::Deprecation.warn("Calling #short_ship_unit on #{self} with whodunnit is deprecated, use created_by instead")
    end

    unit_cancel = Spree::UnitCancel.create!(
      inventory_unit: inventory_unit,
      reason: Spree::UnitCancel::SHORT_SHIP,
      created_by: created_by
    )
    unit_cancel.adjust!
    inventory_unit.cancel!

    unit_cancel
  end

  # if any shipments are now fully shipped then mark them as such
  def update_shipped_shipments(inventory_units)
    shipments = Spree::Shipment.
      includes(:inventory_units).
      where(id: inventory_units.map(&:shipment_id)).
      to_a

    shipments.each do |shipment|
      if shipment.inventory_units.all? { |iu| iu.shipped? || iu.canceled? }
        shipment.update!(state: 'shipped', shipped_at: Time.current)
      end
    end
  end
end
