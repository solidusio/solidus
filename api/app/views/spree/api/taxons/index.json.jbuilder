# frozen_string_literal: true

json.partial! "spree/api/shared/pagination", pagination: @taxons
json.taxons(@taxons) do |taxon|
  json.call(taxon, *taxon_attributes)
  unless params[:without_children]
    json.partial!("spree/api/taxons/taxons", taxon:)
  end
end
