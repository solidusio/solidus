# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Cart', type: :system do
  include_context 'featured products'

  before { create(:store) }

  it "shows cart icon on non-cart pages" do
    visit root_path
    expect(page).to have_selector("#link-to-cart a", visible: true)
  end

  it "prevents double clicking the remove button on cart", js: true do
    @product = create(:product, name: "Solidus mug set")

    visit products_path
    click_link "Solidus mug set"
    click_button "add-to-cart-button"

    # prevent form submit to verify button is disabled
    page.execute_script("document.getElementById('update-cart').onsubmit = function(){return false;}")

    expect(page).not_to have_selector('button#update-button[disabled]')
    click_button 'Remove'
    expect(page).to have_selector('button#update-button[disabled]')
  end

  it 'allows you to remove an item from the cart', js: true do
    create(:product, name: "Solidus mug set")
    visit products_path
    click_link "Solidus mug set"
    click_button "add-to-cart-button"
    click_button "Remove"
    expect(page).not_to have_content("Line items quantity must be an integer")
    expect(page).not_to have_content("Solidus mug set")
    expect(page).to have_content("Your cart is empty")

    within "#link-to-cart" do
      expect(page.text).to eq('')
    end
  end

  skip 'allows you to empty the cart', js: true do
    create(:product, name: "Solidus mug set")
    visit products_path
    click_link "Solidus mug set"
    click_button "add-to-cart-button"

    expect(page).to have_content("Solidus mug set")
    click_on "Empty Cart"
    expect(page).to have_content("Your cart is empty")

    within "#link-to-cart" do
      expect(page.text).to eq('')
    end
  end

  # regression for https://github.com/spree/spree/issues/2276
  context "product contains variants but no option values" do
    let(:variant) { create(:variant) }
    let(:product) { variant.product }

    before { variant.option_values.destroy_all }

    it "still adds product to cart" do
      visit product_path(product)
      click_button "add-to-cart-button"

      visit cart_path
      expect(page).to have_content(product.name)
    end
  end
end
