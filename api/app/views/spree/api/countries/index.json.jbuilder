json.countries(@countries) { |country| json.(country, *country_attributes) }
json.count(@countries.count)
json.current_page(@countries.current_page)
json.pages(@countries.total_pages)
