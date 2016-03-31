# encoding: utf-8
require 'spec_helper'

describe "Prices", type: :feature do
  stub_authorization!

  let(:product) { create(:product_with_option_types, price: "1.99", cost_price: "1.00", weight: "2.5", height: "3.0", width: "1.0", depth: "1.5") }
  context "listing prices" do
    let!(:variant) do
      create(:variant, product: product, price: 19.99)
    end

    it "opens the prices tab in the product view" do
      visit spree.edit_admin_product_path(id: product.slug)
      click_link("Prices")
      expect(page).to have_content("19.99")
    end
  end
end
