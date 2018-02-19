# frozen_string_literal: true

Spree::Sample.load_sample("products")

size = Spree::OptionType.find_by!(presentation: "Size")
color = Spree::OptionType.find_by!(presentation: "Color")

ror_baseball_jersey = Spree::Product.find_by!(name: "Ruby on Rails Baseball Jersey")
ror_baseball_jersey.option_types = [size, color]
ror_baseball_jersey.save!
