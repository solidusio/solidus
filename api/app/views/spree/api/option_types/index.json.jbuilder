# frozen_string_literal: true

json.array! @option_types do |option_type|
  json.partial!("spree/api/option_types/option_type", option_type: option_type)
end
