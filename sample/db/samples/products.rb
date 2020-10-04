# frozen_string_literal: true

Spree::Sample.load_sample("tax_categories")
Spree::Sample.load_sample("shipping_categories")

tax_category = Spree::TaxCategory.find_by!(name: "Default")
shipping_category = Spree::ShippingCategory.find_by!(name: "Default")

descriptions = [
  "Occaecati repellendus soluta perspiciatis ea ea voluptatum alias. Dolorem possimus sunt ipsam eos aliquam voluptates. Voluptate est nemo ullam cumque ea ut molestiae iste.",
  "Nisi dolor explicabo est fugiat alias. Asperiores sunt rerum quisquam perspiciatis quis doloremque. Autem est harum eum dolorem voluptas nihil. Nulla omnis voluptas sint cumque ad ut dignissimos reiciendis. Mollitia culpa iure libero labore nulla autem non eum.",
  "Perferendis sed voluptatem error ipsam voluptatem esse ipsa incidunt. Doloremque quos ratione quia voluptas consequatur mollitia optio. Optio sed iure aut aliquid voluptatum facilis mollitia cum. Dignissimos in saepe consequatur et consequatur dolorem blanditiis.",
  "Necessitatibus optio quod ullam itaque quis corporis occaecati. Saepe harum voluptates consectetur rerum dolorum. Corrupti officiis reprehenderit quo excepturi cumque. Soluta eos perspiciatis aut et ea nulla amet dolores. Dolores distinctio nesciunt libero voluptas molestiae consequatur aut veritatis.",
  "Soluta sed error debitis repellendus et. Voluptates unde enim qui velit. Libero earum tenetur nulla similique temporibus quod repellendus quibusdam.",
  "Recusandae animi deserunt provident dignissimos ullam harum alias et. Itaque dicta maxime consectetur ut nemo non voluptatem. Voluptatem ipsum ut culpa eaque dolores.",
]

default_attrs = {
  description: descriptions.sample,
  available_on: Time.current
}

products = [
  {
    name: "Solidus T-Shirt",
    tax_category: tax_category,
    shipping_category: shipping_category,
    price: 19.99,
    eur_price: 16,
    weight: 0.5,
    height: 20,
    width: 10,
    depth: 5
  },
  {
    name: "Solidus Long Sleeve",
    tax_category: tax_category,
    shipping_category: shipping_category,
    price: 19.99,
    eur_price: 16,
    weight: 0.5,
    height: 20,
    width: 10,
    depth: 5
  },
  {
    name: "Solidus Girly",
    tax_category: tax_category,
    shipping_category: shipping_category,
    price: 19.99,
    eur_price: 16,
    weight: 0.5,
    height: 20,
    width: 10,
    depth: 5
  },
  {
    name: "Solidus Snapback Cap",
    tax_category: tax_category,
    shipping_category: shipping_category,
    price: 15.99,
    eur_price: 14,
    weight: 0.5,
    height: 5,
    width: 5,
    depth: 5
  },
  {
    name: "Solidus Hoodie Zip",
    tax_category: tax_category,
    shipping_category: shipping_category,
    price: 29.99,
    eur_price: 27,
    weight: 1,
    height: 20,
    width: 10,
    depth: 5
  },
  {
    name: "Ruby Hoodie",
    tax_category: tax_category,
    shipping_category: shipping_category,
    price: 29.99,
    eur_price: 27,
    weight: 1,
    height: 20,
    width: 10,
    depth: 5
  },
  {
    name: "Ruby Hoodie Zip",
    tax_category: tax_category,
    shipping_category: shipping_category,
    price: 29.99,
    eur_price: 27,
    weight: 0.8,
    height: 20,
    width: 10,
    depth: 5
  },
  {
    name: "Ruby Polo",
    tax_category: tax_category,
    shipping_category: shipping_category,
    price: 26.99,
    eur_price: 23,
    weight: 0.5,
    height: 20,
    width: 10,
    depth: 5
  },
  {
    name: "Solidus Mug",
    tax_category: tax_category,
    shipping_category: shipping_category,
    price: 9.99,
    eur_price: 7,
    weight: 1,
    height: 5,
    width: 5,
    depth: 5
  },
  {
    name: "Ruby Mug",
    tax_category: tax_category,
    shipping_category: shipping_category,
    price: 9.99,
    eur_price: 7,
    weight: 1,
    height: 5,
    width: 5,
    depth: 5
  },
  {
    name: "Solidus Tote",
    tax_category: tax_category,
    shipping_category: shipping_category,
    price: 15.99,
    eur_price: 14,
    weight: 0.5,
    height: 20,
    width: 10,
    depth: 5
  },
  {
    name: "Ruby Tote",
    tax_category: tax_category,
    shipping_category: shipping_category,
    price: 15.99,
    eur_price: 14,
    weight: 0.5,
    height: 20,
    width: 10,
    depth: 5
  }
]

products.each do |product_attrs|
  eur_price = product_attrs.delete(:eur_price)
  Spree::Config[:currency] = "USD"

  product = Spree::Product.create!(default_attrs.merge(product_attrs))
  Spree::Config[:currency] = "EUR"
  product.reload
  product.price = eur_price
  product.shipping_category = shipping_category
  product.save!
end

Spree::Config[:currency] = "USD"
