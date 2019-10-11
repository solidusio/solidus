# frozen_string_literal: true

Solidus::Sample.load_sample("products")

size = Solidus::OptionType.find_by!(presentation: "Size")
color = Solidus::OptionType.find_by!(presentation: "Color")

solidus_tshirt = Solidus::Product.find_by!(name: "Solidus T-Shirt")
solidus_tshirt.option_types = [size, color]
solidus_tshirt.save!
