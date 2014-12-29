namespace :exchanges do
  desc %q{Takes unreturned exchanged items and creates a new order to charge
  the customer for not returning them}
  task charge_unreturned_items: :environment do

    unreturned_return_items =  Spree::ReturnItem.awaiting_return.exchange_processed.joins(:exchange_inventory_unit).where([
      "spree_inventory_units.created_at < :days_ago AND spree_inventory_units.state = :iu_state",
      days_ago: Spree::Config[:expedited_exchanges_days_window].days.ago, iu_state: "shipped"
    ]).to_a

    # Determine that a return item has already been deemed unreturned and therefore charged
    # by the fact that its exchange inventory unit has popped off to a different order
    unreturned_return_items.select! { |ri| ri.inventory_unit.order_id == ri.exchange_inventory_unit.order_id }

    failed_orders = []

    unreturned_return_items.group_by(&:exchange_shipment).each do |shipment, return_items|
      item_charger = Spree::UnreturnedItemCharger.new(shipment, return_items)
      begin
        item_charger.charge_for_items
        failed_orders << item_charger.order unless item_charger.order.completed? && item_charger.order.valid?
      rescue
        failed_orders << item_charger.order
      end
    end
    failure_message = failed_orders.map { |o| "#{o.number} - #{o.errors.full_messages}" }.join(", ")
    Spree::UnreturnedItemCharger.notify_of_errors(failure_message) if failed_orders.present?
  end
end

class UnableToChargeForUnreturnedItems < StandardError; end
