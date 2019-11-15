# frozen_string_literal: true

json.cache! [I18n.locale, order] do
  json.(order, *order_attributes)
  json.display_item_total(order.display_item_total.to_s)
  json.total_quantity(order.line_items.to_a.sum(&:quantity))
  json.display_total(order.display_total.to_s)
  json.display_ship_total(order.display_ship_total)
  json.display_tax_total(order.display_tax_total)
  json.token(order.guest_token)
  json.checkout_steps(order.checkout_steps)
end
