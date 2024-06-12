# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Orders", type: :feature, solidus_admin: true do
  let(:promotion) { create(:promotion, name: "10OFF") }
  let!(:order_with_promotion) { create(:completed_order_with_promotion, number: "R123456789", promotion: promotion) }
  let!(:order_without_promotion) { create(:completed_order_with_totals, number: "R987654321") }

  before { sign_in create(:admin_user, email: "admin@example.com") }

  it "lists products", :js do
    visit "/admin/orders"

    sleep 1

    click_button "Filter"

    within("div[role=search]") do
      expect(page).to have_content("Promotions")
      find(:xpath, "//summary[normalize-space(text())='Promotions']").click
    end
    check "10OFF"
    expect(page).to have_content("R123456789")
    expect(page).not_to have_content("R987654321")
    expect(page).to be_axe_clean
  end
end
