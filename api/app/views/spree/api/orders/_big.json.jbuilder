json.partial!("spree/api/orders/order", order: order)
json.payment_methods(order.available_payment_methods) do |payment_method|
  json.(payment_method, :id, :name, :partial_name)
  json.method_type payment_method.partial_name
end
json.bill_address do
  if order.billing_address
    json.partial!("spree/api/addresses/address", address: order.billing_address)
  else
    json.nil!
  end
end
json.ship_address do
  if order.shipping_address
    json.partial!("spree/api/addresses/address", address: order.shipping_address)
  else
    json.nil!
  end
end
json.line_items(order.line_items) do |line_item|
  json.partial!("spree/api/line_items/line_item", line_item: line_item)
end
json.payments(order.payments) do |payment|
  json.(payment, *payment_attributes)
  json.payment_method { json.(payment.payment_method, :id, :name) }
  json.source do
    if payment.source
      json.(payment.source, *payment_source_attributes)

      if @current_user_roles.include?("admin")
        json.(payment.source, :gateway_customer_profile_id, :gateway_payment_profile_id)
      end
    else
      json.nil!
    end
  end
end
json.shipments(order.shipments) do |shipment|
  json.partial!("spree/api/shipments/small", shipment: shipment)
end
json.adjustments(order.adjustments) do |adjustment|
  json.partial!("spree/api/adjustments/adjustment", adjustment: adjustment)
end
json.permissions do
  json.can_update current_ability.can?(:update, order)
end
json.credit_cards(order.valid_credit_cards) do |credit_card|
  json.partial!("spree/api/credit_cards/credit_card", credit_card: credit_card)
end
