# frozen_string_literal: true

Spree::Sample.load_sample("taxonomies")
Spree::Sample.load_sample("products")

categories = Spree::Taxonomy.find_by!(name: "Categories")
brands = Spree::Taxonomy.find_by!(name: "Brand")

products = {
  solidus_tshirt: "Solidus T-Shirt",
  solidus_long: "Solidus Long Sleeve",
  solidus_tote: "Solidus Tote",
  ruby_tote: "Ruby Tote",
  solidus_snapback_cap: "Solidus Snapback Cap",
  solidus_hoodie: "Solidus Hoodie Zip",
  ruby_hoodie: "Ruby Hoodie",
  ruby_hoodie_zip: "Ruby Hoodie Zip",
  ruby_polo: "Ruby Polo",
  solidus_mug: "Solidus Mug",
  ruby_mug: "Ruby Mug",
  solidus_girly: "Solidus Girly"
}

products.each do |key, name|
  products[key] = Spree::Product.find_by!(name: name)
end

taxons = [
  {
    name: "Categories",
    taxonomy: categories,
    position: 0
  },
  {
    name: "Clothing",
    taxonomy: categories,
    parent: "Categories"
  },
  {
    name: "Caps",
    taxonomy: categories,
    parent: "Categories",
    position: 1,
    products: [
      products[:solidus_snapback_cap]
    ]
  },
  {
    name: "Bags",
    taxonomy: categories,
    parent: "Categories",
    position: 2,
    products: [
      products[:solidus_tote],
      products[:ruby_tote]
    ]
  },
  {
    name: "Mugs",
    taxonomy: categories,
    parent: "Categories",
    position: 3,
    products: [
      products[:solidus_mug],
      products[:ruby_mug]
    ]
  },
  {
    name: "Shirts",
    taxonomy: categories,
    parent: "Clothing",
    position: 0,
    products: [
      products[:solidus_long],
      products[:ruby_polo],
      products[:solidus_girly]
    ]
  },
  {
    name: "Hoodie",
    taxonomy: categories,
    parent: "Clothing",
    position: 0,
    products: [
      products[:solidus_hoodie],
      products[:ruby_hoodie],
      products[:ruby_hoodie_zip]
    ]
  },
  {
    name: "T-Shirts",
    taxonomy: categories,
    parent: "Clothing",
    products: [
      products[:solidus_tshirt]
    ],
    position: 0
  },
  {
    name: "Brands",
    taxonomy: brands
  },
  {
    name: "Solidus",
    taxonomy: brands,
    parent: "Brand",
    products: [
      products[:solidus_tshirt],
      products[:solidus_long],
      products[:solidus_snapback_cap],
      products[:solidus_hoodie],
      products[:solidus_mug],
      products[:solidus_tote],
      products[:solidus_girly]
    ]
  },
  {
    name: "Ruby",
    taxonomy: brands,
    parent: "Brand",
    products: [
      products[:ruby_hoodie],
      products[:ruby_hoodie_zip],
      products[:ruby_polo],
      products[:ruby_mug],
      products[:ruby_tote]
    ]
  }
]

taxons.each do |taxon_attrs|
  if taxon_attrs[:parent]
    taxon_attrs[:parent] = Spree::Taxon.find_by!(name: taxon_attrs[:parent])
    Spree::Taxon.create!(taxon_attrs)
  end
end
