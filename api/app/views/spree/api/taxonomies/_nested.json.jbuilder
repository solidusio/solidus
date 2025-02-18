# frozen_string_literal: true

json.call(taxonomy, *taxonomy_attributes)
json.root do
  json.call(taxonomy.root, *taxon_attributes)
  json.taxons(taxonomy.root.children) do |taxon|
    json.call(taxon, *taxon_attributes)
    json.partial!("spree/api/taxons/taxons", taxon:)
  end
end
