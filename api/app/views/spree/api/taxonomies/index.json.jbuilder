json.taxonomies(@taxonomies) do |taxonomy|
  json.partial!("spree/api/taxonomies/taxonomy", taxonomy: taxonomy)
end
json.count(@taxonomies.count)
json.current_page(@taxonomies.current_page)
json.pages(@taxonomies.total_pages)
