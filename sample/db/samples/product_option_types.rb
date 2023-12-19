# frozen_string_literal: true

Spree::Sample.load_sample("products")

size = Spree::OptionType.find_by!(presentation: "Size")
color = Spree::OptionType.find_by!(presentation: "Color")

solidus_cap = Spree::Product.find_by!(name: "Solidus cap")

solidus_cap.option_types = [size, color]
solidus_cap.save!

solidus_hoodie = Spree::Product.find_by!(name: "Solidus hoodie")

solidus_hoodie.option_types = [size, color]
solidus_hoodie.save!
