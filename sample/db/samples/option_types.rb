# frozen_string_literal: true

Spree::OptionType.create!([
  {
    name: "tshirt-size",
    presentation: "Size",
    position: 1
  },
  {
    name: "tshirt-color",
    presentation: "Color",
    position: 2
  }
])
