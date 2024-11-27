# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Promotions", :js, type: :feature, solidus_admin: true do
  before { sign_in create(:admin_user, email: "admin@example.com") }

  it "lists promotions and allows deleting them" do
    create(:solidus_promotion, :with_adjustable_benefit, name: "My active Promotion")
    create(:solidus_promotion, name: "My draft Promotion")
    create(:solidus_promotion, :with_adjustable_benefit, name: "My expired Promotion", expires_at: 1.day.ago)
    create(:solidus_promotion, :with_adjustable_benefit, name: "My future Promotion", starts_at: 1.day.from_now)

    visit "/admin/solidus/promotions"
    expect(page).to have_content("My active Promotion")
    click_on "Draft"
    expect(page).to have_content("My draft Promotion", wait: 30)
    click_on "Future"
    expect(page).to have_content("My future Promotion", wait: 30)
    click_on "Expired"
    expect(page).to have_content("My expired Promotion", wait: 30)
    click_on "All"
    expect(page).to have_content("My active Promotion", wait: 30)
    expect(page).to have_content("My draft Promotion")
    expect(page).to have_content("My future Promotion")
    expect(page).to have_content("My expired Promotion")

    expect(page).to be_axe_clean

    select_row("My active Promotion")
    click_on "Delete"
    expect(page).to have_content("Promotions were successfully removed.")
    expect(page).not_to have_content("My active Promotion")
    expect(SolidusPromotions::Promotion.count).to eq(3)

    click_link("My future Promotion")
    expect(page).to have_content("My future Promotion")
    expect(page).to have_content("Starts at")
  end
end
