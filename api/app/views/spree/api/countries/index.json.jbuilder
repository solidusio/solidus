json.countries(@countries) { |country| json.(country, *country_attributes) }
json.partial! 'spree/api/shared/pagination', pagination: @countries
