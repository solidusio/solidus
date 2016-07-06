object false
child(@taxonomies => :taxonomies) do
  extends "spree/api/taxonomies/show"
end
node(:count) { @taxonomies.count }
node(:current_page) { @taxonomies.current_page }
node(:pages) { @taxonomies.total_pages }
