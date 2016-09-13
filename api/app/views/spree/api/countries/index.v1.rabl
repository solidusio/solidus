object false
child(@countries => :countries) do
  attributes *country_attributes
end
node(:count) { @countries.count }
node(:current_page) { @countries.current_page }
node(:pages) { @countries.total_pages }
