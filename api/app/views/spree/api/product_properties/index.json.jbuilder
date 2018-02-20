# frozen_string_literal: true

json.product_properties(@product_properties) do |product_property|
  json.(product_property, *product_property_attributes)
end
json.partial! 'spree/api/shared/pagination', pagination: @product_properties
