# frozen_string_literal: true

json.taxons(taxon.children) do |taxon|
  json.(taxon, *taxon_attributes)
  json.partial!("spree/api/taxons/taxons", taxon: taxon)
end
