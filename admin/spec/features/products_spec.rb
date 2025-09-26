# frozen_string_literal: true

require "spec_helper"

describe "Products", type: :feature do
  before do
    allow(SolidusAdmin::Config).to receive(:enable_alpha_features?) { true }
    sign_in create(:admin_user, email: "admin@example.com")
  end

  it "lists products", :js do
    create(:product, name: "Just a product", slug: "just-a-prod", price: 19.99)

    visit "/admin/products"

    expect(page).to have_content("Just a product")
    expect(page).to have_content("$19.99")
    expect(page).to be_axe_clean

    find_row("Just a product").click

    expect(page).to have_current_path("/admin/products/just-a-prod")
    expect(page).to have_content("Manage images")
  end

  it "can delete multiple products at once", js: true do
    create(:product, name: "Just a product", price: 19.99)
    create(:product, name: "Another product", price: 29.99)

    visit "/admin/products"
    select_row("Just a product")

    accept_confirm("Are you sure you want to delete 1 product?") do
      click_button("Delete", wait: 5)
    end

    expect(page).to have_content("Products were successfully removed.", wait: 5)
    expect(page).not_to have_content("Just a product")
    expect(page).to have_content("Another product")
    expect(Spree::Product.count).to eq(1)
    expect(page).to be_axe_clean
  end

  it "can discontinue and (re)activate multiple products at once", js: true do
    create(:product, name: "Just a product", price: 19.99)
    create(:product, name: "Another product", price: 29.99)

    visit "/admin/products"
    find("main tbody tr:nth-child(2)").find("input").check

    accept_confirm("Are you sure you want to discontinue 1 product?") do
      click_button "Discontinue"
    end

    expect(page).to have_content("Products were successfully discontinued.", wait: 5)
    within("main tbody tr:nth-child(2)") {
      expect(page).to have_content("Just a product")
      expect(page).to have_content("Discontinued")
      expect(page).not_to have_content("Available")
    }
    within("main tbody tr:nth-child(1)") {
      expect(page).to have_content("Another product")
      expect(page).not_to have_content("Discontinued")
      expect(page).to have_content("Available")
    }

    find("main tbody tr:nth-child(2)").find("input").check

    accept_confirm("Are you sure you want to activate 1 product?") do
      click_button "Activate"
    end

    expect(page).to have_content("Products were successfully activated.", wait: 5)
    within("tbody") do
      expect(page).to have_content("Just a product")
      expect(page).to have_content("Another product")
      expect(page).not_to have_content("Discontinued")
      expect(page).to have_content("Available").twice
    end

    expect(page).to be_axe_clean
  end
end
