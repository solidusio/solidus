# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Promotion Categories", :js, type: :feature, solidus_admin: true do
  before { sign_in create(:admin_user, email: "admin@example.com") }

  it "lists promotion categories and allows deleting them" do
    create(:friendly_promotion_category, name: "test1", code: "code1")
    create(:friendly_promotion_category, name: "test2", code: "code2")

    visit "/admin/friendly/promotion_categories"
    expect(page).to have_content("test1")
    expect(page).to have_content("test2")

    expect(page).to be_axe_clean

    select_row("test1")
    click_on "Delete"
    expect(page).to have_content("Promotion Categories were successfully removed.")
    expect(page).not_to have_content("test1")
    expect(SolidusFriendlyPromotions::PromotionCategory.count).to eq(1)
  end
end
