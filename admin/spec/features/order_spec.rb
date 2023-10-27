# frozen_string_literal: true

require 'spec_helper'

describe "Order", type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  context "in cart state" do
    it "allows managing the cart", :js do
      create(:product, name: "Just a product", slug: 'just-a-prod', price: 19.99)
      create(:product, name: "Just another product", slug: 'just-another-prod', price: 29.99)
      create(:order, number: "R123456789", total: 19.99, state: "cart")

      visit "/admin/orders/R123456789/cart"

      expect(page).to have_content("Order R123456789")

      search_field = find("[data-#{SolidusAdmin::UI::SearchPanel::Component.stimulus_id}-target='searchField']")
      search_field.set "another"

      expect(page).not_to have_content("Just a product")
      expect(page).to have_content("Just another product")

      expect(Spree::Order.last.line_items.count).to eq(0)

      find("[aria-selected]", text: "Just another product").click
      expect(page).to have_content("Variant added to cart successfully", wait: 30)

      expect(Spree::Order.last.line_items.count).to eq(1)
      expect(Spree::Order.last.line_items.last.quantity).to eq(1)

      fill_in "line_item[quantity]", with: 4
      expect(page).to have_content("Quantity updated successfully", wait: 30)

      expect(Spree::Order.last.line_items.last.quantity).to eq(4)

      accept_confirm("Are you sure?") { click_on "Delete" }
      expect(page).to have_content("Line item removed successfully", wait: 30)

      expect(Spree::Order.last.line_items.count).to eq(0)
      expect(page).to be_axe_clean
    end
  end
end
