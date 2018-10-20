# frozen_string_literal: true

json.products(@products) do |product|
  json.id product.id
  json.name product.name
end

json.count @products.count
json.total_count @products.total_count
json.current_page params[:page] ? params[:page].to_i : 1
json.per_page params[:per_page] || Kaminari.config.default_per_page
json.pages @products.total_pages
