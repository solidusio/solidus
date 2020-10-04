# frozen_string_literal: true

shared_examples "modifying product actions are restricted" do
  it "cannot create a new product if not an admin" do
    post spree.api_products_path, params: { product: { name: "Brand new product!" } }
    assert_unauthorized!
  end

  it "cannot update a product" do
    put spree.api_product_path(product), params: { product: { name: "I hacked your store!" } }
    assert_unauthorized!
  end

  it "cannot delete a product" do
    delete spree.api_product_path(product)
    assert_unauthorized!
  end
end
