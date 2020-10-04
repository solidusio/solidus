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
    name: "Red",
    presentation: "Red",
    position: 5,
    option_type: color
  },
  {
    name: "Green",
    presentation: "Green",
    position: 4,
    option_type: color
  },
  {
    name: "Black",
    presentation: "Black",
    position: 1,
    option_type: color
  },
  {
    name: "White",
    presentation: "White",
    position: 2,
    option_type: color
  },
  {
    name: "Blue",
    presentation: "Blue",
    position: 3,
    option_type: color
  }
])
