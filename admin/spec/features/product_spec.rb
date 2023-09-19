# frozen_string_literal: true

require 'spec_helper'

describe "Product", type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists products", :js do
    create(:product, name: "Just a product", slug: 'just-a-prod', price: 19.99)

    visit "/admin/products/just-a-prod"

    expect(page).to have_content("Just a product")
    expect(page).to have_content("SEO")
    expect(page).to have_content("Media")
    expect(page).to have_content("Pricing")
    expect(page).to have_content("Stock")
    expect(page).to have_content("Shipping")
    expect(page).to have_content("Options")
    expect(page).to have_content("Specifications")
    expect(page).to have_content("Publishing")
    expect(page).to have_content("Product organization")
    expect(page).to be_axe_clean
  end

  it "redirects the edit route to the show path" do
    create(:product, slug: 'just-a-prod')

    visit "/admin/products/just-a-prod/edit"

    expect(page).to have_current_path("/admin/products/just-a-prod")
  end

  it "can update a product", :js do
    create(:product, name: "Just a product", slug: 'just-a-prod', price: 19.99)

    visit "/admin/products/just-a-prod"

    fill_in "Name", with: "Just a product (updated)"
    within('header') { click_button "Save" }

    expect(page).to have_content("Just a product (updated)")
    fill_in "Name", with: ""
    within('header') { click_button "Save" }

    expect(page).to have_content("Name can't be blank")
    expect(page).to be_axe_clean
  end
end
