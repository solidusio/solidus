# frozen_string_literal: true

Spree::Sample.load_sample("option_values")
Spree::Sample.load_sample("products")

solidus_bottles = Spree::Product.find_by!(name: "Solidus Water Bottle")
solidus_tote = Spree::Product.find_by!(name: "Solidus tote")
solidus_hoodie = Spree::Product.find_by!(name: "Solidus hoodie")
solidus_mug_set = Spree::Product.find_by!(name: "Solidus mug set")
solidus_hat = Spree::Product.find_by!(name: "Solidus winter hat")
solidus_sticker = Spree::Product.find_by!(name: "Solidus circle sticker")
solidus_notebook = Spree::Product.find_by!(name: "Solidus notebook")
solidus_tshirt = Spree::Product.find_by!(name: "Solidus t-shirt")
solidus_long_sleeve_tee = Spree::Product.find_by!(name: "Solidus long sleeve tee")
solidus_dark_tee = Spree::Product.find_by!(name: "Solidus dark tee")
solidus_canvas_tote = Spree::Product.find_by!(name: "Solidus canvas tote bag")
solidus_cap = Spree::Product.find_by!(name: "Solidus cap")

small = Spree::OptionValue.find_by!(name: "Small")
medium = Spree::OptionValue.find_by!(name: "Medium")
large = Spree::OptionValue.find_by!(name: "Large")
extra_large = Spree::OptionValue.find_by!(name: "Extra Large")

blue = Spree::OptionValue.find_by!(name: "Blue")
black = Spree::OptionValue.find_by!(name: "Black")
gray = Spree::OptionValue.find_by!(name: "Gray")
red = Spree::OptionValue.find_by!(name: "Red")

