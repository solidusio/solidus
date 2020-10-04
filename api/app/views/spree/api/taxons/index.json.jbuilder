# frozen_string_literal: true

json.partial! 'spree/api/shared/pagination', pagination: @taxons
json.taxons(@taxons) do |taxon|
  json.(taxon, *taxon_attributes)
  unless params[:without_children]
    json.partial!("spree/api/taxons/taxons", taxon: taxon)
  end
end
