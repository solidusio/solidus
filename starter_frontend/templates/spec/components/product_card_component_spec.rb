# frozen_string_literal: true

require "solidus_starter_frontend_spec_helper"

RSpec.describe ProductCardComponent, type: :component do
  include FactoryBot::Syntax::Methods

  it "renders the product with its main image and price" do
    product = build(:product, name: "The best product", id: 123)
    price = build(:price)
    rendered_component = render_inline(described_class.new(product, price: price))

    aggregate_failures do
      expect(rendered_component.css("li .product-card_header a").to_html).to include("The best product")
      expect(rendered_component.css("li .product-card_header a").first[:href]).to eq('/products/123')
      expect(rendered_component.css("li .product-card_image a").first[:href]).to eq('/products/123')
    end
  end
end
