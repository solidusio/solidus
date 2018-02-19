# frozen_string_literal: true

json.(taxonomy, *taxonomy_attributes)
json.root do
  json.(taxonomy.root, *taxon_attributes)
  json.taxons(taxonomy.root.children) do |taxon|
    json.(taxon, *taxon_attributes)
    json.partial!("spree/api/taxons/taxons", taxon: taxon)
  end
end
