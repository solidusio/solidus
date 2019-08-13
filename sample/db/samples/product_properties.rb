# frozen_string_literal: true

products =
  {
    "Solidus Tote" =>
    {
      "Type" => "Tote",
      "Size" => %{15" x 18" x 6"},
      "Material" => "Canvas"
    },
    "Ruby Tote" =>
    {
      "Type" => "Tote",
      "Size" => %{15" x 18" x 6"},
      "Material" => "Canvas"
    },
    "Solidus Snapback Cap" =>
    {
      "Type" => "Snapback Cap",
      "Size" => "One Size",
      "Material" => "100% Cotton"
    },
    "Solidus T-Shirt" =>
    {
      "Manufacturer" => "Jerseys",
      "Brand" => "Conditioned",
      "Model" => "TL9002",
      "Shirt Type" => "Ringer T",
      "Sleeve Type" => "Short",
      "Made from" => "100% Cotton",
      "Fit" => "Loose",
      "Gender" => "Men's"
    },
    "Solidus Long Sleeve" =>
    {
      "Manufacturer" => "Wilson",
      "Brand" => "Wannabe Sports",
      "Model" => "TL9002",
      "Shirt Type" => "Jersey",
      "Sleeve Type" => "Long",
      "Made from" => "100% cotton",
      "Fit" => "Loose",
      "Gender" => "Men's"
    },
    "Solidus Hoodie Zip" =>
    {
      "Manufacturer" => "Jerseys",
      "Brand" => "Wannabe Sports",
      "Model" => "HD9001",
      "Shirt Type" => "Jersey",
      "Sleeve Type" => "Long",
      "Made from" => "100% cotton",
      "Fit" => "Loose",
      "Gender" => "Unisex"
    },
    "Ruby Hoodie" =>
    {
      "Manufacturer" => "Wilson",
      "Brand" => "Resiliance",
      "Model" => "HD2001",
      "Shirt Type" => "Baseball",
      "Sleeve Type" => "Long",
      "Made from" => "90% Cotton, 10% Nylon",
      "Fit" => "Loose",
      "Gender" => "Unisex"
    },
    "Ruby Hoodie Zip" =>
    {
      "Manufacturer" => "Jerseys",
      "Brand" => "Wannabe Sports",
      "Model" => "HD9001",
      "Shirt Type" => "Jersey",
      "Sleeve Type" => "Long",
      "Made from" => "100% cotton",
      "Fit" => "Loose",
      "Gender" => "Unisex"
    },
    "Ruby Polo" =>
    {
      "Manufacturer" => "Wilson",
      "Brand" => "Resiliance",
      "Model" => "PL9001",
      "Shirt Type" => "Ringer T",
      "Sleeve Type" => "Short",
      "Made from" => "100% Cotton",
      "Fit" => "Slim",
      "Gender" => "Men's"
    },
    "Solidus Mug" =>
    {
      "Type" => "Mug",
      "Size" => %{4.5" tall, 3.25" dia.}
    },
    "Ruby Mug" =>
    {
      "Type" => "Mug",
      "Size" => %{4.5" tall, 3.25" dia.}
    },
    "Solidus Girly" =>
    {
      "Manufacturer" => "Jerseys",
      "Brand" => "Conditioned",
      "Model" => "WM6001",
      "Shirt Type" => "Skinny",
      "Sleeve Type" => "Short",
      "Made from" => "90% Cotton, 10% Nylon",
      "Fit" => "Slim",
      "Gender" => "Women's"
    }
  }

products.each do |name, properties|
  product = Spree::Product.find_by(name: name)
  properties.each do |prop_name, prop_value|
    product.set_property(prop_name, prop_value)
  end
end
