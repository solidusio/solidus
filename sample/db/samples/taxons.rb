# frozen_string_literal: true

Spree::Sample.load_sample("taxonomies")
Spree::Sample.load_sample("products")

categories = Spree::Taxonomy.find_by!(name: "Categories")
brands = Spree::Taxonomy.find_by!(name: "Brands")

products = {
  solidus_bottles: "Solidus Water Bottle",
  solidus_tote: "Solidus tote",
  solidus_hoodie: "Solidus hoodie",
  solidus_mug_set: "Solidus mug set",
  solidus_hat: "Solidus winter hat",
  solidus_sticker: "Solidus circle sticker",
  solidus_notebook: "Solidus notebook",
  solidus_tshirt: "Solidus t-shirt",
  solidus_long_sleeve_tee: "Solidus long sleeve tee",
  solidus_dark_tee: "Solidus dark tee",
  solidus_canvas_tote: "Solidus canvas tote bag",
  solidus_cap: "Solidus cap"
}

products.each do |key, name|
  products[key] = Spree::Product.find_by!(name:)
end

taxons = [
  {
    name: "Categories",
    taxonomy: categories,
  },
  {
    name: "Brands",
    taxonomy: brands
  },
  {
    name: "Solidus",
    taxonomy: brands,
    parent: "Brands",
    products: [
      products[:solidus_tote],
      products[:solidus_hoodie],
      products[:solidus_mug_set],
      products[:solidus_hat],
      products[:solidus_sticker],
      products[:solidus_notebook],
      products[:solidus_tshirt],
      products[:solidus_long_sleeve_tee],
      products[:solidus_dark_tee],
      products[:solidus_bottles],
      products[:solidus_canvas_tote],
      products[:solidus_cap]
    ]
  },
  {
    name: "Clothing",
    taxonomy: categories,
    parent: "Categories"
  },
  {
    name: "Accessories",
    taxonomy: categories,
    parent: "Categories"
  },
  {
    name: "Stickers",
    taxonomy: categories,
    parent: "Categories",
    products: [
      products[:solidus_sticker]
    ]
  },
  {
    name: "Caps",
    taxonomy: categories,
    parent: "Clothing",
    products: [
      products[:solidus_hat],
      products[:solidus_cap]
    ]
  },
  {
    name: "Totes",
    taxonomy: categories,
    parent: "Accessories",
    products: [
      products[:solidus_tote],
      products[:solidus_canvas_tote]
    ]
  },
  {
    name: "Water Bottles",
    taxonomy: categories,
    parent: "Accessories",
    products: [
      products[:solidus_bottles],
    ]
  },
  {
    name: "T-Shirts",
    taxonomy: categories,
    parent: "Clothing",
    products: [
      products[:solidus_tshirt],
      products[:solidus_dark_tee],
      products[:solidus_long_sleeve_tee]
    ],
  },
  {
    name: "Hoodies",
    taxonomy: categories,
    parent: "Clothing",
    products: [
      products[:solidus_hoodie],
    ]
  }
]

taxons.each do |taxon_attrs|
  if taxon_attrs[:parent]
    taxon_attrs[:parent] = Spree::Taxon.find_by!(name: taxon_attrs[:parent])
    Spree::Taxon.create!(taxon_attrs)
  end
end