variants = [
  {
    product: solidus_hoodie,
    option_values: [small, black],
    sku: "SOL-HOODIE-04",
    cost_price: 17
  },
  {
    product: solidus_hoodie,
    option_values: [medium, black],
    sku: "SOL-HOODIE-05",
    cost_price: 17
  },
  {
    product: solidus_hoodie,
    option_values: [large, black],
    sku: "SOL-HOODIE-07",
    cost_price: 17
  },
  {
    product: solidus_hoodie,
    option_values: [extra_large, black],
    sku: "SOL-HOODIE-06",
    cost_price: 17
  },
  {
    product: solidus_hoodie,
    option_values: [small, red],
    sku: "SOL-HOODIE-01",
    cost_price: 17
  },
  {
    product: solidus_hoodie,
    option_values: [medium, red],
    sku: "SOL-HOODIE-02",
    cost_price: 17
  },
  {
    product: solidus_hoodie,
    option_values: [large, red],
    sku: "SOL-HOODIE-08",
    cost_price: 17
  },
  {
    product: solidus_hoodie,
    option_values: [extra_large, red],
    sku: "SOL-HOODIE-03",
    cost_price: 17
  },
  {
    product: solidus_tshirt,
    option_values: [medium, black],
    sku: "SOL-TEE-01",
    cost_price: 8.9
  },
  {
    product: solidus_tshirt,
    option_values: [large, black],
    sku: "SOL-TEE-02",
    cost_price: 9.9
  },
  {
    product: solidus_tshirt,
    option_values: [extra_large, black],
    sku: "SOL-TEE-03",
    cost_price: 11.9
  },
  {
    product: solidus_tote,
    option_values: [small, red],
    sku: "SOL-0000",
    cost_price: 17
  },
  {
    product: solidus_tote,
    option_values: [large, red],
    sku: "SOL-0001",
    cost_price: 17
  },
  {
    product: solidus_tote,
    option_values: [extra_large, red],
    sku: "SOL-0002",
    cost_price: 17
  },
  {
    product: solidus_bottles,
    option_values: [small, gray],
    sku: "SOL-0011",
    cost_price: 17
  },
  {
    product: solidus_bottles,
    option_values: [medium, gray],
    sku: "SOL-0012",
    cost_price: 17
  },
  {
    product: solidus_bottles,
    option_values: [large, gray],
    sku: "SOL-0013",
    cost_price: 17
  },
  {
    product: solidus_bottles,
    option_values: [extra_large, gray],
    sku: "SOL-0014",
    cost_price: 17
  },
  {
    product: solidus_cap,
    option_values: [small, black],
    sku: "SOL-HD001",
    cost_price: 27
  },
  {
    product: solidus_cap,
    option_values: [small, gray],
    sku: "SOL-HD002",
    cost_price: 27
  },
  {
    product: solidus_cap,
    option_values: [medium, black],
    sku: "SOL-HD003",
    cost_price: 27
  },
  {
    product: solidus_cap,
    option_values: [medium, gray],
    sku: "SOL-HD004",
    cost_price: 27
  },
  {
    product: solidus_cap,
    option_values: [large, black],
    sku: "SOL-HD005",
    cost_price: 27
  },
  {
    product: solidus_cap,
    option_values: [extra_large, black],
    sku: "SOL-HD045",
    cost_price: 27
  },
  {
    product: solidus_cap,
    option_values: [large, gray],
    sku: "SOL-HD006",
    cost_price: 27
  },
  {
    product: solidus_cap,
    option_values: [small, red],
    sku: "SOL-HD007",
    cost_price: 27
  },
  {
    product: solidus_cap,
    option_values: [medium, red],
    sku: "SOL-HD008",
    cost_price: 27
  },
  {
    product: solidus_cap,
    option_values: [large, red],
    sku: "SOL-HD009",
    cost_price: 27
  },
  {
    product: solidus_cap,
    option_values: [extra_large, red],
    sku: "SOL-HD010",
    cost_price: 27
  },
  {
    product: solidus_mug_set,
    option_values: [small, gray],
    sku: "SOL-HD011",
    cost_price: 27
  },
  {
    product: solidus_mug_set,
    option_values: [medium, gray],
    sku: "SOL-HD012",
    cost_price: 27
  },
  {
    product: solidus_mug_set,
    option_values: [extra_large, gray],
    sku: "SOL-HD013",
    cost_price: 27
  },
  {
    product: solidus_mug_set,
    option_values: [small, black],
    sku: "SOL-HD014",
    cost_price: 27
  },
  {
    product: solidus_mug_set,
    option_values: [medium, black],
    sku: "SOL-HD015",
    cost_price: 27
  },
  {
    product: solidus_mug_set,
    option_values: [large, black],
    sku: "SOL-HD016",
    cost_price: 27
  },
  {
    product: solidus_mug_set,
    option_values: [extra_large, black],
    sku: "SOL-HD017",
    cost_price: 27
  },
  {
    product: solidus_mug_set,
    option_values: [large, blue],
    sku: "SOL-HD018",
    cost_price: 27
  },
  {
    product: solidus_mug_set,
    option_values: [medium, blue],
    sku: "SOL-HD019",
    cost_price: 27
  },
  {
    product: solidus_mug_set,
    option_values: [extra_large, blue],
    sku: "SOL-HD020",
    cost_price: 27
  }
]

masters = {
  solidus_hoodie => {
    sku: "SOL-HOODIE-00",
    cost_price: 17
  },
  solidus_bottles => {
    sku: "SOL-00001",
    cost_price: 17
  },
  solidus_tote => {
    sku: "SOL-LG001",
    cost_price: 17
  },
  solidus_mug_set => {
    sku: "SOL-LGH01",
    cost_price: 27
  },
  solidus_hat => {
    sku: "SOL-MNH01",
    cost_price: 27
  },
  solidus_sticker => {
    sku: "RUB-HDH01",
    cost_price: 27
  },
  solidus_tote => {
    sku: "SOL-TOT01",
    cost_price: 17
  },
  solidus_tote => {
    sku: "RUB-TOT01",
    cost_price: 17
  },
  solidus_notebook => {
    sku: "SOL-SNC01",
    cost_price: 17
  },
  solidus_tshirt => {
    sku: "RUB-SNC02",
    cost_price: 17
  },
  solidus_long_sleeve_tee => {
    sku: "SOL-MG01",
    cost_price: 7
  },
  solidus_dark_tee => {
    sku: "RUB-MG01",
    cost_price: 7
  },
  solidus_canvas_tote => {
    sku: "SOL-TTE99",
    cost_price: 19
  },
  solidus_cap => {
    sku: "SOL-CAP99",
    cost_price: 24
  }
}

Spree::Variant.create!(variants)

masters.each do |product, variant_attrs|
  product.master.update!(variant_attrs)
end
