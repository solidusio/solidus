# frozen_string_literal: true

require 'spec_helper'

describe "Product", type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists products", :js do
    product = create(:product, name: "Just a product", slug: 'just-a-prod', price: 19.99)

    visit "/admin/products/just-a-prod"

    expect(page).to be_axe_clean
  end
end
