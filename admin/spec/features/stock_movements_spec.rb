# frozen_string_literal: true

require "spec_helper"

describe "Stock Movements", :js, type: :feature do
  let(:admin) { create(:admin_user, email: "admin@example.com") }
  let(:stock_location) { create(:stock_location, name: "Warehouse", propagate_all_variants: false) }
  let(:shirt) { create(:variant, sku: "SHIRT-1", product: create(:product, name: "Shirt")) }
  let(:mug) { create(:variant, sku: "MUG-1", product: create(:product, name: "Mug")) }

  before do
    sign_in admin

    shirt_item = create(:stock_item, stock_location:, variant: shirt)
    mug_item = create(:stock_item, stock_location:, variant: mug)
    create(:stock_movement, stock_item: shirt_item, quantity: 7, originator: admin)
    create(:stock_movement, stock_item: mug_item, quantity: -3)
  end

  it "lists the stock movements of a stock location" do
    visit "/admin/stock_locations"
    click_on "2 stock movements"

    expect(page).to have_current_path("/admin/stock_locations/#{stock_location.id}/stock_movements")
    expect(page).to have_title("Stock Movements")
    expect(page).to have_content("Stock Movements for Warehouse")
    expect(find("tr", text: "SHIRT-1")).to have_content("7")
    expect(find("tr", text: "SHIRT-1")).to have_content("admin@example.com")
    expect(find("tr", text: "MUG-1")).to have_content("-3")
    expect(page).to be_axe_clean
  end

  it "does not list movements from other stock locations" do
    other_item = create(:stock_item, variant: create(:variant, sku: "OTHER-1"))
    create(:stock_movement, stock_item: other_item, quantity: 1)

    visit "/admin/stock_locations/#{stock_location.id}/stock_movements"

    expect(page).to have_content("SHIRT-1")
    expect(page).not_to have_content("OTHER-1")
  end

  it "allows searching by variant SKU" do
    visit "/admin/stock_locations/#{stock_location.id}/stock_movements"

    fill_in "Search all Stock Movements", with: "MUG"

    expect(page).to have_content("MUG-1")
    expect(page).not_to have_content("SHIRT-1")
  end

  it "is linked from the stock items page, filtered by variant" do
    visit "/admin/stock_items"
    within("tr", text: "SHIRT-1") { click_on "1 stock movement" }

    expect(page).to have_content("Stock Movements for Warehouse")
    expect(page).to have_content("SHIRT-1")
    expect(page).not_to have_content("MUG-1")
  end
end
