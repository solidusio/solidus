require 'spec_helper'

describe "States", type: :feature do
  stub_authorization!

  let!(:country) { create(:country) }

  let!(:hungary) do
    Spree::Country.create!(name: "Hungary", iso_name: "Hungary")
  end

  def go_to_states_page
    visit spree.admin_country_states_path(country)
    expect(page).to have_css("#new_state_link")
  end

  context "admin visiting states listing" do
    let!(:state) { create(:state, country: country) }

    it "should correctly display the states" do
      visit spree.admin_country_states_path(country)
      expect(page).to have_content(state.name)
    end
  end

  context "creating and editing states" do
    it "should allow an admin to edit existing states", js: true do
      go_to_states_page
      select2 country.name, from: 'Country'

      click_link "new_state_link"
      fill_in "state_name", with: "Calgary"
      fill_in "Abbreviation", with: "CL"
      click_button "Create"
      expect(page).to have_content("successfully created!")
      expect(page).to have_content("Calgary")
    end

    it "should allow an admin to create states for non default countries", js: true do
      go_to_states_page
      select2 hungary.name, from: 'Country'

      click_link "new_state_link"
      fill_in "state_name", with: "Pest megye"
      fill_in "Abbreviation", with: "PE"
      click_button "Create"
      expect(page).to have_content("successfully created!")
      expect(page).to have_content("Pest megye")
      expect(find("#s2id_country")).to have_content("Hungary")
    end

    it "should show validation errors", js: true do
      go_to_states_page
      select2 country.name, from: 'Country'

      click_link "new_state_link"

      fill_in "state_name", with: ""
      fill_in "Abbreviation", with: ""
      click_button "Create"
      expect(page).to have_content("Name can't be blank")
    end
  end
end
