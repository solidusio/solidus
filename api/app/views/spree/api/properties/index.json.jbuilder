# frozen_string_literal: true

json.properties(@properties) do |property|
  json.call(property, *property_attributes)
end
json.partial! "spree/api/shared/pagination", pagination: @properties
