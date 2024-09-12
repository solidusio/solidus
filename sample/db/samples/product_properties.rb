# frozen_string_literal: true

products =
  {
    "Solidus tote" =>
    {
      "Type" => "Tote",
      "Size" => %{15" x 18" x 6"},
      "Material" => "Canvas"
    },
    "Solidus canvas tote bag" =>
    {
      "Type" => "Tote",
      "Size" => %{15" x 18" x 6"},
      "Material" => "Canvas"
    },
    "Solidus cap" =>
    {
      "Type" => "Cap",
      "Size" => "One Size",
      "Material" => "100% Cotton"
    },
    "Solidus dark tee" =>
    {
      "Manufacturer" => "Jerseys",
      "Brand" => "Solidus",
      "Model" => "TL9002",
      "Shirt Type" => "Ringer T",
      "Sleeve Type" => "Short",
      "Made from" => "100% Cotton",
      "Fit" => "Loose",
      "Gender" => "Unisex"
    },
    "Solidus t-shirt" =>
    {
      "Manufacturer" => "Wilson",
      "Brand" => "Solidus",
      "Model" => "TL9002",
      "Shirt Type" => "Jersey",
      "Sleeve Type" => "Long",
      "Made from" => "100% cotton",
      "Fit" => "Loose",
      "Gender" => "Unisex"
    },
    "Solidus hoodie" =>
    {
      "Manufacturer" => "Jerseys",
      "Brand" => "Solidus",
      "Model" => "HD9001",
      "Shirt Type" => "Jersey",
      "Sleeve Type" => "Long",
      "Made from" => "100% cotton",
      "Fit" => "Loose",
      "Gender" => "Unisex"
    },
    "Solidus long sleeve tee" =>
    {
      "Manufacturer" => "Wilson",
      "Brand" => "Solidus",
      "Model" => "HD2001",
      "Shirt Type" => "Baseball",
      "Sleeve Type" => "Long",
      "Made from" => "90% Cotton, 10% Nylon",
      "Fit" => "Loose",
      "Gender" => "Unisex"
    },
    "Solidus Water Bottle" =>
    {
      "Type" => "Insulated Water Bottle",
      "Size" => %{4.5" tall, 3.25" dia.}
    }
  }

products.each do |name, properties|
  product = Spree::Product.find_by(name:)
  properties.each do |prop_name, prop_value|
    product.set_property(prop_name, prop_value)
  end
end
