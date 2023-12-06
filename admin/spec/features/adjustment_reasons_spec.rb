# frozen_string_literal: true

require 'spec_helper'

describe "Adjustment Reasons", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists adjustment reasons and allows deleting them" do
    create(:adjustment_reason, name: "Default-adjustment-reason")

    visit "/admin/adjustment_reasons"
    expect(page).to have_content("Default-adjustment-reason")
    expect(page).to be_axe_clean

    select_row("Default-adjustment-reason")
    click_on "Delete"
    expect(page).to have_content("Adjustment Reasons were successfully removed.")
    expect(page).not_to have_content("Default-adjustment-reason")
    expect(Spree::AdjustmentReason.count).to eq(0)
    expect(page).to be_axe_clean
  end
end
