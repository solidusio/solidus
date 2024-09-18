# frozen_string_literal: true

require 'spec_helper'

describe "Properties", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists properties and allows deleting them" do
    create(:property, name: "Type prop", presentation: "Type prop")
    create(:property, name: "Size", presentation: "Size")

    visit "/admin/properties"
    expect(page).to have_content("Type prop")
    expect(page).to have_content("Size")

    expect(page).to be_axe_clean

    select_row("Type prop")
    click_on "Delete"
    expect(page).to have_content("Properties were successfully removed.")
    expect(page).not_to have_content("Type prop")
    expect(Spree::Property.count).to eq(1)
  end

  context "when creating a new product property" do
    before do
      visit "/admin/properties"
      click_on "Add new"
      expect(page).to have_content("New Property")
      expect(page).to be_axe_clean
    end

    it "opens and closes new property modal" do
      expect(page).to have_selector("dialog")
      within("dialog") { click_on "Cancel" }
      expect(page).not_to have_selector("dialog")
    end
  end
end
