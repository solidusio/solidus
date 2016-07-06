object false
node(:count) { @taxons.count }
node(:total_count) { @taxons.total_count }
node(:current_page) { @taxons.current_page }
node(:per_page) { @taxons.limit_value }
node(:pages) { @taxons.total_pages }
child @taxons => :taxons do
  attributes *taxon_attributes
  unless params[:without_children]
    extends "spree/api/taxons/taxons"
  end
end
