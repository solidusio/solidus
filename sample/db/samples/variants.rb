# frozen_string_literal: true

Spree::Sample.load_sample("option_values")
Spree::Sample.load_sample("products")

solidus_tshirt = Spree::Product.find_by!(name: "Solidus T-Shirt")
solidus_long = Spree::Product.find_by!(name: "Solidus Long Sleeve")
solidus_snapback_cap = Spree::Product.find_by!(name: "Solidus Snapback Cap")
solidus_hoodie = Spree::Product.find_by!(name: "Solidus Hoodie Zip")
ruby_hoodie = Spree::Product.find_by!(name: "Ruby Hoodie")
ruby_hoodie_zip = Spree::Product.find_by!(name: "Ruby Hoodie Zip")
ruby_polo = Spree::Product.find_by!(name: "Ruby Polo")
solidus_mug = Spree::Product.find_by!(name: "Solidus Mug")
ruby_mug = Spree::Product.find_by!(name: "Ruby Mug")
solidus_tote = Spree::Product.find_by!(name: "Solidus Tote")
ruby_tote = Spree::Product.find_by!(name: "Ruby Tote")
solidus_womens_tshirt = Spree::Product.find_by!(name: "Solidus Women's T-Shirt")

small = Spree::OptionValue.find_by!(name: "Small")
medium = Spree::OptionValue.find_by!(name: "Medium")
large = Spree::OptionValue.find_by!(name: "Large")
extra_large = Spree::OptionValue.find_by!(name: "Extra Large")

blue = Spree::OptionValue.find_by!(name: "Blue")
black = Spree::OptionValue.find_by!(name: "Black")
white = Spree::OptionValue.find_by!(name: "White")

