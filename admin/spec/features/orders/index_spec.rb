# frozen_string_literal: true

require 'spec_helper'

describe "Orders", type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists products", :js do
    create(:order, number: "R123456789", total: 19.99)

    visit "/admin/orders"
    click_on "In Progress"

    expect(page).to have_content("R123456789")
    expect(page).to have_content("$19.99")
    expect(page).to be_axe_clean
  end

  it "Filters product list", :js do
    create(:completed_order_with_pending_payment, number: "R123456789", total: 19.99)
    create(:order_ready_to_ship, number: "R987654321", total: 29.99)

    visit "/admin/orders"

    ensure_js_is_ready

    click_button "Filter"

    within("div[role=search]") do
      expect(page).to have_content("Payment State")
      find(:xpath, "//summary[normalize-space(text())='Payment State']").click
    end
    check "Balance Due"
    expect(page).to have_content("R123456789")
    expect(page).not_to have_content("R987654321")

    # TODO: Fix colors of the orange pills. They don't have enough contrast.
    # expect(page).to be_axe_clean
  end
end
