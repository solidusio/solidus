# This class represents all of the actions one can take to modify an Order after it is complete
class Spree::OrderCancellations

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

  def short_ship(inventory_units, whodunnit:nil)
    if inventory_units.map(&:order_id).uniq != [@order.id]
      raise ArgumentError, "Not all inventory units belong to this order"
    end

    unit_cancels = []

    Spree::OrderMutex.with_lock!(@order) do

      Spree::InventoryUnit.transaction do
        inventory_units.each do |iu|
          unit_cancels << short_ship_unit(iu, whodunnit: whodunnit)
        end

        update_shipped_shipments(inventory_units)
        Spree::OrderMailer.inventory_cancellation_email(@order, inventory_units).deliver if Spree::OrderCancellations.send_cancellation_mailer
      end

      @order.update!

      if short_ship_tax_notifier
        short_ship_tax_notifier.call(unit_cancels)
      end
    end

    unit_cancels
  end

  private

  def short_ship_unit(inventory_unit, whodunnit:nil)
    unit_cancel = Spree::UnitCancel.create!(
      inventory_unit: inventory_unit,
      reason: Spree::UnitCancel::SHORT_SHIP,
      created_by: whodunnit,
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
      if shipment.inventory_units.all? {|iu| iu.shipped? || iu.canceled? }
        shipment.update_attributes!(state: 'shipped', shipped_at: Time.now)
      end
    end
  end
end
