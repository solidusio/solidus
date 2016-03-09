namespace :exchanges do
  desc 'Takes unreturned exchanged items and creates a new order to charge
  the customer for not returning them'
  task charge_unreturned_items: :environment do
    unreturned_return_items = Spree::ReturnItem.expecting_return.exchange_processed.joins(:exchange_inventory_unit).where([
      "spree_inventory_units.created_at < :days_ago AND spree_inventory_units.state = :iu_state",
      days_ago: Spree::Config[:expedited_exchanges_days_window].days.ago, iu_state: "shipped"
    ]).preload(:exchange_inventory_unit).to_a

    # Determine that a return item has already been deemed unreturned and therefore charged
    # by the fact that its exchange inventory unit has popped off to a different order
    unreturned_return_items.select! { |ri| ri.inventory_unit.order_id == ri.exchange_inventory_unit.order_id }

    failures = []

    unreturned_return_items.group_by(&:exchange_shipment).each do |shipment, return_items|
      item_charger = Spree::UnreturnedItemCharger.new(shipment, return_items)

      begin
        item_charger.charge_for_items
      rescue Spree::UnreturnedItemCharger::ChargeFailure => e
        failure = { message: e.message }
      rescue => e
        failure = { message: "#{e.class}: #{e.message}" }
      end

      next unless failure
      failure[:new_order] = item_charger.new_order.number if item_charger.new_order
      failures << failure.merge({
        order: item_charger.original_order.number,
        shipment: shipment.number,
        return_items: return_items.map(&:id),
        order_errors: item_charger.original_order.errors.full_messages
      })
    end

    if failures.any?
      if Spree::UnreturnedItemCharger.failure_handler
        Spree::UnreturnedItemCharger.failure_handler.call(failures)
      else
        raise Spree::ChargeUnreturnedItemsFailures.new(failures.to_json)
      end
    end
  end
end

class Spree::ChargeUnreturnedItemsFailures < StandardError; end
