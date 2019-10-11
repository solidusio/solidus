# frozen_string_literal: true

Solidus::Sample.load_sample("option_values")
Solidus::Sample.load_sample("products")

solidus_tshirt = Solidus::Product.find_by!(name: "Solidus T-Shirt")
solidus_long = Solidus::Product.find_by!(name: "Solidus Long Sleeve")
solidus_snapback_cap = Solidus::Product.find_by!(name: "Solidus Snapback Cap")
solidus_hoodie = Solidus::Product.find_by!(name: "Solidus Hoodie Zip")
ruby_hoodie = Solidus::Product.find_by!(name: "Ruby Hoodie")
ruby_hoodie_zip = Solidus::Product.find_by!(name: "Ruby Hoodie Zip")
ruby_polo = Solidus::Product.find_by!(name: "Ruby Polo")
solidus_mug = Solidus::Product.find_by!(name: "Solidus Mug")
ruby_mug = Solidus::Product.find_by!(name: "Ruby Mug")
solidus_tote = Solidus::Product.find_by!(name: "Solidus Tote")
ruby_tote = Solidus::Product.find_by!(name: "Ruby Tote")
solidus_girly = Solidus::Product.find_by!(name: "Solidus Girly")

small = Solidus::OptionValue.find_by!(name: "Small")
medium = Solidus::OptionValue.find_by!(name: "Medium")
large = Solidus::OptionValue.find_by!(name: "Large")
extra_large = Solidus::OptionValue.find_by!(name: "Extra Large")

red = Solidus::OptionValue.find_by!(name: "Red")
blue = Solidus::OptionValue.find_by!(name: "Blue")
green = Solidus::OptionValue.find_by!(name: "Green")
black = Solidus::OptionValue.find_by!(name: "Black")
white = Solidus::OptionValue.find_by!(name: "White")

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
    product: solidus_girly,
    option_values: [small, black],
    sku: "SOL-WM001",
    cost_price: 17
  },
  {
    product: solidus_girly,
    option_values: [small, blue],
    sku: "SOL-WM002",
    cost_price: 17
  },
  {
    product: solidus_girly,
    option_values: [small, white],
    sku: "SOL-WM003",
    cost_price: 17
  },
  {
    product: solidus_girly,
    option_values: [medium, blue],
    sku: "SOL-WM004",
    cost_price: 17
  },
  {
    product: solidus_girly,
    option_values: [medium, white],
    sku: "SOL-WM005",
    cost_price: 17
  },
  {
    product: solidus_girly,
    option_values: [medium, black],
    sku: "SOL-WM006",
    cost_price: 17
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
  solidus_girly => {
    sku: "SOL-WM00",
    cost_price: 17
  }
}

Solidus::Variant.create!(variants)

masters.each do |product, variant_attrs|
  product.master.update!(variant_attrs)
end
