json.count(@taxons.count)
json.total_count(@taxons.total_count)
json.current_page(@taxons.current_page)
json.per_page(@taxons.limit_value)
json.pages(@taxons.total_pages)
json.taxons(@taxons) do |taxon|
  json.(taxon, *taxon_attributes)
  unless params[:without_children]
    json.partial!("spree/api/taxons/taxons", taxon: taxon)
  end
end
