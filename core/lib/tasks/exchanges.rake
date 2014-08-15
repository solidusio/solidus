namespace :exchanges do
  desc %q{Takes unreturned exchanged items and creates a new order to charge
  the customer for not returning them}
  task charge_unreturned_items: :environment do

    unreturned_return_items =  Spree::ReturnItem.awaiting_return.exchange_processed.joins(:exchange_inventory_unit).where([
      "spree_inventory_units.created_at < :days_ago",
      days_ago: Spree::Config[:expedited_exchanges_days_window].days.ago
    ]).to_a
    unreturned_return_items.select! { |ri| ri.inventory_unit.order_id == ri.exchange_inventory_unit.order_id }

    failed_orders = []

    unreturned_return_items.group_by(&:exchange_shipment).each do |shipment, return_items|
      begin
        inventory_units = return_items.map(&:exchange_inventory_unit)

        original_order = shipment.order
        order = Spree::Order.create(bill_address: original_order.bill_address,
                                    ship_address: original_order.ship_address,
                                    email: original_order.email)

        order.associate_user!(original_order.user) if original_order.user

        return_items.group_by(&:exchange_variant).map do |variant, variant_return_items|
          variant_inventory_units = variant_return_items.map(&:exchange_inventory_unit)
          line_item = Spree::LineItem.create(variant: variant, quantity: variant_return_items.count, order: order)
          variant_inventory_units.each { |i| i.update_columns(line_item_id: line_item.id, order_id: order.id) }
        end

        Spree::OrderUpdater.new(order.reload).update

        card_to_reuse = original_order.valid_credit_cards.first
        # TODO bring back default logic when the default cc work is reimplemented
        # card_to_reuse = original_order.user.credit_cards.default.first if !card_to_reuse && original_order.user
        card_to_reuse = original_order.user.credit_cards.last if !card_to_reuse && original_order.user

        Spree::Payment.create(order: order,
                              payment_method_id: card_to_reuse.try(:payment_method_id),
                              source: card_to_reuse,
                              amount: order.total)

        inventory_units.each { |i| i.update_columns(order_id: order.id) }
        shipment.update_columns(order_id: order.id)
        order.update_columns(state: "confirm")

        order.next
        Spree::OrderUpdater.new(order.reload).update
        order.finalize!

        failed_orders << order unless order.completed? && order.valid?
      rescue
        failed_orders << order
      end
    end
    raise UnableToChargeForUnreturnedItems.new(failed_orders.map(&:number).join(", ")) if failed_orders.present?
  end
end

class UnableToChargeForUnreturnedItems < StandardError; end
