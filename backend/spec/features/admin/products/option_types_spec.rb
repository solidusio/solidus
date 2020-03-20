# frozen_string_literal: true

require 'spec_helper'

describe "Option Types", type: :feature do
  stub_authorization!

  before(:each) do
    visit spree.admin_path
    click_nav "Products"
  end

  context "listing option types" do
    it "should list existing option types" do
      create(:option_type, name: "tshirt-color", presentation: "Color")
      create(:option_type, name: "tshirt-size", presentation: "Size")

      click_link "Option Types"
      within("table#listing_option_types") do
        expect(page).to have_content("Color")
        expect(page).to have_content("tshirt-color")
        expect(page).to have_content("Size")
        expect(page).to have_content("tshirt-size")
      end
    end
  end

  context "creating a new option type" do
    it "should allow an admin to create a new option type", js: true do
      click_link "Option Types"
      click_link "new_option_type_link"
      expect(page).to have_content("New Option Type")
      fill_in "option_type_name", with: "shirt colors"
      fill_in "option_type_presentation", with: "colors"
      click_button "Create"
      expect(page).to have_content("successfully created!")

      page.find('#option_type_option_values_attributes_0_name').set('color')
      page.find('#option_type_option_values_attributes_0_presentation').set('black')

      click_button "Update"
      expect(page).to have_content("successfully updated!")
    end
  end

  context "editing an existing option type" do
    it "should allow an admin to update an existing option type" do
      create(:option_type, name: "tshirt-color", presentation: "Color")
      create(:option_type, name: "tshirt-size", presentation: "Size")
      click_link "Option Types"
      within('table#listing_option_types') do
        find('tr', text: 'Size').click_link "Edit"
      end
      fill_in "option_type_name", with: "foo-size 99"
      click_button "Update"
      expect(page).to have_content("successfully updated!")
      expect(page).to have_content("foo-size 99")
    end
  end

  # Regression test for https://github.com/spree/spree/issues/2277
  it "can remove an option value from an option type", js: true do
    option_value = create(:option_value)
    click_link "Option Types"
    within('table#listing_option_types') { click_icon :edit }
    expect(page).to have_title("#{option_value.option_type.name} - Option Types - Products")
    # persisted and new element is seen
    expect(page).to have_css("tbody#option_values tr", count: 2)

    accept_alert do
      click_icon :trash
    end
    expect(page).to have_content 'successfully removed'

    # only the new element is left
    expect(page).to have_css("tbody#option_values tr", count: 1)
  end
end
