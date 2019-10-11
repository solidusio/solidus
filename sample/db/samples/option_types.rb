# frozen_string_literal: true

Solidus::OptionType.create!([
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
