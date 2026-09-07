# frozen_string_literal: true

taxonomies = [
  {name: "Categories"},
  {name: "Brands"}
]

taxonomies.each do |taxonomy_attrs|
  Spree::Taxonomy.find_or_create_by!(taxonomy_attrs)
end
