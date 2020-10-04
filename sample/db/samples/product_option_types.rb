# frozen_string_literal: true

Spree::Sample.load_sample("products")

size = Spree::OptionType.find_by!(presentation: "Size")
color = Spree::OptionType.find_by!(presentation: "Color")

solidus_tshirt = Spree::Product.find_by!(name: "Solidus T-Shirt")
solidus_tshirt.option_types = [size, color]
solidus_tshirt.save!
