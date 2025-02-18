# frozen_string_literal: true

require "spec_helper"

describe "Stock Items Management", js: true do
  stub_authorization!

  let(:admin_user) { create(:admin_user) }
  let!(:variant_1) { create(:variant, product: product1) }
  let!(:variant_2) { create(:variant, product: product2) }
  let(:product1) { create(:product, name: "Ruby Shirt") }
  let(:product2) { create(:product, name: "Solidus Shirt") }
  let!(:stock_location) { create(:stock_location_without_variant_propagation) }

  scenario "User can add a new stock locations to any variant" do
    visit spree.admin_stock_items_path
    within(".js-add-stock-item", match: :first) do
      find('[name="stock_location_id"]').select(stock_location.name)
      fill_in("count_on_hand", with: 10)
      click_on("Create")
    end
    expect(page).to have_content("Created successfully")
  end

  scenario "searching by variant" do
    visit spree.admin_stock_items_path
    fill_in "SKU or Option Value", with: "Ruby"
    click_on "Filter Results"
    expect(page).to have_content "Ruby Shirt"
    expect(page).to_not have_content "Solidus Shirt"
  end
end
