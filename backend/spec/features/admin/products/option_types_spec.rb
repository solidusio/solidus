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
    expect(page).to have_css("tbody#option_values tr", count: 1)
    within("tbody#option_values") do
      find('.spree_remove_fields').click
    end
    # Assert that the field is hidden automatically
    expect(page).to have_no_css("tbody#option_values tr")

    # Ensure the DELETE request finishes
    expect(page).to have_no_css("#progress")

    # Then assert that on a page refresh that it's still not visible
    visit page.current_url
    # What *is* visible is a new option value field, with blank values
    # Sometimes the page doesn't load before the all check is done
    # lazily finding the element gives the page 10 seconds
    expect(page).to have_css("tbody#option_values")
    all("tbody#option_values tr input", count: 2).each do |input|
      expect(input.value).to be_blank
    end
  end

  # Regression test for https://github.com/spree/spree/issues/3204
  it "can remove a non-persisted option value from an option type", js: true do
    create(:option_type)
    click_link "Option Types"
    within('table#listing_option_types') { click_icon :edit }

    expect(page).to have_css("tbody#option_values tr", count: 1)

    # Add a new option type
    click_button "Add Option Value"
    expect(page).to have_css("tbody#option_values tr", count: 2)

    # Remove default option type
    within("tbody#option_values") do
      within_row(1) do
        find('.fa-trash').click
      end
    end
    # Assert that the field is hidden automatically
    expect(page).to have_css("tbody#option_values tr", count: 1)

    # Remove added option type
    within("tbody#option_values") do
      find('.fa-trash').click
    end
    # Assert that the field is hidden automatically
    expect(page).to have_css("tbody#option_values tr", count: 0)
  end
end
