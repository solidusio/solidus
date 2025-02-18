# frozen_string_literal: true

json.call(shipping_rate, :id, :name, :cost, :selected, :shipping_method_id, :shipping_method_code)
json.display_cost(shipping_rate.display_cost.to_s)
