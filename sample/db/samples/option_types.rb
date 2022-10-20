# frozen_string_literal: true

Spree::OptionType.create!([
  {
    name: "clothing-size",
    presentation: "Size",
    position: 1
  },
  {
    name: "clothing-color",
    presentation: "Color",
    position: 2
  }
])
