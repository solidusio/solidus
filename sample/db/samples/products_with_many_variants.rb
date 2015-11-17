Spree::Sample.load_sample("image_helpers")

tax_category = Spree::TaxCategory.find_by_name!("Default")
shipping_category = Spree::ShippingCategory.find_by_name!("Default")

color_option_type = Spree::OptionType.find_or_create_by!(name: "color", presentation: "Color")
collar_option_type = Spree::OptionType.find_or_create_by!(name: "collar", presentation: "Collar")
fit_option_type = Spree::OptionType.find_or_create_by!(name: "fit", presentation: "Fit")
neck_option_type = Spree::OptionType.find_or_create_by!(name: "neck", presentation: "Neck")
sleeve_option_type = Spree::OptionType.find_or_create_by!(name: "sleeve", presentation: "Sleeve")

option_values_by_option_type = {
  color_option_type => ["red", "orange", "yellow", "green", "blue", "indigo", "violet", "aqua", "purple", "olive"],
  collar_option_type => ['point', 'spread'],
  fit_option_type => ["regular", "slim", "tailored"],
  neck_option_type => ["14", "14.5", "15", "15.5", "16", "16.5", "17", "17.5", "18"],
  sleeve_option_type => ["32", "33", "34", "35", "36", "37", "38", "39", "40"],
}

option_values_by_option_type.each do |option_type, option_values|
  option_values.each do |ov|
    Spree::OptionValue.find_or_create_by!(name: ov, presentation: ov.titleize, option_type: option_type)
  end
end

color_option_values = Spree::OptionValue.where(option_type: color_option_type)
collar_option_values = Spree::OptionValue.where(option_type: collar_option_type)
fit_option_values = Spree::OptionValue.where(option_type: fit_option_type)
neck_option_values = Spree::OptionValue.where(option_type: neck_option_type)
sleeve_option_values = Spree::OptionValue.where(option_type: sleeve_option_type)

images = [
  image("ror_baseball_jersey_red", "png"),
  image("ror_baseball_jersey_back_red", "png"),
  image("ror_baseball_jersey_green", "png"),
  image("ror_baseball_jersey_back_green", "png"),
  image("ror_baseball_jersey_blue", "png"),
  image("ror_baseball_jersey_back_blue", "png")
]

10.times do |product_number|
  puts "Creating product #{product_number}"
  product = Spree::Product.create!(
    price: 55,
    name: "Performance Shirt - #{product_number}",
    description: Faker::Lorem.paragraph,
    available_on: Time.zone.now,
    tax_category: tax_category,
    shipping_category: shipping_category
  )

  color_option_values.each do |color_ov|
    collar_option_values.each do |collar_ov|
      fit_option_values.each do |fit_ov|
        neck_option_values.each do |neck_ov|
          sleeve_option_values.each do |sleeve_ov|
            Spree::Variant.create!(
              product: product,
              track_inventory: false,
              option_values: [color_ov, collar_ov, fit_ov, neck_ov, sleeve_ov]
            )
          end
        end
      end
    end
  end

  # Create variant image rules - 6 images for each color
  color_option_values.each do |color_ov|
    image_rule = product.variant_image_rules.build
    image_rule.conditions.build(option_value: color_ov)
    images.each do |image|
      image_rule_value = image_rule.values.build
      image_rule_value.image_attachment = image
    end
    image_rule.save!
  end
end

