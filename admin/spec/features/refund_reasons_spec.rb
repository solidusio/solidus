# frozen_string_literal: true

require 'spec_helper'

describe "Refund Reasons", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists refund reasons and allows deleting them" do
    create(:refund_reason, name: "Default-refund-reason")

    visit "/admin/refund_reasons"
    expect(page).to have_content("Default-refund-reason")
    expect(page).to be_axe_clean

    select_row("Default-refund-reason")
    click_on "Delete"
    expect(page).to have_content("Refund Reasons were successfully removed.")
    expect(page).not_to have_content("Default-refund-reason")
    expect(Spree::RefundReason.count).to eq(0)
    expect(page).to be_axe_clean
  end
end
