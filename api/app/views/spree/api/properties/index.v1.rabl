object false
child(@properties => :properties) do
  attributes *property_attributes
end
node(:count) { @properties.count }
node(:current_page) { @properties.current_page }
node(:pages) { @properties.total_pages }
