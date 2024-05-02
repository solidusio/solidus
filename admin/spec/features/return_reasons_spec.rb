# frozen_string_literal: true

require 'spec_helper'

describe "Return Reasons", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists Return Reasons and allows deleting them" do
    create(:return_reason, name: "Default-return-reason")

    visit "/admin/return_reasons"
    expect(page).to have_content("Default-return-reason")
    expect(page).to be_axe_clean

    select_row("Default-return-reason")
    click_on "Delete"
    expect(page).to have_content("Return Reasons were successfully removed.")
    expect(page).not_to have_content("Default-return-reason")
    expect(Spree::ReturnReason.count).to eq(0)
    expect(page).to be_axe_clean
  end

  it "allows an admin to create a new RMA reason" do
    visit "/admin/return_reasons"

    expect(page).to have_content("Add new")
    click_on "Add new"

    expect(page).to have_content("New Return Reason")
    fill_in "Name", with: "Size too small"

    expect(page).to have_css("input[type=checkbox][name='return_reason[active]'][checked='checked']")

    click_on "Add Return Reason"

    expect(page).to have_content("Return reason has been successfully created!")
  end
end
