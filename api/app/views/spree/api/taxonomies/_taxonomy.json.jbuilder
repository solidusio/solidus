# frozen_string_literal: true

if params[:set] == "nested"
  json.partial!("spree/api/taxonomies/nested", taxonomy:)
else
  json.call(taxonomy, *taxonomy_attributes)
  json.root do
    json.call(taxonomy.root, *taxon_attributes)
    json.taxons(taxonomy.root.children) do |taxon|
      json.call(taxon, *taxon_attributes)
    end
  end
end
