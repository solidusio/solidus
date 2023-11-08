# frozen_string_literal: true

require 'spec_helper'

describe "Order", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "allows detaching a customer from an order" do
    order = create(:order, number: "R123456789", user: create(:user))

    visit "/admin/orders/R123456789"

    open_customer_menu
    click_on "Remove customer"

    expect(page).to have_content("Customer was removed successfully")
    open_customer_menu
    expect(page).not_to have_content("Remove customer")
    expect(order.reload.user).to be_nil
  end

  it "allows changing the order email" do
    create(:order, number: "R123456789", total: 19.99)

    visit "/admin/orders/R123456789/edit"

    expect(page).to have_content("Order R123456789")
    open_customer_menu
    click_on "Edit order email"
    within("dialog") do
      fill_in "Customer Email", with: "a@b.c"
      click_on "Save"
    end
    expect(page).to have_content("Order was updated successfully")
    expect(page).to have_content("Order contact email a@b.c", normalize_ws: true)
  end

  context "in cart state" do
    it "allows managing the cart" do
      create(:product, name: "Just a product", slug: 'just-a-prod', price: 19.99)
      create(:product, name: "Just another product", slug: 'just-another-prod', price: 29.99)
      create(:order, number: "R123456789", total: 19.99, state: "cart")

      visit "/admin/orders/R123456789/edit"
      expect(page).to have_current_path("/admin/orders/R123456789")

      expect(page).to have_content("Order R123456789")

      search_field = find("[data-#{SolidusAdmin::UI::Forms::Search::Component.stimulus_id}-target='searchField']")
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

  private

  def open_customer_menu
    find("summary", text: "Customer").click
  end
end
