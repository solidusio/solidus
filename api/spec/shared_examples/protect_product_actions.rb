shared_examples "modifying product actions are restricted" do
  it "cannot create a new product if not an admin" do
    post :create, product: { name: "Brand new product!" }
    assert_unauthorized!
  end

  it "cannot update a product" do
    put :update, id: product.to_param, product: { name: "I hacked your store!" }
    assert_unauthorized!
  end

  it "cannot delete a product" do
    delete :destroy, id: product.to_param
    assert_unauthorized!
  end
end
