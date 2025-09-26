# frozen_string_literal: true

json.taxons(taxon.children) do |taxon|
  json.call(taxon, *taxon_attributes)
  json.partial!("spree/api/taxons/taxons", taxon:)
end
