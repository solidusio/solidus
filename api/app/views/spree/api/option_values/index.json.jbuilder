# frozen_string_literal: true

json.array! @option_values do |option_value|
  json.partial!("spree/api/option_values/option_value", option_value: option_value)
end
