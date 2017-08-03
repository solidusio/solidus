json.zones(@zones) do |zone|
  json.partial!("spree/api/zones/zone", zone: zone)
end
json.count(@zones.count)
json.current_page(@zones.current_page)
json.pages(@zones.total_pages)
