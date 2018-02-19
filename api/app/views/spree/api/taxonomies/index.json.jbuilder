# frozen_string_literal: true

json.taxonomies(@taxonomies) do |taxonomy|
  json.partial!("spree/api/taxonomies/taxonomy", taxonomy: taxonomy)
end
json.partial! 'spree/api/shared/pagination', pagination: @taxonomies
