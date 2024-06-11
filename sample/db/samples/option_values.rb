# frozen_string_literal: true

Spree::Sample.load_sample("option_types")

size = Spree::OptionType.find_by!(presentation: "Size")
color = Spree::OptionType.find_by!(presentation: "Color")

Spree::OptionValue.create!([
  {
    name: "Small",
    presentation: "S",
    position: 1,
    option_type: size
  },
  {
    name: "Medium",
    presentation: "M",
    position: 2,
    option_type: size
  },
  {
    name: "Large",
    presentation: "L",
    position: 3,
    option_type: size
  },
  {
    name: "Extra Large",
    presentation: "XL",
    position: 4,
    option_type: size
  },
  {
    name: "Black",
    presentation: "Black",
    position: 1,
    option_type: color
  },
  {
    name: "Gray",
    presentation: "Gray",
    position: 2,
    option_type: color
  },
  {
    name: "Blue",
    presentation: "Blue",
    position: 3,
    option_type: color
  },
  {
    name: "Red",
    presentation: "Red",
    position: 4,
    option_type: color
  },
])
