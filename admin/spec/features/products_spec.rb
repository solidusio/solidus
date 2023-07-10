# frozen_string_literal: true

require 'spec_helper'

describe "Products", type: :feature do
  it "lists products" do
    create(:product, name: "Just a product", price: 19.99)

    visit "/admin/products"

    expect(page).to have_content("Just a product")
    expect(page).to have_content("$19.99")
  end
end
