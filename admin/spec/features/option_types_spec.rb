# frozen_string_literal: true

require 'spec_helper'

describe "Option Types", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists option types and allows deleting them" do
    create(:option_type, name: "color", presentation: "Color")
    create(:option_type, name: "size", presentation: "Size")

    visit "/admin/option_types"
    expect(page).to have_content("color")
    expect(page).to have_content("size")

    expect(page).to be_axe_clean

    select_row("color")
    click_on "Delete"
    expect(page).to have_content("Option types were successfully removed.")
    expect(page).not_to have_content("color")
    expect(Spree::OptionType.count).to eq(1)
  end
end
