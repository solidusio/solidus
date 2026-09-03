# frozen_string_literal: true

[
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
].each do |attrs|
  Spree::OptionType.find_or_create_by!(name: attrs[:name]) do |option_type|
    option_type.assign_attributes(attrs)
  end
end
