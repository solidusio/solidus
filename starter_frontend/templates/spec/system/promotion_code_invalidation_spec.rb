# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Promotion Code Invalidation', type: :system, js: true do
  let!(:promotion) do
    FactoryBot.create(
      :promotion_with_item_adjustment,
      code: "PROMO",
      per_code_usage_limit: 1,
      adjustment_rate: 5
    )
  end

  before do
    create(:store)
    FactoryBot.create(:product_in_stock, name: "DL-44")
    FactoryBot.create(:product_in_stock, name: "E-11")

    visit products_path
    click_link "DL-44"
    expect(page).to have_content("As seen on TV!")
    click_button "Add To Cart"
    expect(page).to have_content("Shopping Cart")

    visit products_path
    click_link "E-11"
    expect(page).to have_content("As seen on TV!")
    click_button "Add To Cart"
  end

  it 'adding the promotion to a cart with two applicable items' do
    fill_in "Coupon code", with: "PROMO"
    click_button "Apply Code"

    expect(page).to have_content("The coupon code was successfully applied to your order")

    within("#cart_adjustments") do
      expect(page).to have_content("-$10.00")
    end

    # Remove an item

    fill_in "order_line_items_attributes_0_quantity", with: 0
    click_button "Update"
    within("#cart_adjustments") do
      expect(page).to have_content("-$5.00")
    end

    # Add it back
    visit products_path
    click_link "DL-44"
    click_button "Add To Cart"
    within("#cart_adjustments") do
      expect(page).to have_content("-$10.00")
    end
  end
end