variants = [
  {
    product: solidus_tshirt,
    option_values: [small, blue],
    sku: "SOL-00003",
    cost_price: 17
  },
  {
    product: solidus_tshirt,
    option_values: [small, black],
    sku: "SOL-00002",
    cost_price: 17
  },
  {
    product: solidus_tshirt,
    option_values: [small, white],
    sku: "SOL-00004",
    cost_price: 17
  },
  {
    product: solidus_tshirt,
    option_values: [medium, blue],
    sku: "SOL-00005",
    cost_price: 17
  },
  {
    product: solidus_tshirt,
    option_values: [large, white],
    sku: "SOL-00006",
    cost_price: 17
  },
  {
    product: solidus_tshirt,
    option_values: [large, black],
    sku: "SOL-00007",
    cost_price: 17
  },
  {
    product: solidus_tshirt,
    option_values: [extra_large, blue],
    sku: "SOL-0008",
    cost_price: 17
  },
  {
    product: solidus_long,
    option_values: [small, black],
    sku: "SOL-LS02",
    cost_price: 17
  },
  {
    product: solidus_long,
    option_values: [small, white],
    sku: "SOL-LS01",
    cost_price: 17
  },
  {
    product: solidus_long,
    option_values: [small, blue],
    sku: "SOL-LS03",
    cost_price: 17
  },
  {
    product: solidus_long,
    option_values: [medium, white],
    sku: "SOL-LS04",
    cost_price: 17
  },
  {
    product: solidus_long,
    option_values: [medium, black],
    sku: "SOL-LS05",
    cost_price: 17
  },
  {
    product: solidus_long,
    option_values: [medium, blue],
    sku: "SOL-LS06",
    cost_price: 17
  },
  {
    product: solidus_long,
    option_values: [large, white],
    sku: "SOL-LS07",
    cost_price: 17
  },
  {
    product: solidus_long,
    option_values: [large, black],
    sku: "SOL-LS08",
    cost_price: 17
  },
  {
    product: solidus_long,
    option_values: [large, blue],
    sku: "SOL-LS09",
    cost_price: 17
  },
  {
    product: solidus_womens_tshirt,
    option_values: [small, black],
    sku: "SOL-WM001",
    cost_price: 17
  },
  {
    product: solidus_womens_tshirt,
    option_values: [small, blue],
    sku: "SOL-WM002",
    cost_price: 17
  },
  {
    product: solidus_womens_tshirt,
    option_values: [small, white],
    sku: "SOL-WM003",
    cost_price: 17
  },
  {
    product: solidus_womens_tshirt,
    option_values: [medium, blue],
    sku: "SOL-WM004",
    cost_price: 17
  },
  {
    product: solidus_womens_tshirt,
    option_values: [medium, white],
    sku: "SOL-WM005",
    cost_price: 17
  },
  {
    product: solidus_womens_tshirt,
    option_values: [medium, black],
    sku: "SOL-WM006",
    cost_price: 17
  },
  {
    product: solidus_snapback_cap,
    option_values: [small],
    sku: "SOL-SNC02",
    cost_price: 17
  },
  {
    product: solidus_snapback_cap,
    option_values: [medium],
    sku: "SOL-SNC03",
    cost_price: 17
  },
  {
    product: solidus_snapback_cap,
    option_values: [large],
    sku: "SOL-SNC04",
    cost_price: 17
  },
  {
    product: solidus_hoodie,
    option_values: [small],
    sku: "SOL-HD02",
    cost_price: 27
  },
  {
    product: solidus_hoodie,
    option_values: [medium],
    sku: "SOL-HD03",
    cost_price: 27
  },
  {
    product: solidus_hoodie,
    option_values: [large],
    sku: "SOL-HD04",
    cost_price: 27
  },
  {
    product: ruby_hoodie,
    option_values: [small],
    sku: "RUB-HD02",
    cost_price: 27
  },
  {
    product: ruby_hoodie,
    option_values: [medium],
    sku: "RUB-HD03",
    cost_price: 27
  },
  {
    product: ruby_hoodie,
    option_values: [large],
    sku: "RUB-HD04",
    cost_price: 27
  },
  {
    product: ruby_hoodie_zip,
    option_values: [small],
    sku: "RUB-HD05",
    cost_price: 27
  },
  {
    product: ruby_hoodie_zip,
    option_values: [medium],
    sku: "RUB-HD06",
    cost_price: 27
  },
  {
    product: ruby_hoodie_zip,
    option_values: [large],
    sku: "RUB-HD07",
    cost_price: 27
  },
  {
    product: ruby_polo,
    option_values: [small],
    sku: "RUB-PL02",
    cost_price: 23
  },
  {
    product: ruby_polo,
    option_values: [medium],
    sku: "RUB-PL03",
    cost_price: 23
  },
  {
    product: ruby_polo,
    option_values: [large],
    sku: "RUB-PL04",
    cost_price: 23
  }
]

masters = {
  solidus_tote => {
    sku: "SOL-TOT01",
    cost_price: 17
  },
  ruby_tote => {
    sku: "RUB-TOT01",
    cost_price: 17
  },
  solidus_snapback_cap => {
    sku: "SOL-SNC01",
    cost_price: 17
  },
  solidus_tshirt => {
    sku: "SOL-00001",
    cost_price: 17
  },
  solidus_long => {
    sku: "SOL-LS00",
    cost_price: 17
  },
  solidus_hoodie => {
    sku: "SOL-HD00",
    cost_price: 27
  },
  ruby_hoodie => {
    sku: "RUB-HD01",
    cost_price: 27
  },
  ruby_hoodie_zip => {
    sku: "RUB-HD00",
    cost_price: 27
  },
  ruby_polo => {
    sku: "RUB-PL01",
    cost_price: 23
  },
  solidus_mug => {
    sku: "SOL-MG01",
    cost_price: 7
  },
  ruby_mug => {
    sku: "RUB-MG01",
    cost_price: 7
  },
  solidus_womens_tshirt => {
    sku: "SOL-WM00",
    cost_price: 17
  }
}

Spree::Variant.create!(variants)

masters.each do |product, variant_attrs|
  product.master.update!(variant_attrs)
end

