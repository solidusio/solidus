# frozen_string_literal: true

json.call(option_type, *option_type_attributes)
json.option_values(option_type.option_values) do |option_value|
  json.call(option_value, *option_value_attributes)
end
