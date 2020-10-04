# frozen_string_literal: true

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
    ##
    # payment.source could be a Spree::Payment. If it is then we need to call
    # source twice.
    # @see https://github.com/solidusio/solidus/blob/v2.4/backend/app/views/spree/admin/payments/show.html.erb#L16
    #
    payment_source = payment.source.is_a?(Spree::Payment) ? payment.source.source : payment.source

    if payment_source
      json.partial!(
        "spree/api/payments/source_views/#{payment.payment_method.partial_name}",
        payment_source: payment_source
      )
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
