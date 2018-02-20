# frozen_string_literal: true

if params[:set] == "nested"
  json.partial!("spree/api/taxonomies/nested", taxonomy: taxonomy)
else
  json.(taxonomy, *taxonomy_attributes)
  json.root do
    json.(taxonomy.root, *taxon_attributes)
    json.taxons(taxonomy.root.children) do |taxon|
      json.(taxon, *taxon_attributes)
    end
  end
end
