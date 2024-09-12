# frozen_string_literal: true

Spree::Sample.load_sample("products")

size = Spree::OptionType.find_by!(presentation: "Size")
color = Spree::OptionType.find_by!(presentation: "Color")

products_with_variants = [
  "Solidus cap",
  "Solidus hoodie",
  "Solidus t-shirt",
  "Solidus mug set",
  "Solidus tote",
  "Solidus Water Bottle"
]

products_with_variants.each do |name|
  product = Spree::Product.find_by!(name:)
  product.option_types = [size, color]
  product.save!
end
