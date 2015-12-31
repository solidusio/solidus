namespace :exchanges do
  desc %q{Takes unreturned exchanged items and creates a new order to charge
  the customer for not returning them}
  task charge_unreturned_items: :environment do

    unreturned_return_items =  Solidus::ReturnItem.expecting_return.exchange_processed.includes(:exchange_inventory_unit).where([
      "spree_inventory_units.created_at < :days_ago AND spree_inventory_units.state = :iu_state",
      days_ago: Solidus::Config[:expedited_exchanges_days_window].days.ago, iu_state: "shipped"
    ]).references(:exchange_inventory_units).to_a

    # Determine that a return item has already been deemed unreturned and therefore charged
    # by the fact that its exchange inventory unit has popped off to a different order
    unreturned_return_items.select! { |ri| ri.inventory_unit.order_id == ri.exchange_inventory_unit.order_id }

    failures = []

    unreturned_return_items.group_by(&:exchange_shipment).each do |shipment, return_items|
      item_charger = Solidus::UnreturnedItemCharger.new(shipment, return_items)

      begin
        item_charger.charge_for_items
      rescue Solidus::UnreturnedItemCharger::ChargeFailure => e
        failure = { message: e.message }
      rescue => e
        failure = { message: "#{e.class}: #{e.message}" }
      end

      if failure
        failure[:new_order] = item_charger.new_order.number if item_charger.new_order
        failures << failure.merge({
          order: item_charger.original_order.number,
          shipment: shipment.number,
          return_items: return_items.map(&:id),
          order_errors: item_charger.original_order.errors.full_messages,
        })
      end
    end

    if failures.any?
      if Solidus::UnreturnedItemCharger.failure_handler
        Solidus::UnreturnedItemCharger.failure_handler.call(failures)
      else
        raise Solidus::ChargeUnreturnedItemsFailures.new(failures.to_json)
      end
    end
  end
end

class Solidus::ChargeUnreturnedItemsFailures < StandardError; end
