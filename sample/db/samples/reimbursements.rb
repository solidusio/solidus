# frozen_string_literal: true

Spree::Sample.load_sample("orders")

order          = Spree::Order.last
inventory_unit = order.inventory_units.first
stock_location = inventory_unit.find_stock_item.stock_location

return_item = Spree::ReturnItem.create(inventory_unit: inventory_unit)

return_item.exchange_variant = return_item.eligible_exchange_variants.last
return_item.build_exchange_inventory_unit
return_item.accept!

customer_return = Spree::CustomerReturn.create(
  stock_location: stock_location,
  return_items: [return_item]
)

order.reimbursements.create(
  customer_return: customer_return,
  return_items: [return_item]
)
