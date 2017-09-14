json.shipping_rates @shipping_rates do |shipping_rate|
  json.partial!("spree/api/shipping_rates/shipping_rate", shipping_rate: shipping_rate)
end
