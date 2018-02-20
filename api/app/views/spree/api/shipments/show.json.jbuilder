# frozen_string_literal: true

json.cache! [I18n.locale, @shipment] do
  json.(@shipment, *shipment_attributes)
  json.order_id(@shipment.order.number)
  json.stock_location_name(@shipment.stock_location.name)
  json.shipping_rates(@shipment.shipping_rates) do |shipping_rate|
    json.partial!("spree/api/shipping_rates/shipping_rate", shipping_rate: shipping_rate)
  end
  json.selected_shipping_rate do
    if @shipment.selected_shipping_rate
      json.partial!("spree/api/shipping_rates/shipping_rate", shipping_rate: @shipment.selected_shipping_rate)
    else
      json.nil!
    end
  end
  json.shipping_methods(@shipment.shipping_methods) do |shipping_method|
    json.(shipping_method, :id, :name)
    json.zones(shipping_method.zones) do |zone|
      json.(zone, :id, :name, :description)
    end
    json.shipping_categories(shipping_method.shipping_categories) do |shipping_category|
      json.(shipping_category, :id, :name)
    end
  end
  json.manifest(@shipment.manifest) do |manifest_item|
    json.variant do
      json.partial!("spree/api/variants/small", variant: manifest_item.variant)
    end
    json.quantity(manifest_item.quantity)
    json.states(manifest_item.states)
  end
end
