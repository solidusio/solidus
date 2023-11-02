# frozen_string_literal: true

Spree::Sample.load_sample("products")

size = Spree::OptionType.find_by!(presentation: "Size")
color = Spree::OptionType.find_by!(presentation: "Color")

colored_clothes = [
  "Solidus T-Shirt", "Solidus Long Sleeve", "Solidus Women's T-Shirt"
]

Spree::Product.all.find_each do |product|
  product.option_types = [size]
  product.option_types << color if colored_clothes.include?(product.name)
  product.save!
end
