# frozen_string_literal: true

json.shipping_rates @shipping_rates do |shipping_rate|
  json.(shipping_rate, :name, :cost, :shipping_method_id, :shipping_method_code)
  json.display_cost(shipping_rate.display_cost.to_s)
end
