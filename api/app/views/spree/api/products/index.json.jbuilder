# frozen_string_literal: true

json.partial! 'spree/api/shared/pagination', pagination: @products
json.products(@products) do |product|
  json.partial!("spree/api/products/product", product: product)
end
